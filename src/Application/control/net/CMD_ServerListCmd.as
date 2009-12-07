package Application.control.net
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IGameItem;
	import Application.model.vo.protocol.login.CMD_GQ_ListConfig;
	import Application.model.vo.protocol.login.tagGameKind;
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.model.vo.protocol.login.tagGameType;
	
	import common.data.CMD_DEF_HALL;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_ServerListCmd extends SimpleCommand implements ICommand
	{
		public function CMD_ServerListCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var type:String = notification.getType();
			var obj:Object = notification.getBody();
			
			switch(type){
				case CMD_DEF_HALL.SUB_GQ_LIST_TYPE.toString():{
					//游戏类型列表
					recvListType(obj);
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LIST_KIND.toString():{
					//游戏种类列表
					recvListKind(obj);
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LIST_STATION.toString():{
					//站点列表
					
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LIST_SERVER.toString():{
					//游戏房间列表
					recvListServer(obj);
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LIST_FINISH.toString():{
					//发送完成
					recvListFinish(obj);
					break;
				}
				case CMD_DEF_HALL.SUB_GQ_LIST_CONFIG.toString():{
					//列表配置---是否显示人数
					recvListConfig(obj);
					break;
				}
			} 
		}
		
		private function recvListFinish(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			
			sendNotification(NotificationString.LOGIN_SUCCESS);
						
			var gameManager:GameManagerProxy = facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy;
			var pGameItem:IGameItem;
			var allOnlineCount:int = 0;
			var arr:Array = gameManager.getAllGame();
			for each(var p:IGameItem in arr){
				allOnlineCount += p.getOnLineCount();
			}
			sendNotification(NotificationString.UPDATE_ONLINECOUNT,allOnlineCount);
		}
		
		private function recvListConfig(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			
			var gameListConfig:CMD_GQ_ListConfig = CMD_GQ_ListConfig.readData(bytes);
			
			(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).setListConfig(gameListConfig);
		}
		
		private function recvListType(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var arrGameType:Array=new Array;
			var wItemCount:int = wDataSize/tagGameType.sizeof_tagGameType;
			for(var i:int=0;i<wItemCount;i++){
				var gameType:tagGameType = tagGameType.readData(bytes);		
				if(GlobalDef.DEBUG)trace("in CMD_serverListCmd recvListType: gameType = " + gameType.wTypeID + ":" + gameType.szTypeName);
				(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).addGameTypeToList(gameType);
			}
			
		}
		
		private function recvListKind(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var wDataSize:int = obj["dataSize"];
			
			var arrGameKind:Array=new Array;
			
			var wItemCount:int = wDataSize/tagGameKind.sizeof_tagGameKind;
			for(var i:int=0;i<wItemCount;i++){
				var gameKind:tagGameKind = tagGameKind.readData(bytes);	
				if(GlobalDef.DEBUG)trace("in CMD_serverListCmd recvListKind: gameKindInfo = " + gameKind.wKindID + ":" + gameKind.szKindName + ":" + gameKind.wTypeID);
				(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).addGameKindToList(gameKind);
			}
		}
		
		private function recvListServer(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			
			var wDataSize:int = obj["dataSize"];
			
			var arrGameServer:Array=new Array;
			
			var wItemCount:int = wDataSize/tagGameServer.sizeof_tagGameServer;
			for(var i:int=0;i<wItemCount;i++){
				var gameServer:tagGameServer = tagGameServer.readData(bytes);
				if(GlobalDef.DEBUG)trace("in CMD_serverListCmd recvListServer: gameServer = " + gameServer.wServerID + ":" + gameServer.szServerName + ":" + gameServer.wKindID + ":" + gameServer.wServerPort);
				(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).addGameServerToList(gameServer);
			}
		}
	}
}