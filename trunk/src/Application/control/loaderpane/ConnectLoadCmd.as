package Application.control.loaderpane
{
	import Application.view.mediator.GameMediator;
	import Application.view.mediator.loaderpane.ConnectLoadMediator;
	
	import flash.display.DisplayObject;
	
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectLoadCmd extends SimpleCommand implements ICommand
	{   
	    private var _win:DisplayObject;
	    private var _connectPane:ConnectLoadMediator;
		public function ConnectLoadCmd()
		{
			super();
			
		}
		
		override public function execute(notification:INotification):void
		{
			_connectPane = facade.retrieveMediator("ConnectLoadMediator") as ConnectLoadMediator;
			switch(notification.getType()){
				//显示
				case "0": 
				    if(notification.getBody()!=null){
				    	_connectPane
				    }
	                 _win = (facade.retrieveMediator("GameMediator") as GameMediator).getGameComponent as DisplayObject//获取顶层对象				    				       		    
		     		PopUpManager.addPopUp((_connectPane.getConnectLoad() as   IFlexDisplayObject),_win,true,PopUpManagerChildList.POPUP );//弹出加载框
		    		PopUpManager.centerPopUp((_connectPane.getConnectLoad()as  IFlexDisplayObject));//弹出窗口居中
				break;
				//删除
				case "1":
				     PopUpManager.removePopUp((_connectPane.getConnectLoad()as  IFlexDisplayObject));
				     break;
				    
			}
				
			
		}
		
	}
}