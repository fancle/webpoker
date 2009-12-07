package Application.model.game
{
	import Application.model.interfaces.IGameItem;
	import Application.model.interfaces.IServerItem;
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.model.vo.protocol.login.tagGameType;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;

	public class GameItem implements IGameItem
	{
		private var _gameKind:objGameKind;							//游戏类
		private var _arrGameServerList:Array = new Array;			//游戏下房间列表		
		private var _arrGameTypeDescription:Array = new Array;		//游戏类型描述列表
				
		public function GameItem()
		{
			_gameKind = new objGameKind;
		}
		
		public function setGameName(gameName:String):void{
			_gameKind.szGameName = gameName;
		}
		
		public function setGameType(gameType:tagGameType,gameID:uint):void{
			for each(var obj:objGameTypeDescription in _arrGameTypeDescription){
				if(obj.GameType == gameType){
					return;
				}
			}
			
			var gameTypeDescription:objGameTypeDescription = new objGameTypeDescription;
			gameTypeDescription.GameType = gameType;
			gameTypeDescription.wGameKindID = gameID;
			
			_arrGameTypeDescription.push(gameTypeDescription);
		}
		
		public function setGameOnLineCount(gameID:uint,onLineCount:uint):void{
			var _onLineCount:uint = 0;
			
			for each(var obj:objGameTypeDescription in _arrGameTypeDescription){
				if(obj.wGameKindID == gameID){
					obj.dwGameOnlineCount = onLineCount;
				}
				_onLineCount += obj.dwGameOnlineCount;
			}
			_gameKind.dwOnLineCount = _onLineCount;
		}
		
		public function setServerConfigInfo(serverInfo:CMD_GQ_ServerInfo):void{
			_gameKind.serverConfigInfo = serverInfo;
		}
		
		public function setServerColumnInfo(columnInfo:CMD_GQ_ColumnInfo):void
		{
			_gameKind.serverColumnInfo = columnInfo;
		}
		///////////////////////////////////////////////////////////
		public function addGameServerToList(_vGameServer:tagGameServer):IServerItem{
			var serverItem:ServerItem = new ServerItem;
			serverItem.gameServer = _vGameServer;
			
			_arrGameServerList.push(serverItem);
			
			return serverItem;
		}
				
		public function getGameName():String
		{
			if(_gameKind!=null){
				return _gameKind.szGameName;
			}
			return null;
		}
		
		public function getOnLineCount():uint
		{
			if(_gameKind){
				return _gameKind.dwOnLineCount;
			}
			return 0;
		}
		
		public function getServerItemByServerID(serverID:uint):IServerItem{
			for each(var serverItem:IServerItem in _arrGameServerList){
				if(serverItem.getServerID() == serverID){
					return serverItem;
				}
			}
			return null;
		}
		
		public function getServerListByTypeID(typeID:uint):Array
		{
			var kindID:uint;
			var arr:Array = new Array;
			
			for each(var gameTypeDescription:objGameTypeDescription in _arrGameTypeDescription){
				if(gameTypeDescription.GameType.wTypeID == typeID){
					kindID = gameTypeDescription.wGameKindID;
					break;
				}
			}
			for each(var _gameServer:IServerItem in _arrGameServerList){
				if(_gameServer.getGameID() == kindID){
					arr.push(_gameServer);
				}
			}
			return arr;
		}
		
		public function getServerListByTypeName(typeName:String):Array
		{
			var kindID:uint;
			var arr:Array = new Array;
			
			for each(var gameTypeDescription:objGameTypeDescription in _arrGameTypeDescription){
				if(gameTypeDescription.GameType.szTypeName == typeName){
					kindID = gameTypeDescription.wGameKindID;
					break;
				}
			}
			for each(var _gameServer:IServerItem in _arrGameServerList){
				if(_gameServer.getGameID() == kindID){
					arr.push(_gameServer);
				}
			}
			return arr;
		}
		
		public function getServerConfigInfo():CMD_GQ_ServerInfo{
			return _gameKind.serverConfigInfo;
		}
		
		public function getServerColumnInfo():CMD_GQ_ColumnInfo{
			return _gameKind.serverColumnInfo;
		}
		
		public function hasGameID(gameID:uint):Boolean{
			for each(var gameTypeDescription:objGameTypeDescription in _arrGameTypeDescription){
				if(gameTypeDescription.wGameKindID == gameID) return true;
			}
			return false
		}
	}
}