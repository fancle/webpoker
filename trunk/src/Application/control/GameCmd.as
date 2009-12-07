package Application.control
{
	import Application.NotificationString;
	import Application.model.ConfigProxy;
	import Application.view.mediator.GameMediator;
	
	import common.data.GlobalDef;
	import common.data.StringDef;
	
	import flash.display.DisplayObject;
	import flash.net.LocalConnection;
	
	import mx.events.ResizeEvent;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	public class GameCmd extends SimpleCommand implements ICommand
	{
		
		public function GameCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{		
			
			facade.registerMediator(new GameMediator(notification.getBody() as game));//注册外壳媒介
			
			facade.registerCommand(NotificationString.LOAD_CONFIG_COMPLETE,LoadStartCommand);//注册加载配置文件信息
			facade.registerProxy(new ConfigProxy);	
			(notification.getBody() as DisplayObject).addEventListener(ResizeEvent.RESIZE, onResizeHandle);//flash大小发生改变的侦听
		  	
		  	
		  	
		}
		

		private function onResizeHandle(evt:ResizeEvent):void {
			 sendNotification(NotificationString.RESIZE);
		}

	}
}