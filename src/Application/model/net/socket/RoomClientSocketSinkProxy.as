package Application.model.net.socket
{
	import Application.NotificationString;
	import Application.control.net.room.CMD_GameRoomCmd;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IClientSocketSink;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class RoomClientSocketSinkProxy extends ClientSocketSinkBase implements IClientSocketSink
	{
		public static const NAME:String = "GameClientSocketSinkProxy";
		public static var instance:RoomClientSocketSinkProxy;
		
		public static function getInstance(_ip:String = null , _port:uint = 0 ):RoomClientSocketSinkProxy{
			if(!instance){
				instance = new RoomClientSocketSinkProxy(_ip,_port);
			}
			else if(_ip!=null && _port!=0){
				//需要修改socket连接地址与端口
				instance.changeHost(_ip,_port);
			}
			return instance as RoomClientSocketSinkProxy
		}
		
		public function RoomClientSocketSinkProxy(_ip:String, _port:uint)
		{
			super(_ip, _port, NAME);
		}
		
		/**
		 * ====================================================
		 * -------------------覆盖基类方法----------------------
		 * ====================================================
		 */
		
		override protected function connectHandle():void{
			if(GlobalDef.DEBUG)trace("in GameClientSocketSinkProxy connectHandle: socket连接成功！");
			//sendNotification(NotificationString.CONNECT_LOADING,null,"1");
			//发送登录信息
			sendNotification(NotificationString.CMD_ROOM_LOGIN,null,CMD_DEF_ROOM.SUB_GP_LOGON_USERID.toString());
		}
		
		override protected function errorHandle():void{
			if(GlobalDef.DEBUG)trace("in GameClientSocketSinkProxy errorHandle: 连接socket发生错误！");
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"0");
		}
		
		override protected function closeHandle():void{
			if(GlobalDef.DEBUG)trace("in GameClientSocketSinkProxy closeHandle: socket关闭！");
			//如果有正在连接的状态面板，则移除
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"0");
			//通知弹出alert
			var obj:Object = new Object;
			obj["closeHandler"] = socketCloseHandle;
			obj["type"] = "1";
			obj["text"]= "您已经掉线，请重新进入房间！";
			
			sendNotification(NotificationString.ALERT,obj,"0");
		}
		
		override protected function timeoutHandle():void{
			if(GlobalDef.DEBUG)trace("in GameClientSocketSinkProxy timeoutHandle: 连接socket超时！");
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"1");
		}
		
		/**
		 * ====================================================
		 * --------------------覆盖接口方法----------------------
		 * ====================================================
		 */
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		override public function getProxyName():String
		{
			return NAME;
		}
		
		override public function setData(data:Object):void
		{
		}
		
		override public function getData():Object
		{
			return null;
		}
		
		override public function onRegister():void
		{
		}
		
		override public function onRemove():void
		{
		}
		
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		override public function receiveSocketData(wMainCmdID:uint, wSubCmdID:uint, baBuffer:ByteArray, wDataSize:uint):void
		{
			super.receiveSocketData(wMainCmdID, wSubCmdID, baBuffer, wDataSize);
			
			var obj:Object=new Object;
			obj.dataBuffer = baBuffer;
			obj.dataSize = wDataSize;
			
			switch(wMainCmdID){
				//登录相关
				case CMD_DEF_ROOM.MDM_GR_LOGON:{
					sendNotification(NotificationString.CMD_ROOM_LOGIN, obj, wSubCmdID.toString());
					break;
				}
				//用户相关
				case CMD_DEF_ROOM.MDM_GR_USER:{
					sendNotification(NotificationString.CMD_ROOM_USER, obj, wSubCmdID.toString());
					break;
				}
				//配置相关
				case CMD_DEF_ROOM.MDM_GR_INFO:{
					sendNotification(NotificationString.CMD_ROOM_INFO, obj, wSubCmdID.toString());
					break;
				}
				//房间状态相关
				case CMD_DEF_ROOM.MDM_GR_STATUS:{
					sendNotification(NotificationString.CMD_ROOM_STATUS, obj, wSubCmdID.toString());
					break;
				}
				//管理相关
				case CMD_DEF_ROOM.MDM_GR_MANAGER:{
					
					break;
				}
				//系统消息
				case CMD_DEF_ROOM.MDM_GR_SYSTEM:{
					sendNotification(NotificationString.CMD_ROOM_MESSAGE, obj, wSubCmdID.toString());
					break;
				}
				//房间数据包
				case CMD_DEF_ROOM.MDM_GR_SERVER_INFO:{
					sendNotification(NotificationString.CMD_ROOM_SERVER_INFO, obj, wSubCmdID.toString());
					break;
				}
				//礼物数据
				case CMD_DEF_ROOM.MDM_GF_PRESENT:{
					sendNotification(NotificationString.CMD_ROOM_PRESENT,obj,wSubCmdID.toString());
					break;
				} 
				//
				case CMD_DEF_ROOM.MDM_GF_FRAME:
				case CMD_DEF_ROOM.MDM_GF_GAME:
				{
					if(facade.hasProxy(GameFrameProxy.NAME)){
						(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).RecvSocketData(wMainCmdID, wSubCmdID, baBuffer, wDataSize);
					}
					else
					{
						sendNotification(NotificationString.CMD_GAME_FRAME,obj,wSubCmdID.toString());
					}
					break;
				}
			}
		}
		
		
		/**
		 * =======================================================================================
		 * --------------------------------------------功能方法---------------------------------
		 * =======================================================================================
		 */
		
		/////////////////////////////////////////////////////////////////////////////
		public function socketCloseHandle(evt:Event = null):void{
			sendNotification(NotificationString.CMD_GAME_ROOM,null,CMD_GameRoomCmd.ROOM_SOCKET_CLOSE);
		}
	}
}