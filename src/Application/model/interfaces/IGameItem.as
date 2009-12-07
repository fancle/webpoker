package Application.model.interfaces
{
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.model.vo.protocol.login.tagGameType;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	
	public interface IGameItem
	{
		function setGameName(gameName:String):void
		function setGameType(gameTypeID:tagGameType,gameID:uint):void
		function setGameOnLineCount(gameID:uint,onLineCount:uint):void
		function setServerConfigInfo(serverInfo:CMD_GQ_ServerInfo):void;
		function setServerColumnInfo(columnInfo:CMD_GQ_ColumnInfo):void;
		
		function addGameServerToList(gameServer:tagGameServer):IServerItem;
		
		function hasGameID(gameID:uint):Boolean;
		function getGameName():String;
		function getOnLineCount():uint;
		function getServerListByTypeID(typeID:uint):Array;
		function getServerListByTypeName(typeName:String):Array;
		function getServerConfigInfo():CMD_GQ_ServerInfo;
		function getServerColumnInfo():CMD_GQ_ColumnInfo
		function getServerItemByServerID(serverID:uint):IServerItem;
	}
}