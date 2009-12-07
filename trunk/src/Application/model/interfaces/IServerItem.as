package Application.model.interfaces
{
	import Application.model.vo.protocol.login.tagGameServer;
	
	public interface IServerItem
	{
		function set gameServer(gameServer:tagGameServer):void;
		
		function getServerName():String;
		function getServerID():uint;
		function getGameID():uint;
		function getGameName():String;
		function getOnlineCount():uint;
		function getServerAddr():Object;
		function getServerPort():uint;
	}
}