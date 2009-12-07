/**
 * 
 * 处理框架启动、结束及初始化等信息
 * 
 */
package Application.control.net.gameFrame
{
	import Application.NotificationString;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IPropertyItem;
	import Application.model.present.PresentManager;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.common.tagMessageBody;
	import Application.model.vo.protocol.gameFrame.CMD_GF_MatchMessage;
	import Application.model.vo.protocol.gameFrame.IPC_Property;
	import Application.model.vo.protocol.room.CMD_GF_GiftNotify;
	import Application.model.vo.protocol.room.CMD_GQ_Message;
	import Application.model.vo.protocol.room.tagUserData;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.IPC_DEF;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomGameFrameCmd extends SimpleCommand implements ICommand
	{
		public function CMD_RoomGameFrameCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case "regist":		//注册
				{
					var gameName:String = notification.getBody() as String;
					if(!facade.hasProxy(GameFrameProxy.NAME)){
						facade.registerProxy(new GameFrameProxy(null,gameName));
					}
					
					break;
				}
				case "remove":		//移除----结束游戏
				{
					if(facade.hasProxy(GameFrameProxy.NAME)){
						facade.removeProxy(GameFrameProxy.NAME);
					}
					break;
				}
				case "message":
				{
					recvMessage(notification.getBody());
					break;
				}
				case CMD_DEF_ROOM.SUB_GF_MATCHMESSAGE.toString():
				case "matchMessage":	//奖状弹出消息
				{
					recvMatchMessage(notification.getBody());
					break;
				}
				case "property":				//道具信息
				{
					recvProperty(notification.getBody() as ByteArray);
					break;
				}				
				case "closeGameClient":		//关闭游戏客户端
				{
					closeGameClient(notification.getBody());
					break;
				}
			}
		}
		
		private function recvMessage(obj:Object):void{
			var dataBuffer:ByteArray = obj["dataBuffer"];
			var dataSize:int = obj["dataSize"];
			
			var message:CMD_GQ_Message = CMD_GQ_Message.readData(dataBuffer);
			
			if(message.wMessageType&GlobalDef.SMT_GAME_MATCH_CLOSE){
				var msgObj:Object = new Object;
				msgObj["message"] = message.szContent;
				msgObj["timeDelay"] = 3000;
				sendNotification(NotificationString.MSG_GAMEFRAME,msgObj);
			}
			if(message.wMessageType&GlobalDef.SMT_GAME_MATCH){
				var msgObj:Object = new Object;
				msgObj["message"] = message.szContent;
				msgObj["timeDelay"] = -1;
				sendNotification(NotificationString.MSG_GAMEFRAME,msgObj);
			}
			
			if(message.wMessageType&(GlobalDef.SMT_INFO|GlobalDef.SMT_GLOBAL)){
				var recvObj:Object = new Object;
				recvObj["color"] = 0x00ff00;
				recvObj["sendUser"] = 0 + "|" + "系统消息";
				recvObj["targetUser"] = "";
				recvObj["chatMessage"] = message.szContent;
				recvObj["sendUserName"] = "系统消息";
				//接收到公共消息
				if(GlobalDef.DEBUG)trace("^^^^^^^^^^^^^^in CMD_RoomGameFrameCmd recvMessage:message.wMessageType = " + message.wMessageType);
				sendNotification(NotificationString.GAME_CHAT_INPUT,recvObj);	
			}
			if(message.wMessageType & GlobalDef.SMT_CLOSE_ROOM){
				//关闭房间
				var messageBody:tagMessageBody = new tagMessageBody;
				messageBody.text = message.szContent;
				messageBody.type = "1";
				messageBody.title = "提示";
				messageBody.closeHandler = closeGameClient;
				
				sendNotification(NotificationString.ALERT,messageBody,"0");
				return;
			}
			if(message.wMessageType & GlobalDef.SMT_EJECT){
				//弹出消息
				var messageBody:tagMessageBody = new tagMessageBody;
				messageBody.text = message.szContent;
				messageBody.type = "1";
				messageBody.title = "提示";
				messageBody.closeHandler = null;
				
				sendNotification(NotificationString.ALERT,messageBody,"0");
			}			
			
		}
		/**
		 * 奖状消息
		 * @param obj
		 * 
		 */
		private function recvMatchMessage(obj:Object):void
		{
			var pBuffer:ByteArray = obj["dataBuffer"] as ByteArray;
			var wDataSize:int = obj["dataSize"] as int;
			
			var cmd:CMD_GF_MatchMessage = CMD_GF_MatchMessage.readData(pBuffer);
			
			var _date:Date = new Date;
			var obj:Object = new Object;
			obj["userName"] = cmd.varszNickName.toString();
			obj["roomName"] = cmd.varszGameRoomName.toString();
			obj["rank"] = cmd.dwMatchRank.toString();
			obj["honour"] = cmd.vardwMatchRY.toString();
			obj["UD"] = cmd.vardwMatchUD.toString();
			obj["date"] = _date.fullYear.toString() + "-" + _date.month.toString() + "-" + _date.date + "  " + _date.toLocaleTimeString();
			
			sendNotification(NotificationString.MSG_MATCHOVER,obj);			
		}
		/**
		 * 收到道具信息
		 * @param obj
		 * 
		 */
		private function recvProperty(bytes:ByteArray):void
		{
			var cmd:CMD_GF_GiftNotify = CMD_GF_GiftNotify.readData(bytes);
			
			//修改道具数量、施用者U豆、作用者魅力等属性值
			var _property:IPropertyItem = PresentManager.getInstance().getPropertyByID(cmd.wGiftID);
			_property.setPropertyCount(cmd.WSenderFlowerCount);
			
			var pUser:tagUserData = UserManager.getInstance().SearchUserByUserID(cmd.dwRcvUserID).GetUserData();
			pUser.lLoveliness = cmd.WRecverLoveliness;
			
			var sUser:tagUserData = UserManager.getInstance().SearchUserByUserID(cmd.dwSendUserID).GetUserData();
			sUser.lGameGold = cmd.WSenderGameGoldCount;
			
			var objR:Object = new Object;
			objR["userNowStatus"] = objR["userPreStatus"] = UserManager.getInstance().SearchUserByUserID(cmd.dwRcvUserID).GetUserStatus();
			var objS:Object = new Object;
			objS["userNowStatus"] = objS["userPreStatus"] = UserManager.getInstance().SearchUserByUserID(cmd.dwSendUserID).GetUserStatus();
			
			sendNotification(NotificationString.GAME_ROOM_DATA, objR, "user_status");
			sendNotification(NotificationString.GAME_ROOM_DATA, objS, "user_status");
			
			//
			var p:IPC_Property = new IPC_Property;
			p.userID = cmd.dwRcvUserID;
			p.propertyID = cmd.wGiftID;
			
			//构造一个Object，交给游戏去处理坐标的问题
			(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).sendIPCChannelMessage(IPC_DEF.IPC_MAIN_PROPERTY,IPC_DEF.IPC_SUB_PROPERTY_RECV,p,0);
			
		}
		/**
		 * 通知游戏端开始关闭游戏---即游戏端GameBaseClient.SendEventExitGameClient()
		 * 
		 */
		private function closeGameClient(obj:Object=null):void{
			var gameFrameProxy:GameFrameProxy = facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy;
			if(gameFrameProxy){
				gameFrameProxy.sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONTROL,IPC_DEF.IPC_SUB_CLOSE_GAMECLIENT,obj,0);
			}
			else{
				//发送关闭框架通知
				var obj:Object = new Object;
				obj.messageCode = 2;//没有gameFrameProxy说明只有框架没有GameClass,说明是在比赛场，不允许进房间，所以强退到大厅
				
				sendNotification(NotificationString.CMD_GAME_FRAME,obj,"exitFrame");
			}
		}
	}
}