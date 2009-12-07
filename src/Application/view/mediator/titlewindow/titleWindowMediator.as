package Application.view.mediator.titlewindow
{
	import Application.view.componentView.titlewindow.titleWindow;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	public class titleWindowMediator extends Mediator implements IMediator
	{  
		public static const NAME:String = "titleWindowMediator";
		public function titleWindowMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
	
			
		}
		private function onClose(evt:CloseEvent):void{
		    if(getTitleWindow.isPopUp==true){		  
		    	PopUpManager.removePopUp(getTitleWindow);
		    }
		}
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent;
		}
		public function get getTitleWindow():titleWindow
		{
		    return viewComponent as titleWindow;	
		}
		override public function setViewComponent(viewComponent:Object):void
		{
		}
		
		override public function listNotificationInterests():Array
		{
			return [];
		}
		
		override public function handleNotification(notification:INotification):void
		{
		}
		
		override public function onRegister():void
		{
			getTitleWindow.addEventListener(CloseEvent.CLOSE,onClose);
		}
		
		override public function onRemove():void
		{
		}
		
	}
}