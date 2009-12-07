package Application.model.interfaces
{
	import Application.model.vo.protocol.login.tagGameKind;
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.model.vo.protocol.login.tagGameType;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	
	public interface IGameManager
	{
		function addGameTypeToList(gameType:tagGameType):void;
		function addGameKindToList(gameKind:tagGameKind):IGameItem;
		function addGameServerToList(gameServer:tagGameServer):IServerItem;
		function setGameServerConfig(serverInfo:CMD_GQ_ServerInfo):void;
		function setCurrentServerItem(serverItem:IServerItem):void;
		
		function getAllGame():Array;//获得所有游戏
		function getGameItemByGameID(gameID:uint):IGameItem;//根据游戏ID取得游戏
		function getGameItemByGameName(gameName:String):IGameItem;//根据游戏名称取得游戏
		function getCurrentGameItem():IGameItem;
		function getCurrentServerItem():IServerItem;
		function exitServer():void;//离开房间
	}
}