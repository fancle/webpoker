package Application.model.game
{
	import Application.model.interfaces.IServerItem;
	import Application.model.vo.protocol.login.tagGameServer;
	import Application.utils.GameUtil;
	
	import common.data.GlobalDef;
	
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ServerItem implements IServerItem
	{
		private var _gameServer:tagGameServer;
		
		public function set gameServer(_vGameServer:tagGameServer):void{
			_gameServer = _vGameServer;
		}
		
		public function ServerItem()
		{
		}

		public function getServerName():String
		{
			return _gameServer.szServerName;
		}
		
		public function getServerID():uint
		{
			return _gameServer.wServerID;
		}
		
		public function getGameID():uint
		{
			return _gameServer.wKindID;
		}
		
		public function getGameName():String
		{
			return (Facade.getInstance(GlobalDef.GAME_FACADE).retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getGameItemByGameID(_gameServer.wKindID).getGameName();
		}
		
		public function getOnlineCount():uint
		{
			return _gameServer.dwOnLineCount;
		}
		
		public function getServerAddr():Object
		{
			var obj:Object = new Object;
			obj["ip"] = GameUtil.convertIPToString(_gameServer.dwServerAddr);
			obj["port"] = getServerPort();
			
			return obj;
		}
		
		public function getServerPort():uint
		{
			return _gameServer.wServerPort;
		}
		
	}
}