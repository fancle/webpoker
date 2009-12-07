package Application.control.net.gameFrame
{
	import Application.NotificationString;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.gameFrame.IPC_UserStatus;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.CMD_GR_UserChat;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.IPC_DEF;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_FrameUserCmd extends SimpleCommand implements ICommand
	{
		
		public function CMD_FrameUserCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case CMD_DEF_ROOM.SUB_GF_USER_CHAT.toString():	//游戏中的聊天
				{
					userChatHandle(notification.getBody());
					break;
				}
				case "userCome":
				{
					userComeHandle(notification.getBody() as tagUserData);
					break;
				}
				case "userStatus":								//当前桌上玩家状态改变
				{
					userStatusHandle(notification.getBody() as IPC_UserStatus);
					break;
				}
				case "gameStart":
				{
					gameStartHandle();
					break;
				}
				case "gameFinish":
				{
					gameFinishHandle();
					break;
				}
			}
		}
		
		public function userChatHandle(obj:Object):void{
			//发送信息
			if(obj.hasOwnProperty("send")){
				var userChatSendMessage:CMD_GR_UserChat = new CMD_GR_UserChat;
				//填写属性
				userChatSendMessage.crFontColor = uint(obj["color"]);
				userChatSendMessage.dwSendUserID = tagGlobalUserData.dwUserID;
				userChatSendMessage.dwTargetUserID = uint(obj["targetUserID"]);
				userChatSendMessage.szChatMessage = obj["chatMessage"];
				
				var strBytes:ByteArray = new ByteArray;
				strBytes.writeUTFBytes(String(obj["chatMessage"]));
				
				userChatSendMessage.wChatLength = strBytes.length;
				
				var bytes:ByteArray = userChatSendMessage.toByteArray();
				
				(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(CMD_DEF_ROOM.MDM_GF_FRAME,CMD_DEF_ROOM.SUB_GF_USER_CHAT,bytes,CMD_GR_UserChat.sizeof_Head_CMD_GR_UserChat+strBytes.length);				
			}
			//接收信息
			else{
				var dataBuffer:ByteArray = obj["dataBuffer"];
				var dataSize:int = obj["dataSize"];
				
				var userChatMessage:CMD_GR_UserChat = CMD_GR_UserChat.readData(dataBuffer);
				
				var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(userChatMessage.dwSendUserID);
				var sendUserName:String = pUserItem.GetUserName();
				
				pUserItem = UserManager.getInstance().SearchUserByUserID(userChatMessage.dwTargetUserID);
				if(pUserItem){
					var targetUserName:String = pUserItem.GetUserName();
				}			
				
				var recvObj:Object = new Object;
				recvObj["color"] = userChatMessage.crFontColor;
				recvObj["sendUser"] = userChatMessage.dwSendUserID + "|" + sendUserName;
				recvObj["targetUser"] = userChatMessage.dwTargetUserID + "|" + targetUserName;
				recvObj["chatMessage"] = userChatMessage.szChatMessage;
				recvObj["sendUserName"] = sendUserName;
				//接收到公共消息
				
				sendNotification(NotificationString.GAME_CHAT_INPUT,recvObj);
				
				
			}
		}
		
		private function userComeHandle(userData:tagUserData):void{
			(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_USER,IPC_DEF.IPC_SUB_USER_COME,userData,tagUserData.sizeof_tagUserData);
		}
		private function userStatusHandle(userStatus:IPC_UserStatus):void
		{
			//发送信道消息
			(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_USER,IPC_DEF.IPC_SUB_USER_STATUS,userStatus,tagUserStatus.sizeof_tagUserStatus);
		}
		private function gameStartHandle():void{
			(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_USER,IPC_DEF.IPC_SUB_GAME_START,null,0);
		}
		private function gameFinishHandle():void{
			(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_USER,IPC_DEF.IPC_SUB_GAME_FINISH,null,0);
		}
	}
}