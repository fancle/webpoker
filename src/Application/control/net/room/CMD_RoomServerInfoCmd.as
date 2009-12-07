package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IGameItem;
	import Application.model.vo.protocol.room.CMD_RoomServerInfo;
	
	import common.data.CMD_DEF_ROOM;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomServerInfoCmd extends SimpleCommand implements ICommand
	{
		public function CMD_RoomServerInfoCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			switch(notification.getType()){
				case CMD_DEF_ROOM.SUB_GR_ONLINE_COUNT_INFO.toString():{
					recvOnlineCount(notification.getBody());
					break;
				}
			}
		}
		
		private function recvOnlineCount(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var gameManager:GameManagerProxy = facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy;
			var pGameItem:IGameItem;
			
			for(var i:int = 0; i<wDataSize/CMD_RoomServerInfo.sizeof_CMD_RoomServerInfo; i++){
				var serverInfo:CMD_RoomServerInfo = CMD_RoomServerInfo.readData(bytes);
				pGameItem = gameManager.getGameItemByGameID(serverInfo.wKindID) as IGameItem;
				if(pGameItem) pGameItem.setGameOnLineCount(serverInfo.wKindID,serverInfo.dwOnLineCount);
			}
			
			var allOnlineCount:int = 0;
			var arr:Array = gameManager.getAllGame();
			for each(var p:IGameItem in arr){
				allOnlineCount += p.getOnLineCount();
			}
			
			sendNotification(NotificationString.UPDATE_ONLINECOUNT,allOnlineCount);
		}
		
	}
}