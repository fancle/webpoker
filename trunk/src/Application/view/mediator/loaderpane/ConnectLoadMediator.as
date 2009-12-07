package Application.view.mediator.loaderpane
{
	import Application.NotificationString;
	import Application.view.componentView.loaderpane.connectLoad;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ConnectLoadMediator extends Mediator implements IMediator
	{   
		public static  const  NAME:String = "ConnectLoadMediator";
		public function ConnectLoadMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		public function  getConnectLoad():connectLoad{			
			return viewComponent as connectLoad;
		}
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent;
		}
		override public function setViewComponent(viewComponent:Object):void
		{
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			          NotificationString.CONNECT_LOADING  
			       ];
		}
		
		override public function handleNotification(notification:INotification):void
		{        //从通知体中获取内容
			     switch(notification.getName()){
			     	 case NotificationString.CONNECT_LOADING:
			     	 getConnectLoad().progressbar.label = ((notification.getBody() as String)== null)?"正在连接服务器":notification.getBody() as String;
			     	 break;
			     }
		}
		override public function onRegister():void
		{
		}
		
		override public function onRemove():void
		{
		}
		
	}
}