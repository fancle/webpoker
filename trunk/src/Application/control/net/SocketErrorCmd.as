package Application.control.net
{
	import Application.NotificationString;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SocketErrorCmd extends SimpleCommand implements ICommand
	{
		public function SocketErrorCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			sendNotification(NotificationString.CONNECT_LOADING,null,"1");
			switch(notification.getType()){
				case "0":{
					trace("in SocketErrorCmd excute: SecurityError/IOError");
					sendNotification(NotificationString.ALERT,"连接错误");
					break;
				}
				case "1":{
					trace("in SocketErrorCmd excute: socketConnectTimeout");
					sendNotification(NotificationString.ALERT,"连接超时");
					break;
				}
			}
		}
		
	}
}