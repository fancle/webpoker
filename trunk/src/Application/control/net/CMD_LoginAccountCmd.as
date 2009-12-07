package Application.control.net
{
	import Application.NotificationString;
	import Application.model.net.socket.LoginClientSocketSinkProxy;
	import Application.model.vo.protocol.login.CMD_GP_Login;
	import Application.model.vo.protocol.login.CMD_GQ_Login_Error;
	import Application.model.vo.protocol.login.CMD_GQ_Login_Success;
	import Application.model.vo.protocol.login.tagDataDescribe;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.system.tagClientSerial;
	import Application.utils.Memory;
	
	import common.data.CMD_DEF_HALL;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_LoginAccountCmd extends SimpleCommand implements ICommand
	{
		public function CMD_LoginAccountCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var type:String=notification.getType();
			var obj:Object=notification.getBody();
			
			switch(type){
				case CMD_DEF_HALL.SUB_GP_LOGON_ACCOUNT.toString():{
					//调用登录socket来向服务器发送帐户登录信息
					sendAccount(obj);					
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LOGON_SUCCESS.toString():{
					recvSuccessInfo(obj);
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LOGON_ERROR.toString():{
					recvFailInfo(obj);
					break;
				}				
				case CMD_DEF_HALL.SUB_GQ_LOGON_FINISH.toString():{
					//登录完成
					recvLoginFinish();
					break;
				}
			}
		}
		
		private function sendAccount(obj:Object):void{
			
			//////////////////////////////////////////////////////////////////
			//标识为flash版登录
			//LoginClientSocketSinkProxy(facade.retrieveProxy(LoginClientSocketSinkProxy.NAME)).send(CMD_DEF_HALL.MDM_GR_LOGON, CMD_DEF_HALL.SUB_GP_LONON_FLASH ,null, 0);
			//////////////////////////////////////////////////////////////////
			
			var cmd_gp_Login:CMD_GP_Login=new CMD_GP_Login;
			cmd_gp_Login.strUser_name=obj["user_name"];
			cmd_gp_Login.strPassword=obj["password"];
			
			var bytes:ByteArray=cmd_gp_Login.toByteArray();
			
			//////////////////////////////////////////////////////
		 	
			 var serial:tagClientSerial=new tagClientSerial;
			serial.dwSystemVer=0xffff;
			for(var i:int=0;i<3;i++){
				serial.dwComputerID[i]=0xffff0000;
			}
			var serialBytes:ByteArray=serial.toByteArray();
			
			Memory.memsetByByteArray(bytes, serialBytes, tagClientSerial.sizeof_tagClientSerial, bytes.length+4, 0);     
			//////////////////////////////////////////////////////
			var dataSize:int = CMD_GP_Login.sizeof_CMD_GP_Login + 4 + tagClientSerial.sizeof_tagClientSerial;			
			//var dataSize:int = CMD_GP_Login.sizeof_CMD_GP_Login;
			
			LoginClientSocketSinkProxy(facade.retrieveProxy(LoginClientSocketSinkProxy.NAME)).send(CMD_DEF_HALL.MDM_GR_LOGON, CMD_DEF_HALL.SUB_GP_LOGON_ACCOUNT ,bytes, dataSize);
		}
		
		private function recvSuccessInfo(obj:Object):void{
			if(obj!=null){
				var bytes:ByteArray = obj["dataBuffer"];
			
				bytes.position=0;
			
				//先读出基本信息
				var loginAccouts:CMD_GQ_Login_Success = CMD_GQ_Login_Success.readData(bytes);
				tagGlobalUserData.cbGender = loginAccouts.cbGender;
				tagGlobalUserData.cbMember = loginAccouts.cbMember;
				tagGlobalUserData.cbHonorLevel = loginAccouts.cbHonorLevel;
				tagGlobalUserData.dwCustomFaceVer = loginAccouts.dwCustomFaceVer;
				tagGlobalUserData.dwExperience = loginAccouts.dwExperience;
				tagGlobalUserData.dwGameID = loginAccouts.dwGameID; 
				tagGlobalUserData.dwUserID = loginAccouts.dwUserID;
				tagGlobalUserData.wFaceID = loginAccouts.wFaceID;
				tagGlobalUserData.lGameGold = loginAccouts.lGameGold;
				tagGlobalUserData.lUserUQ = loginAccouts.lGameUQ;
				
				
				//循环读出数据描述 --- 根据bytes.bytesAvailable
				var i:int=0;
				var bytesSize:int=bytes.bytesAvailable;
				
				while(bytes.bytesAvailable>=tagDataDescribe.sizeof_tagDataDescribe){
					var dataDescribe:tagDataDescribe=tagDataDescribe.readData(bytes);
					bytesSize -= tagDataDescribe.sizeof_tagDataDescribe;
					i+=4;
					switch(dataDescribe.wDataDescribe){
						case GlobalDef.DTP_USER_ACCOUNTS:		//用户帐户
						{
							tagGlobalUserData.szAccounts=Memory.readStringByByteArray(bytes,dataDescribe.wDataSize);
							var str1:String = tagGlobalUserData.szAccounts;
							bytesSize -= dataDescribe.wDataSize;
							i += dataDescribe.wDataSize;
							
							break;
						}
						case GlobalDef.DTP_USER_PASS:			//用户密码
						{
							tagGlobalUserData.szPassword =  Memory.readStringByByteArray(bytes,dataDescribe.wDataSize);
							var str2:String = tagGlobalUserData.szPassword;
							bytesSize -= dataDescribe.wDataSize;
							i += dataDescribe.wDataSize;
							break;
						}
						case GlobalDef.DTP_UNDER_WRITE:			//个性签名
						{
							tagGlobalUserData.szUnderWrite = Memory.readStringByByteArray(bytes,dataDescribe.wDataSize);
							bytesSize -= dataDescribe.wDataSize;
							i += dataDescribe.wDataSize;
							break;
						}
						case GlobalDef.DTP_USER_NICKNAME:		//用户昵称
						{
							tagGlobalUserData.szNickName =  Memory.readStringByByteArray(bytes,dataDescribe.wDataSize);
							var str:String = tagGlobalUserData.szNickName;
							bytesSize -= dataDescribe.wDataSize;
							i += dataDescribe.wDataSize;
							break;
						}
						//case 
					}//switch end
				}//while end
			}//if end
			
		}//function end
		private function recvFailInfo(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var dataSize:uint = obj["dataSize"];
			
			var ErrorMessage:CMD_GQ_Login_Error = CMD_GQ_Login_Error.readData(bytes);
			if(GlobalDef.DEBUG)trace("in CMD_LoginAccountCmd recvFailInfo:ErrorMessage.lErrorCode = " + ErrorMessage.lErrorCode);
			if(GlobalDef.DEBUG)trace("in CMD_LoginAccountCmd recvFailInfo:ErrorMessage.szErrorDescribe = " + ErrorMessage.szErrorDescribe);
			//
			sendNotification(NotificationString.ALERT,ErrorMessage.szErrorDescribe);
		}
		private function recvLoginFinish():void{
			//登录完成----断开socket
			(facade.retrieveProxy(LoginClientSocketSinkProxy.NAME) as LoginClientSocketSinkProxy).close();
		}
	}
}