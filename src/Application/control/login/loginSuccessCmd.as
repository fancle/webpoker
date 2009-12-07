package Application.control.login
{
	
	import Application.view.mediator.GameMediator;
	import Application.view.mediator.hall.HallMediator;
	import Application.view.mediator.login.LoginMediator;
	
	import common.assets.ModuleLib;
	
	import de.polygonal.ds.HashMap;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class loginSuccessCmd extends SimpleCommand implements ICommand
	{
		private var _win:game;
		private var _hall:hall; 
		public function loginSuccessCmd()
		{
			super();

		   
		}
		
		override public function execute(notification:INotification):void
		{			
			 _win =((facade.retrieveMediator("GameMediator") as GameMediator).getGameComponent as game);
		    _hall = (ModuleLib.getInstance().lib as HashMap).find("hall") as hall;	
			 //(facade.retrieveMediator("LoginMediator") as LoginMediator).dispose();//登陆初始化；
			 _win.controlbar.visible = true;			 			
			 if(!(facade.hasMediator(HallMediator.NAME))){
			      facade.registerMediator(new HallMediator(_hall));//大厅初始化			    
			 }		
		   	_win.addModule(_hall);	
		}

		
	}
}