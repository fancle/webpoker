package Application.control.connect
{
	import Application.NotificationString;
	import Application.model.net.socket.LoginClientSocketSinkProxy;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	
	import common.data.GlobalDef;
	import common.data.HallConfig;
	
	import flash.utils.getTimer;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectSocketCmd extends SimpleCommand implements ICommand
	{
		public function ConnectSocketCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			//通知界面显示连接状态
			sendNotification(NotificationString.CONNECT_LOADING,null,"0");
			
			switch(notification.getType()){
				
				case GlobalDef.SOCKETPROXY_LOGIN:{
					facade.registerProxy(LoginClientSocketSinkProxy.getInstance(HallConfig.getInstance().getScoket("login")["host"],HallConfig.getInstance().getScoket("login")["port"]));
					(facade.retrieveProxy(LoginClientSocketSinkProxy.NAME) as LoginClientSocketSinkProxy).connect();
					break;
				}
				
				case GlobalDef.SOCKETPROXY_GAME:{
					//获得传过来的IP、Port
					var obj:Object = notification.getBody();
					var gameServerIP:String = obj["ip"];
					var gameserverPort:uint = obj["port"];
					if(GlobalDef.DEBUG)trace("in ConnectSocketCmd execute:房间IP及端口 = " + gameServerIP + ":" + gameserverPort);
					//取game Socket,建立连接
					facade.registerProxy(RoomClientSocketSinkProxy.getInstance(gameServerIP,gameserverPort));
					(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).connect();
					if(GlobalDef.DEBUG)trace("in ConnectSocketCmd execute: getTimer1 = " + getTimer());
					break;
				}
			}			
		}
		
	}
}