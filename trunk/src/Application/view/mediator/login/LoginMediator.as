package Application.view.mediator.login
{
	import Application.NotificationString;
	import Application.model.io.LocalData;
	import Application.utils.GameUtil;
	
	import com.adobe.crypto.MD5;
	
	import common.data.CMD_DEF_HALL;
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.HallConfig;
	import common.data.StringDef;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LoginMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LoginMediator";
		private var _userNameArray:Array = new Array();
		public function LoginMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);

		}
		private  function init():void{
			componet.extraWordText.text = extraRadom();
			if(((LocalData.getInstance().getObject("username")) as Array)==null){
				return;
			}
		    componet.username.dataProvider =   ((LocalData.getInstance().getObject("username")) as Array).reverse();
		    _userNameArray = ((LocalData.getInstance().getObject("username")) as Array).reverse();
		}
		private function registerHandle(evt:MouseEvent):void{
			GameUtil.webLink(HallConfig.getInstance().getLink("register")["url"]);		
		}
		private function chargHandle(evt:MouseEvent):void{
			GameUtil.webLink(HallConfig.getInstance().getLink("charge")["url"]);
		}
		public function dispose():void{
			componet.extraWord.text="";
			componet.password.text="";
			componet.extraWordText.text = extraRadom();
			componet.extraWord.removeEventListener(FlexEvent.ENTER,loginHandle);
		}
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent ;
		}
	    public function get componet():LoginModule{
	    	return viewComponent as LoginModule;
	    }
	    //产生随机码
	    private function extraRadom():String{
	    	var tempR:String="";
	    	for(var index:int = 0; index<4;index++){
	    		tempR+= int((Math.random()*10)).toString();
	    		
	    	}
	    	return tempR
	        
	    }
		//单击登陆按钮
		private function loginHandle(evt:Event):void{
			
/* 			 if(componet.username.text==""||componet.password.text==""){
			 	  sendNotification(NotificationString.ALERT,StringDef.MEG_ERR_LOGININFOEMPTY);
			 }else if(componet.extraWord.text==""){
			 	  sendNotification(NotificationString.ALERT,StringDef.MEG_ERR_CHECKCODEEMPTY);
			 }else if(componet.extraWord.text!=componet.extraWordText.text){
			      sendNotification(NotificationString.ALERT,StringDef.MEG_ERR_CHECKCODEWRONG);
			      componet.extraWord.text="";
			 }else{			 	
			     sendNotification(NotificationString.CONNECT_LOADING,null,"0");//网络连接状态改变的通知
			     sendNotification(NotificationString.CONNECT_SOCKET,null,"login");//发出连接 登录socket 的通知
			 }	 */		
			 
			 if(componet.username.text==""||componet.password.text==""){
			 	  sendNotification(NotificationString.ALERT,StringDef.MEG_ERR_LOGININFOEMPTY);
			 }else{
			     sendNotification(NotificationString.CONNECT_SOCKET,null,GlobalDef.SOCKETPROXY_LOGIN);//发出连接 登录socket 的通知
			 }  
		
			 
		}
		override public function setViewComponent(viewComponent:Object):void
		{
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			         NotificationString.SOCKET_CONNECTED
			       ];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName()){
				case NotificationString.SOCKET_CONNECTED:{
					//根据参数来判断是什么socket连接成功
					switch(notification.getType()){
						case GlobalDef.SOCKETPROXY_LOGIN:{
							var obj:Object=new Object;					
							obj.user_name=componet.username.text;				
							obj.password = MD5.hash(componet.password.text);
							facade.sendNotification(NotificationString.CMD_LOGIN_ACCOUNT,obj,CMD_DEF_HALL.SUB_GP_LOGON_ACCOUNT.toString());
                  			saveName(componet.username.text);//保存用户名到本地	
							break;
						}
						case GlobalDef.SOCKETPROXY_GAME:{
							sendNotification(NotificationString.CMD_ROOM_LOGIN,null,CMD_DEF_ROOM.SUB_GP_LOGON_USERID.toString());
							break;
						}
					}
									
					break;
				}
			}
		}
		private function saveName(value:String):void{
			var isRepeat:Boolean = false;			
			if(_userNameArray.length<5){
				for(var index:* in _userNameArray){
					if(value== _userNameArray[index]){
						isRepeat = true;
					    _userNameArray.splice(index,1);
						_userNameArray.push(value);	
						break;
					}
				}
				if(!isRepeat){
					_userNameArray.push(value);
				}
			}else{
				for(var key:* in _userNameArray){
					if(value== _userNameArray[key]){
						isRepeat = true;
						_userNameArray.splice(key,1);				
						_userNameArray.push(value);
						break;
					}
				}
				if(!isRepeat){
					_userNameArray.shift();
				    _userNameArray.push(value);
				}
			}			
			LocalData.getInstance().setObject("username",_userNameArray,0);
		}
		override public function onRegister():void
		{
			init();			
			componet.loginBtn.addEventListener(MouseEvent.CLICK,loginHandle);
			componet.registerBtn.addEventListener(MouseEvent.CLICK,registerHandle);
			componet.extraWord.addEventListener(FlexEvent.ENTER,loginHandle);
			componet.chargeBtn.addEventListener(MouseEvent.CLICK,chargHandle);
		}
		
		override public function onRemove():void
		{
		}
		
	}
}