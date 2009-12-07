package Application.control.net.gameFrame
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IGameItem;
	import Application.model.interfaces.IGameManager;
	import Application.model.interfaces.IServerItem;
	import Application.model.interfaces.IUserItem;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.gameFrame.IPC_GF_ServerInfo;
	import Application.model.vo.protocol.gameFrame.IPC_Message;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.IPC_DEF;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class IPC_KernelCmd extends SimpleCommand implements ICommand
	{
		private var pMeUserItem:IUserItem = UserManager.getInstance().getMeItem();
		
		public function IPC_KernelCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var obj:Object = notification.getBody();
			
			switch(notification.getType()){
				case IPC_DEF.IPC_SUB_IPC_CLIENT_CONNECT.toString():		//游戏初始化完成，给游戏传递初始信息
				{
					
					//发送初始化数据
					if(sendGameInfo()){
						if(sendTableUsers()){
							//通知GameClass初始化数据已经发送完闭，可以通知游戏服务端了！
							(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONTROL,IPC_DEF.IPC_SUB_START_FINISH,null,0);
							//通知GameFrameMediator该addChild游戏了
							sendNotification(NotificationString.CMD_GAME_FRAME,obj["extraData"],"start");
						}
					}
					break;
				}
				case IPC_DEF.IPC_SUB_IPC_CLIENT_CLOSE.toString():		//关闭游戏
				{
					closeGame();
					break;
				}
				case IPC_DEF.IPC_SUB_IPC_MESSAGE.toString():
				{
					messageHandle(notification.getBody()["dataBuffer"] as IPC_Message);
					break;
				}
				
			}
		}
		///////////////////////////////////////////////////////////////////////////
		/**
		 * 发送游戏基本信息
		 */
		private function sendGameInfo():Boolean{
			var gameManager:IGameManager = facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy;
			var serverInfo:IPC_GF_ServerInfo = new IPC_GF_ServerInfo;
			
			var pGameItem:IGameItem = gameManager.getCurrentGameItem();
			var pServerItem:IServerItem = gameManager.getCurrentServerItem();
			var serverConfigInfo:CMD_GQ_ServerInfo = pGameItem.getServerConfigInfo();
			serverInfo.dwUserID = pMeUserItem.GetUserID();
			serverInfo.wKindID = serverConfigInfo.wKindID;
			serverInfo.wServerID =  gameManager.getCurrentServerItem().getServerID();
			serverInfo.wTableID = pMeUserItem.GetUserStatus().wTableID;
			serverInfo.wChairID = pMeUserItem.GetUserStatus().wChairID;
			serverInfo.wChairCount = serverConfigInfo.wChairCount;
			serverInfo.wGameGenre = serverConfigInfo.wGameGenre;
			serverInfo.szKindName = pGameItem.getGameName();
			serverInfo.szServerName = pServerItem.getServerName();			
			
			return (facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONFIG,IPC_DEF.IPC_SUB_SERVER_INFO,serverInfo,IPC_GF_ServerInfo.sizeof_IPC_GF_ServerInfo);
		}
		/**
		 * 发送上桌玩家
		 */
		private function sendTableUsers():Boolean{
			for each(var userItem:IUserItem in UserManager.getInstance().getUserListByTableID(pMeUserItem.GetUserStatus().wTableID)){
				if(GlobalDef.DEBUG)trace("============in IPC_KernelCmd sendTableUsers:userStatus = " + userItem.GetUserStatus().cbUserStatus);
				(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_USER,IPC_DEF.IPC_SUB_USER_COME,userItem.GetUserData(),tagUserData.sizeof_tagUserData);
			}
			return true;
		}
		/**
		 * 向服务器请求离开游戏---即发送站起请求
		 * 
		 */
		private function closeGame():void{
			//发送关闭框架通知
			var roomSocket:RoomClientSocketSinkProxy = facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy;
			var gameType:int = -1;
			
			if(facade.hasProxy(GameManagerProxy.NAME)){
				try{
					gameType = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre;
				}
				catch(error:Error){
					
				}
			}
			
			var obj:Object = new Object;
			obj.messageCode = 0;
			if(!roomSocket.isContented()){
				obj.messageCode = 1;
			}
			else if(gameType == GlobalDef.GAME_GENRE_MATCH){
				//请求站起
				regStandUp();
				
				obj.messageCode = 2;
			}else{
				//请求站起
				regStandUp();
			}
			
			sendNotification(NotificationString.CMD_GAME_FRAME,obj,"exitFrame");		
		}
		private function regStandUp():void
		{
			var pMeUserStatus:tagUserStatus;
			
			try{
				pMeUserStatus=UserManager.getInstance().getMeItem().GetUserStatus();
			}catch(error:Error){
				return;
			}
				
			if (pMeUserStatus.wTableID!=(GlobalDef.INVALID_TABLE))
			{
				if (pMeUserStatus.cbUserStatus==GlobalDef.US_PLAY) 
				{
					SendLeftGamePacket();
				}
				SendStandUpPacket();
			}
		}
		private function SendLeftGamePacket():void{
			(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(CMD_DEF_ROOM.MDM_GR_USER,CMD_DEF_ROOM.SUB_GR_USER_LEFT_GAME_REQ,null,0);
		}
		private function SendStandUpPacket():void{
			(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(CMD_DEF_ROOM.MDM_GR_USER,CMD_DEF_ROOM.SUB_GR_USER_STANDUP_REQ,null,0);
		}
		//////////////////////////////////////////////////
		private function messageHandle(ipcMessage:IPC_Message):void
		{
			switch(ipcMessage.bMessageCode){
				case GlobalDef.SMT_EJECT:
				{
					sendNotification(NotificationString.ALERT,ipcMessage.oMessageBody,"0");
					break;
				}
			}
		}
	}
}