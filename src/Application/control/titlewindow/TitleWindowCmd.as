package Application.control.titlewindow
{
	
	import Application.view.componentView.titlewindow.titleWindow;
	import Application.view.mediator.titlewindow.titleWindowMediator;
	
	import common.assets.ModuleLib;
	
	import flash.display.LoaderInfo;
	
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TitleWindowCmd extends SimpleCommand implements ICommand
	{   
		private var  _winPop:titleWindow;
		private var  _win:hall;
		public function TitleWindowCmd()
		{
			super();

		}
		
		override public function execute(notification:INotification):void
		{
			_winPop = (facade.retrieveMediator("titleWindowMediator") as titleWindowMediator).getTitleWindow;
			_win = ModuleLib.getInstance().lib["hall"] as hall;
			switch(notification.getType()){
				case "0":
				    if(_winPop.isPopUp==false){
						PopUpManager.addPopUp(_winPop,_win);
						PopUpManager.centerPopUp(_winPop);						
						if(notification.getBody()!=null){
							_winPop.swfloader.load((notification.getBody() as LoaderInfo).content);						
						}
						
					}
				     break;
				case "1":
				     break;
			}
		}

		
	}
}