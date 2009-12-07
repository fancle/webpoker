package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.vo.protocol.login.CMD_GQ_Login_Error;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.CMD_LoginByUserID;
	import Application.model.vo.protocol.system.tagClientSerial;
	import Application.utils.Memory;
	
	import common.data.CMD_DEF_HALL;
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomLoginCmd extends SimpleCommand implements ICommand
	{
		public function CMD_RoomLoginCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case CMD_DEF_ROOM.SUB_GP_LOGON_USERID.toString():{
					//发送登录信息
					sendLoginAccount();
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_LOGON_SUCCESS.toString():{
					//登录成功
					recvLogonSuccess();
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_LOGON_ERROR.toString():{
					//登录失败
					recvLogonError(notification.getBody());
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_LOGON_FINISH.toString():{
					//登录完成
					recvLogonFinish();
					break;
				}
			}
		}
		
		private function sendLoginAccount():void{
			//////////////////////////////////////////////////////////////////
			//标识为flash版登录
			//if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd sendLoginAccount:在这里需要给服务器发送flash登录标志");
			//RoomClientSocketSinkProxy(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME)).send(CMD_DEF_HALL.MDM_GR_LOGON, CMD_DEF_HALL.SUB_GP_LONON_FLASH ,null, 0);
			//////////////////////////////////////////////////////////////////
			//从vo里取相关信息
			 var cmd_roomLogin:CMD_LoginByUserID = new CMD_LoginByUserID;
			
			cmd_roomLogin.dwPlazaVersion = GlobalDef.VER_PLAZA_LOW | (GlobalDef.VER_PLAZA_HIGH<<16);
			cmd_roomLogin.dwProcessVersion = GlobalDef.VER_PROCESS;
			//cmd_roomLogin.dwClientLogo = GlobalDef.LOGO_CLIENT_FLASH;
			cmd_roomLogin.dwUserID = tagGlobalUserData.dwUserID;
			cmd_roomLogin.szPassWord = tagGlobalUserData.szPassword;
			
			var bytes:ByteArray = cmd_roomLogin.toByteArray();
			//////////////////////////////////////////////////////
		 	//机器序列
		 	var serial:tagClientSerial=new tagClientSerial;
			serial.dwSystemVer=0x0;
			for(var i:int=0;i<3;i++){
				serial.dwComputerID[i]=0x0;
			}
			var serialBytes:ByteArray=serial.toByteArray();
			
			Memory.memsetByByteArray(bytes, serialBytes, tagClientSerial.sizeof_tagClientSerial, bytes.length+4, 0);      
			//////////////////////////////////////////////////////
			var dataSize:int = CMD_LoginByUserID.sizeof_CMD_LoginByUserID + 4 + tagClientSerial.sizeof_tagClientSerial;			
			//var dataSize:int = CMD_LoginByUserID.sizeof_CMD_LoginByUserID;
			
			
			RoomClientSocketSinkProxy(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME)).send(CMD_DEF_ROOM.MDM_GR_LOGON, CMD_DEF_ROOM.SUB_GP_LOGON_USERID, bytes, dataSize);
		}
		
		private function recvLogonSuccess(obj:Object = null):void{
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd recvLogonSuccess: success");
			//通知界面登录成功
			sendNotification(NotificationString.ROOM_LOGIN);
		}
		
		private function recvLogonError(obj:Object = null):void{
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd recvLogonError: error");
			var bytes:ByteArray = obj["dataBuffer"];
			var dataSize:uint = obj["dataSize"];
			
			var ErrorMessage:CMD_GQ_Login_Error = CMD_GQ_Login_Error.readData(bytes);
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd recvLogonError:ErrorMessage.lErrorCode = " + ErrorMessage.lErrorCode);
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd recvLogonError:ErrorMessage.szErrorDescribe = " + ErrorMessage.szErrorDescribe);
			//移除连接状态面板
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"0");
			//弹出消息
			var obj:Object = new Object;
			obj["type"] = "1";
			obj["text"]= ErrorMessage.szErrorDescribe;
			
			sendNotification(NotificationString.ALERT,obj,"0");
		}
		
		/* 当登录完成后即表示已经接收到如下数据　---　房间配置信息、列表配置信息、房间内用户信息、房间状态信息、道具鲜花属性，可以进入房间界面了！ */
		private function recvLogonFinish(obj:Object = null):void{
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd recvLogonSuccess: finish");
			if(GlobalDef.DEBUG)trace("in CMD_RoomLoginCmd execute: getTimer2 = " + getTimer());
			sendNotification(NotificationString.GAME_ROOM_SUCCESS);
			
			sendNotification(NotificationString.CONNECT_LOADING,null,"1");//去掉正在连接服务的消息框
		}
	}
}