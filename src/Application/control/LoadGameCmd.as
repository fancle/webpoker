package Application.control
{
	import Application.model.SingleGameProxy;
	
	import common.data.GameListConfig;
	import common.data.GameTypeConfig;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	public class LoadGameCmd extends SimpleCommand implements ICommand
	{

		public function LoadGameCmd()
		{
			super();
		}


		override public function execute(notification:INotification):void
		{
		
			if (!facade.hasProxy(SingleGameProxy.NAME))
			{
				facade.registerProxy(new SingleGameProxy);			
		
			}
			   var _gamename:String = GameTypeConfig.getInstance().getGameName(notification.getBody()["gamename"].toString());			 		
			   (facade.retrieveProxy(SingleGameProxy.NAME) as SingleGameProxy).setGame(GameListConfig.getInstance().getGameModule(_gamename),notification.getBody());

		}
	}
}