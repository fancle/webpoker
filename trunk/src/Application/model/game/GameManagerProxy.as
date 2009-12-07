package Application.model.game
{
	import Application.model.interfaces.IGameItem;
	import Application.model.interfaces.IGameManager;
	import Application.model.interfaces.IServerItem;
	import Application.model.vo.protocol.login.CMD_GQ_ListConfig;
	import Application.model.vo.protocol.login.tagGameKind;
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.model.vo.protocol.login.tagGameType;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class GameManagerProxy extends Proxy implements IProxy, IGameManager
	{
		public static const NAME:String = "GameManagerProxy";
		
		public static const gameType_xiuxian:String = "休闲游戏";
		public static const gameType_jingji:String = "竞技游戏";
		public static const gameKind_doudizhu:String = "斗地主";
		public static const gameKind_majiang:String = "二人麻将";
		
		private var _listConfig:CMD_GQ_ListConfig;
		private var _arrGameTypeList:Array = new Array;
		private var _arrGameKindList:Array = new Array;
		private var _currentGameItem:IGameItem;//当前游戏
		private var _currentServerItem:IServerItem;//当前房间
		private var _currentServerID:int;//当前房间ID
		
		public function GameManagerProxy(proxyName:String=null, data:Object=null)
		{
			super(NAME, data);
		}
		
		override public function getProxyName():String
		{
			return NAME;
		}
		
		override public function setData(data:Object):void
		{
		}
		
		override public function getData():Object
		{
			return null;
		}
		
		override public function onRegister():void
		{
		}
		
		override public function onRemove():void
		{
		}
		////////////////////////////////////////////////////////////////
		public function setListConfig(listConfig:CMD_GQ_ListConfig):void{
			_listConfig = listConfig;
		}
		
		public function addGameTypeToList(gameType:tagGameType):void{
			
			_arrGameTypeList.push(gameType);
		}
		
		public function addGameKindToList(_vGameKind:tagGameKind):IGameItem{
			var pGameItem:IGameItem;
			
			if(_vGameKind.szKindName.indexOf(gameKind_doudizhu,0)>-1){
				//如果游戏是斗地主游戏
				if(getGameItemByGameName(gameKind_doudizhu)==null){
					pGameItem = new GameItem;
					pGameItem.setGameName(gameKind_doudizhu);
					
					pGameItem.setGameType(getGameTypeByTypeID(_vGameKind.wTypeID) as tagGameType,_vGameKind.wKindID);
					pGameItem.setGameOnLineCount(_vGameKind.wKindID,_vGameKind.dwOnLineCount);
					
					_arrGameKindList.push(pGameItem);	
				}
				else {
					pGameItem = getGameItemByGameName(gameKind_doudizhu);
					
					pGameItem.setGameType(getGameTypeByTypeID(_vGameKind.wTypeID) as tagGameType,_vGameKind.wKindID);
					pGameItem.setGameOnLineCount(_vGameKind.wKindID,_vGameKind.dwOnLineCount);
				}
			}
			else if(_vGameKind.szKindName.indexOf(gameKind_majiang,0)>-1){
				//如果游戏为麻将游戏
				if(getGameItemByGameName(gameKind_majiang)==null){
					pGameItem = new GameItem;
					pGameItem.setGameName(gameKind_majiang);
					
					pGameItem.setGameType(getGameTypeByTypeID(_vGameKind.wTypeID) as tagGameType,_vGameKind.wKindID);
					pGameItem.setGameOnLineCount(_vGameKind.wKindID,_vGameKind.dwOnLineCount);
					
					_arrGameKindList.push(pGameItem);
				}
				else{
					pGameItem = getGameItemByGameName(gameKind_majiang);
					
					pGameItem.setGameType(getGameTypeByTypeID(_vGameKind.wTypeID) as tagGameType,_vGameKind.wKindID);
					pGameItem.setGameOnLineCount(_vGameKind.wKindID,_vGameKind.dwOnLineCount);
				}
			}
			return 	pGameItem;
		}
		
		public function addGameServerToList(_vGameServer:tagGameServer):IServerItem{
			var pGameItem:IGameItem = getGameItemByGameID(_vGameServer.wKindID);
			if(pGameItem) return pGameItem.addGameServerToList(_vGameServer);
			
			return null;
		}
		
		/**
		 * 添加房间配置信息 
		 * @param gameID
		 * @param serverInfo
		 * 
		 */
		public function setGameServerConfig(serverInfo:CMD_GQ_ServerInfo):void{
			if(_currentGameItem){
				_currentGameItem.setServerConfigInfo(serverInfo);
			} 
		}
		
		public function setGameServerColumnInfo(columnInfo:CMD_GQ_ColumnInfo):void{
			if(_currentGameItem){
				_currentGameItem.setServerColumnInfo(columnInfo);
			} 
		}
		
		public function setCurrentServerItem(serverItem:IServerItem):void{
			if(serverItem){
				_currentServerItem = serverItem;
				_currentGameItem = getGameItemByGameID(serverItem.getGameID());
			} 
		}
		
		public function exitServer():void{
			if(_currentGameItem){
				_currentGameItem.setServerConfigInfo(null);
				_currentGameItem = null;
				_currentServerItem = null;
				_currentServerID = -1;
			}
		}
		
		public function getAllGame():Array
		{
			
			return _arrGameKindList;
		}
		
		public function getGameItemByGameID(gameID:uint):IGameItem
		{
			for each(var item:IGameItem in _arrGameKindList){
				if(item.hasGameID(gameID)){
					return item;
				}
			}
			
			return null;
		}
		
		public function getGameItemByGameName(gameName:String):IGameItem
		{
			for each(var item:IGameItem in _arrGameKindList){
				if(item.getGameName() == gameName){
					return item;
				}
			}
			return null;
		}
		
		public function getCurrentGameItem():IGameItem{
			return _currentGameItem;
		}
		
		public function getCurrentServerItem():IServerItem{
			return _currentServerItem;
		}
		///////////////////////////////////////////////////////////////////////
		private function getGameTypeByTypeID(typeID:uint):tagGameType{
			for each(var gameType:tagGameType in _arrGameTypeList){
				if(gameType.wTypeID == typeID){
					return gameType;
				}
			}
			return null;
		}
		
		
		////////////////////////////////////////////////////////////////
		
		public function dispose():void{
			_arrGameTypeList.splice(0,_arrGameTypeList.length);
			_arrGameKindList.splice(0,_arrGameKindList.length);
		}
	}
}