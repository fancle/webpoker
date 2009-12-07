package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.vo.protocol.common.tagMessageBody;
	import Application.model.vo.protocol.room.CMD_GQ_Message;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomMessageCmd extends SimpleCommand implements ICommand
	{
		public function CMD_RoomMessageCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch (notification.getType())
			{
				case CMD_DEF_ROOM.SUB_GQ_MESSAGE.toString():{
					recvMessage(notification.getBody());
					break;
				}				
			}
		}
		
		private function recvMessage(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var message:CMD_GQ_Message = CMD_GQ_Message.readData(bytes);
			
			if(GlobalDef.DEBUG)trace("in CMD_RoomMessageCmd execute: message.wMessageType = " + message.wMessageType);
			if(GlobalDef.DEBUG)trace("in CMD_RoomMessageCmd execute: message.szContent = " + message.szContent);
			
			if(message.wMessageType & (GlobalDef.SMT_INFO|GlobalDef.SMT_GLOBAL)){
				//信息消息|全局消息
				var obj:Object = new Object;
				obj["color"] = 0x00ff0000;
				obj["sendUserName"] = "系统消息";
				obj["chatMessage"] =  message.szContent;
				sendNotification(NotificationString.CHAT_INPUT,obj);
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
			if(message.wMessageType & GlobalDef.SMT_CLOSE_ROOM){
				//关闭房间
				var objClose:Object = new Object;
				objClose["closeHandler"] = socketCloseHandle;
				objClose["type"] = "1";
				objClose["text"]= "您已经掉线，请重新进入房间！";
				
				sendNotification(NotificationString.ALERT,objClose,"0");
				
				(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).close();
			}
			if(message.wMessageType & GlobalDef.SMT_INTERMIT_LINE){
				//中断连接
				
			}			
			
		}
		/////////////////////////////////////////////////////////////////////////////
		public function socketCloseHandle(evt:Event = null):void{
			sendNotification(NotificationString.CMD_GAME_ROOM,null,CMD_GameRoomCmd.ROOM_SOCKET_CLOSE);
		}
	}
}