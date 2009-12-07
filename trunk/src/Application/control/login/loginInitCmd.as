package Application.control.login
{
	import mx.modules.IModuleInfo;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	public class loginInitCmd extends SimpleCommand implements ICommand
	{  
		private var _login:IModuleInfo;
		public function loginInitCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{   			

		}

		
	}
}