package Application.control
{
	import Application.model.load.LoaderProxy;
	
	import common.data.ContextConfig;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LoadStartCommand extends SimpleCommand implements ICommand
	{
		public function LoadStartCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			facade.registerProxy(new LoaderProxy);//注册加载类
			ContextConfig.getInstance().showContext();//设置右键
		}
		
	}
}