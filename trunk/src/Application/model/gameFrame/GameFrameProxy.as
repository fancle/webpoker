package Application.model.gameFrame
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IGameClass;
	import Application.model.interfaces.IGameClassContainer;
	import Application.model.interfaces.ISocketDataSink;
	import Application.model.interfaces.IUserItem;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.user.UserManager;
	
	import common.assets.ModuleLib;
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.IPC_DEF;
	import common.data.StringDef;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class GameFrameProxy extends Proxy implements IProxy, IGameClassContainer,ISocketDataSink
	{
		public static const NAME:String = "GameFrameProxy";
		
		private var m_gameClass:IGameClass;
		private var m_gameAssets:LoaderInfo;
		private var p_meItem:IUserItem;
		
		public function GameFrameProxy(proxyName:String=null, data:Object=null)
		{
			super(NAME, data);
		}
		/** 
		 * 初始化自己
		 */
		private function init():void{
			var hashMap:HashMap = ModuleLib.getInstance().gameLib.find(data as String);
			
			m_gameClass = hashMap.find("module") as IGameClass;			
			m_gameAssets = hashMap.find("material") as LoaderInfo;
			
			if(m_gameClass) initGameClass();
		}
		/**
		 * 初始化游戏客户端
		 */
		private function initGameClass():void{
			m_gameClass.CreateGameClient(this,m_gameAssets);
		}
		
		override public function onRegister():void
		{
			super.onRegister();
			p_meItem = UserManager.getInstance().getMeItem();
			init();
			
			/* if((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre == GlobalDef.GAME_GENRE_MATCH){
				var msgObj:Object = new Object;
				msgObj["timeDelay"] = -1;
				msgObj["message"] = "";
				sendNotification(NotificationString.MSG_GAMEFRAME,msgObj);
			} */
		}
		
		override public function onRemove():void
		{
			super.onRemove()
			data = null;
			
			/* if((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre == GlobalDef.GAME_GENRE_MATCH){
				var msgObj:Object = new Object;
				msgObj["timeDelay"] = -1;
				msgObj["message"] = StringDef.WEIT_TO_GET_TABLE;
				sendNotification(NotificationString.MSG_GAMEFRAME,msgObj);
			} */
		}
		/////////////////////////////////////////////////////////////////////////
		//功能函数
		/////////////////////////////////////////////////////////////////////////
		/**
		 * 关闭游戏客户端 
		 * @return 
		 * 
		 */		
		private function CloseGameClient():int
		{
			if(m_gameClass)
			{
				sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONTROL,IPC_DEF.IPC_SUB_CLOSE_FRAME,null,0);
				m_gameClass.DestroyGameClient();
				
				//需要通知mediator层移除游戏
				//IPC_KernelCmd--发送退出游戏命令--CMD_RoomUserCmd/userStatus--CMD_FrameUserCmd--GameBaseClass/userStatus--CMD_Game_Frame/"remove"		
				/* var game:MovieClip = m_GameClassInstance.GetMovieClip();
				removeChild(game); */
				
				//消除游戏引用
				m_gameClass = null;
				
				//if(m_FlashMovieClipHelper)
					//m_FlashMovieClipHelper.Resume();
			} 
			return 0;
		}
		///////////////////////////////////////////////////////////////////////////////////
		//封装的发送消息方法
		///////////////////////////////////////////////////////////////////////////////////
		/**
		 * 向游戏发送socket数据 
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */		
		public function sendIPCSocketMessage(wMainCmdID:uint, wSubCmdID:uint, pBuffer:ByteArray, wDataSize:int):Boolean{
			if(m_gameClass == null)
			{
				return false;
			}
			return m_gameClass.OnIPCSocketMessage(wMainCmdID, wSubCmdID, pBuffer, wDataSize);
		}
		/**
		 *　向游戏发送信息数据 
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */			
		public function sendIPCChannelMessage(wMainCmdID:uint, wSubCmdID:uint, pBuffer:*, wDataSize:int):Boolean{
			if(m_gameClass == null)
			{
				return false;
			}
			return m_gameClass.OnIPCChannelMessage(wMainCmdID, wSubCmdID, pBuffer, wDataSize);
		}
		/////////////////////////////////////////////////////////////////////////
		//实现接口方法
		/////////////////////////////////////////////////////////////////////////
		/* 实现IGameClassContainer接口 */
		//销毁游戏端
		public function DestroyGameClass(game:IGameClass, bAutoSitChairAgain:Boolean = false):void
		{
			if(m_gameClass == game)
			{
				CloseGameClient();
				//再随机坐下
				//if(bAutoSitChairAgain)
					//OnEventAutoSitChair(null);
			}
		}
		
		/* 实现ISocketDataSink接口 */
		public function RecvSocketData(wMainCmdID:uint, wSubCmdID:uint, pBuffer:ByteArray, wDataSize:int):Boolean
		{
			var obj:Object = new Object;
			obj["dataBuffer"] = pBuffer;
			obj["dataSize"] = wDataSize;
			
			switch(wMainCmdID){
				case CMD_DEF_ROOM.MDM_GF_FRAME:				//框架消息
				{
					switch(wSubCmdID){
						case CMD_DEF_ROOM.SUB_GF_USER_CHAT:		//框架数据：游戏中的聊天
						{
							sendNotification(NotificationString.CMD_FRAME_USER,obj,wSubCmdID.toString());
							break;
						}
						case CMD_DEF_ROOM.SUB_GF_MESSAGE:		//框架数据：系统消息
						{
							sendNotification(NotificationString.CMD_GAME_FRAME,obj,"message");
							break;
						}
						case CMD_DEF_ROOM.SUB_GF_MATCHMESSAGE:	//框架弹出消息
						{
							sendNotification(NotificationString.CMD_GAME_FRAME,obj,"matchMessage");
							break;
						}
						default:								//框架数据：由游戏处理
						{
							return m_gameClass.OnIPCSocketMessage(wMainCmdID, wSubCmdID, pBuffer, wDataSize);
						}
					}
					
					break;
				}
				default:									//非框架数据：由游戏处理
				{
					return m_gameClass.OnIPCSocketMessage(wMainCmdID, wSubCmdID, pBuffer, wDataSize);
				}
			}
			
			return false;
		}
		
		/* 实现IChannelMessageSink接口 */
		/**
		 * 处理socket消息
		 */
		public function OnIPCSocketMessage(wMainCmdID:uint,wSubCmdID:uint,pBuffer:ByteArray,wDataSize:int):Boolean
		{
			//发送socket数据
			return (facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(wMainCmdID,wSubCmdID,pBuffer,wDataSize);
			return false;
		}
		/**
		 * 处理信道消息
		 */
		public function OnIPCChannelMessage(wMainCmdID:uint,
								  wSubCmdID:uint,
								  pIPCBuffer:*, 
								  wDataSize:uint):Boolean
		{
			var obj:Object = new Object;
			obj["dataBuffer"] = pIPCBuffer;
			obj["dataSize"] = wDataSize;
			
			
			switch(wMainCmdID){
				case IPC_DEF.IPC_MAIN_CONTROL:		//控制消息
				{
					sendNotification(NotificationString.IPC_CONTROL,obj,wSubCmdID.toString());
					return true;
					break;
				}
				case IPC_DEF.IPC_MIAN_IPC_KERNEL:	//信道内核信息
				{
					obj["extraData"] = m_gameClass;
					sendNotification(NotificationString.IPC_KERNEL,obj,wSubCmdID.toString());
					return true;
					break;
				}
				case IPC_DEF.IPC_MAIN_PROPERTY:		//信道道具信息
				{
					sendNotification(NotificationString.IPC_PROPERTY,obj,wSubCmdID.toString());
					return true;
					break;
				}
			}
			return false;
		}
		
	}
}