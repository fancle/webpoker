package Application.view.mediator
{
	import Application.NotificationString;
	import Application.control.net.room.CMD_RoomUserCmd;
	
	import com.adobe.crypto.MD5;
	
	import common.data.CMD_DEF_HALL;
	import common.data.GlobalDef;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class GameMediator extends Mediator implements IMediator
	{   
		public static const NAME:String = "GameMediator";	

		public function GameMediator( viewComponent:Object=null)
		{
			//TODO: implement function
			super(NAME, viewComponent);

		
		
		}

		//注册所需mediator、command、proxy等
		private function reg():void{
			
		}
		
		override public function getMediatorName():String
		{
			//TODO: implement function
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			//TODO: implement function
			return viewComponent;
		}
		public function get getGameComponent():game{
			return viewComponent as game
		}
		
		override public function setViewComponent(viewComponent:Object):void
		{   
			
			//TODO: implement function
		}
		
		override public function listNotificationInterests():Array
		{
			//TODO: implement function
			return [
			         NotificationString.LOAD_MODULE_COMPLETE,
			         NotificationString.SOCKET_CONNECTED
			       ];
		}
		
		override public function handleNotification(notification:INotification):void
		{   
			switch(notification.getName()){
				case NotificationString.LOAD_MODULE_COMPLETE:	  	      
				  //  getGameComponent.addChild((notification.getBody() as HashMap).find("login") as DisplayObject);				  
				  //  facade.registerMediator(new LoginMediator((notification.getBody() as HashMap).find("login") as DisplayObject));//登陆初始化	  
				  //  centerComponent((notification.getBody() as HashMap).find("login") as DisplayObject);//登陆框居中	
				  //这里需要直接进大厅
				   sendNotification(NotificationString.CONNECT_SOCKET,null,GlobalDef.SOCKETPROXY_LOGIN);//发出连接 登录socket 的通知
				    
				    //开始注册其他模块				 
				    break;
				case NotificationString.SOCKET_CONNECTED:
					var obj:Object=new Object;					
					obj.user_name= "tmp6008";  //InitData.getInstance().userName;				
					obj.password =  MD5.hash("ibm");//InitData.getInstance().passWord;//加密的
				  	facade.sendNotification(NotificationString.CMD_LOGIN_ACCOUNT,obj,CMD_DEF_HALL.SUB_GP_LOGON_ACCOUNT.toString());
				  	break;		
			}
			//TODO: implement function
		}
		override public function onRegister():void
		{
			//TODO: implement function
			getGameComponent.exitRoomBtn.addEventListener(MouseEvent.CLICK,exitRoom);
			getGameComponent.findChairBtn.addEventListener(MouseEvent.CLICK,findChair);
		}
		
		override public function onRemove():void
		{
			//TODO: implement function
		}
				//距中函数
		private function centerComponent(obj:DisplayObject):void{
			 obj.x = (getGameComponent.width- obj.width)/2;
			 obj.y = (getGameComponent.height-obj.height)/2; 
		}
		/**
		 * 
		 * @param evt 退出的鼠标事件
		 */
		private function exitRoom(evt:MouseEvent):void{
			sendNotification(NotificationString.EXIT_ROOM);
		}
		/**
		 * 自动找座
		 * @param evt
		 * 
		 */
		private function findChair(evt:MouseEvent):void
		{
			sendNotification(NotificationString.CMD_ROOM_USER,null,CMD_RoomUserCmd.USER_AUTOSIT);
		}
		// 游戏结束时释放资源，包括撤消注册 
		private function dispose():void{
			
		}
	}
}