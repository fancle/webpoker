package Application.control.loaderpane
{
	import Application.view.mediator.GameMediator;
	import Application.view.mediator.loaderpane.LoaderPaneMediator;
	
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	public class LoaderPaneCmd extends SimpleCommand implements ICommand
	{   
		private var _loadPane:LoaderPaneMediator;
		private var _win:DisplayObject;
		public var _currentState:String;
      
		public function LoaderPaneCmd()
		{
			super();
			
	
				
		}
		//加载面板显示的操作
		override public function execute(notification:INotification):void
		{     
			 _loadPane = facade.retrieveMediator("LoaderPaneMediator") as LoaderPaneMediator;
			  switch(notification.getType()){
			  	  case "0":
			  	  	_win = (facade.retrieveMediator("GameMediator") as GameMediator).getGameComponent as DisplayObject//获取顶层对象		     		    
		     		PopUpManager.addPopUp((_loadPane.getLoadPane as  UIComponent),_win,true);//弹出加载框
		    		PopUpManager.centerPopUp((_loadPane.getLoadPane as  UIComponent));//弹出窗口居中
		    		_currentState = "0";
		    	  break;
		    	  case "1":
		    	      if((_loadPane.getLoadPane as  UIComponent).isPopUp==false){
		    	      		_win = (facade.retrieveMediator("GameMediator") as GameMediator).getGameComponent as DisplayObject
		    	      		PopUpManager.addPopUp((_loadPane.getLoadPane as  UIComponent),_win,true);//弹出加载框
		    				PopUpManager.centerPopUp((_loadPane.getLoadPane as  UIComponent));//弹出窗口居中
		    	      }
		    	      _loadPane.setProgress(notification.getBody());		    	     	      
		    	      _currentState = "1";
		    	      break;
		    	  case "2":		    	     
		    	      PopUpManager.removePopUp((_loadPane.getLoadPane as  UIComponent));//消除加载面板
		    	      _currentState = "2";
		    	      break;
		    	     
			  }

		}
		
	}
}