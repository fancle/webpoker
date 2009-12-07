package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.room.CMD_GQ_TableInfo;
	import Application.model.vo.protocol.room.CMD_GQ_TableStatus;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomTableCmd extends SimpleCommand implements ICommand
	{
		public static const TABLE_INFO:String = "table_info";
		public static const TABLE_STATUS:String = "table_status";
		
		public function CMD_RoomTableCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case CMD_DEF_ROOM.SUB_GQ_TABLE_INFO.toString():{
					recvTableInfo(notification.getBody());
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_TABLE_STATUS.toString():{
					recvTableStatus(notification.getBody());
					break;
				}
			}
		}
		
		private function recvTableInfo(obj:Object):void{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			
			var tableInfo:CMD_GQ_TableInfo = CMD_GQ_TableInfo.readData(bytes);
			
			//发送通知
			sendNotification(NotificationString.GAME_ROOM_DATA,tableInfo,TABLE_INFO);
		}
		
		private function recvTableStatus(obj:Object):void{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			
			var tableStatus:CMD_GQ_TableStatus = CMD_GQ_TableStatus.readData(bytes);
			
			//发送通知
			sendNotification(NotificationString.GAME_ROOM_DATA,tableStatus,TABLE_STATUS);
			if(GlobalDef.DEBUG)trace("in CMD_RoomTableCmd recvTableStatus: tableStatus.bPlayStatus " + tableStatus.bPlayStatus);
			
			if(facade.hasProxy(GameFrameProxy.NAME)){
				//frameTableStatusHandle(tableStatus);
			}	
		}
		private function frameTableStatusHandle(_tableStatus:CMD_GQ_TableStatus):void{
			var pMeUserItem:IUserItem = UserManager.getInstance().getMeItem();
			
			if(pMeUserItem.GetUserStatus().wTableID == _tableStatus.wTableID){
				//如果是当前所坐桌子状态
				var type:String=_tableStatus.bPlayStatus?"gameStart":"gameFinish";
				sendNotification(NotificationString.CMD_FRAME_USER,null,type);
			}
		}
	}
}