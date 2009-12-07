package Application.control.alert
{
	import Application.view.mediator.GameMediator;
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	
	import mx.controls.Alert;
	import mx.core.IUITextField;
	import mx.core.mx_internal;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class AlertCmd extends SimpleCommand implements ICommand
	{   
		private var _win:Sprite;
		private var _glow:GlowFilter =  new GlowFilter(0xFFFFFF,1,10,10,5);
		private var alert:Alert;
		
		public function AlertCmd()
		{
			super();
			
		}
		
		override public function execute(notification:INotification):void
		{    
			_win = (facade.retrieveMediator("GameMediator") as GameMediator).getGameComponent as Sprite
		     Alert.okLabel = "退出";
		     Alert.cancelLabel = "取消";
		     
		     var strText:String;
		     
		     switch(notification.getType()){
		     	     case "0":		     	    	 
		     		  	  var str:string;
		     		  	  switch(notification.getBody()["type"]){
		     		  	  	case "0":{ //确定 取消
		     		  	  		str = Alert.OK|Alert.CANCEL;
		     		  	  		break;
		     		  	  	}
		     		  	  	case "1":{ //确定
		     		  	  		str= Alert.OK;
		     		  	  		break;
		     		  	  	}
		     		  	  }
		     		  	  strText = notification.getBody()["text"];
		     		  	  alert = Alert.show(strText,(notification.getBody()["title"]),str,_win,(notification.getBody()["closeHandler"]));					      
					      break;
					 default :
					     strText = notification.getBody() as String;
					     alert = Alert.show(strText,"提示",Alert.OK,_win);
					     
		     }
		     alert.filters = [_glow];
			var tf:IUITextField = alert.mx_internal::alertForm.mx_internal::textField; 
			tf.selectable = true;
			tf.autoSize = TextFieldAutoSize.CENTER; 
			tf.htmlText = strText;
		}
		
	}
}