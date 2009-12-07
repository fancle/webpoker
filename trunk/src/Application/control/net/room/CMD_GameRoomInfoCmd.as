package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_GameRoomInfoCmd extends SimpleCommand implements ICommand
	{
		public function CMD_GameRoomInfoCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case CMD_DEF_ROOM.SUB_GQ_SERVER_INFO.toString():{
					//房间配置
					recvServerInfo(notification.getBody());
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_COLUMN_INFO.toString():{
					//列表配置
					recvColumnInfo(notification.getBody());
					break;
				}
				case CMD_DEF_ROOM.SUB_GQ_CONFIG_FINISH.toString():{
					//配置完成
					if(GlobalDef.DEBUG)trace("in CMD_GameRoomInfoCmd execute: config finish!!!\n");
					break;
				}
			}
		}
		
		private function recvServerInfo(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var serverInfo:CMD_GQ_ServerInfo = CMD_GQ_ServerInfo.readData(bytes);
			
			(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).setGameServerConfig(serverInfo);
			
			sendNotification(NotificationString.GAME_ROOM_INIT_DATA,serverInfo,"CMD_GQ_ServerInfo");
		}
		private function recvColumnInfo(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var columnInfo:CMD_GQ_ColumnInfo = CMD_GQ_ColumnInfo.readData(bytes);
			
			(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).setGameServerColumnInfo(columnInfo);
			
			sendNotification(NotificationString.GAME_ROOM_INIT_DATA,columnInfo,"CMD_GQ_ColumnInfo");
		}
	}
}