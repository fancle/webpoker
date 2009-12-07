package Application.control.login
{
	import Application.model.game.GameManagerProxy;
	import Application.view.mediator.hall.HallMediator;
	
	import common.assets.ModuleLib;
	
	import de.polygonal.ds.HashMap;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LogoutCmd extends SimpleCommand implements ICommand
	{   
		
		public function LogoutCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			(facade.retrieveMediator(HallMediator.NAME) as HallMediator).dispose();//清除界面
			(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).dispose();//清除数据
			(ModuleLib.getInstance().gameStage).logout((ModuleLib.getInstance().lib as HashMap).find("login"));
		}
		
	}
}