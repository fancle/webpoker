package Application.view.mediator.loaderpane
{
	import Application.NotificationString;
	import Application.view.componentView.loaderpane.loadPane;
	
	import common.data.GlobalDef;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LoaderPaneMediator extends Mediator implements IMediator
	{  
		public static const NAME:String = "LoaderPaneMediator";
	    private var _time:Timer = new Timer(GlobalDef.OVERTIME,1);//超时显示提示 让用户耐新等待
		public function LoaderPaneMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent;
		}
		public function get getLoadPane():loadPane{
			return viewComponent as loadPane;
		}
		override public function setViewComponent(viewComponent:Object):void
		{
			this.viewComponent = viewComponent;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			          NotificationString.LOAD_EVENT
			       ];
		}
		
		override public function handleNotification(notification:INotification):void
		{   
			 switch(notification.getName()){
			 	 case NotificationString.LOAD_EVENT:
			 	    switch(notification.getType()){
			 	    	case "0":  //开始加载播放动画 
			 	    	    _time.start(); 
			 	    	    getLoadPane.playMovie();
			 	         	break;
			 	    	case "2": //加载结束停止动画
			 	    	    _time.stop();			 	    	    
			 	    	    break;
			 	    }
			 	 break;
			 }
              
		}
		public function setProgress(value:Object):void{			
			getLoadPane.setProgress(value.bytesLoaded,value.bytesTotal);
		}
		public function setStatusText(value:String):void{
			getLoadPane.setStatues(value); 
		}
		private function timeComplete(evt:TimerEvent):void{
			getLoadPane.showWord();
		}
		override public function onRegister():void
		{
			   _time.addEventListener(TimerEvent.TIMER_COMPLETE,timeComplete);
		}
		
		override public function onRemove():void
		{
		}
		
	}
}