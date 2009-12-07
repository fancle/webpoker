package Application.model.net.socket
{
	import Application.NotificationString;
	import Application.model.interfaces.IClientSocketSink;
	
	import common.data.CMD_DEF_HALL;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class LoginClientSocketSinkProxy extends ClientSocketSinkBase implements IClientSocketSink
	{
		public static const NAME:String = "LoginClientSocketSinkProxy";
		public static var instance:LoginClientSocketSinkProxy;
		
		public static function getInstance(_ip:String = null , _port:uint = 0 ):LoginClientSocketSinkProxy{
			if(!instance){
				instance = new LoginClientSocketSinkProxy(_ip,_port);
			}
			return instance as LoginClientSocketSinkProxy
		}
		public function LoginClientSocketSinkProxy(_ip:String, _port:uint)
		{
			super(_ip, _port, NAME);
		}
		
		/**
		 * ====================================================
		 * -------------------覆盖基类方法----------------------
		 * ====================================================
		 */
		
		override protected function connectHandle():void{
			if(GlobalDef.DEBUG)trace("in LoginClientSocketSinkProxy connectHandle: 登录socket连接成功！");
			sendNotification(NotificationString.CONNECT_LOADING,null,"1");
			sendNotification(NotificationString.SOCKET_CONNECTED,null,GlobalDef.SOCKETPROXY_LOGIN);			
		}
		
		override protected function errorHandle():void{
			if(GlobalDef.DEBUG)trace("in LoginClientSocketSinkProxy errorHandle: 连接socket发生错误！");
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"0");
		}
		
		override protected function closeHandle():void{
			if(GlobalDef.DEBUG)trace("in LoginClientSocketSinkProxy closeHandle: socket关闭！");
			//sendNotification(NotificationString.ALERT,"连接关闭")
		}
		
		override protected function timeoutHandle():void{
			if(GlobalDef.DEBUG)trace("in LoginClientSocketSinkProxy timeoutHandle: 连接socket超时！");
			sendNotification(NotificationString.SOCKET_CONNECT_ERROR,null,"1");
		}
		
		/**
		 * ====================================================
		 * --------------------覆盖接口方法----------------------
		 * ====================================================
		 */
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		override public function getProxyName():String
		{
			return NAME;
		}
		
		override public function setData(data:Object):void
		{
		}
		
		override public function getData():Object
		{
			return null;
		}
		
		override public function onRegister():void
		{
		}
		
		override public function onRemove():void
		{
		}
		
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		override public function receiveSocketData(wMainCmdID:uint, wSubCmdID:uint, baBuffer:ByteArray, wDataSize:uint):void
		{
			super.receiveSocketData(wMainCmdID, wSubCmdID, baBuffer, wDataSize);
			
			switch(wMainCmdID){
				case CMD_DEF_HALL.MDM_GR_LOGON:{
					loginHandle(wSubCmdID,baBuffer,wDataSize);
					break;
				}
				case CMD_DEF_HALL.MDM_GR_SERVER_LIST:{
					serverListHandle(wSubCmdID,baBuffer,wDataSize);
					break;
				}
			}
		}
		
		/**
		 * ====================================================
		 * -----------------------功能方法----------------------
		 * ====================================================
		 */
		private function loginHandle(wSubCmdID:uint, baBuffer:ByteArray, wDataSize:uint):void{
			var obj:Object=new Object;
			obj.dataBuffer = baBuffer;
			obj.dataSize = wDataSize;
			
			sendNotification(NotificationString.CMD_LOGIN_ACCOUNT,obj,wSubCmdID.toString());
		}
		private function serverListHandle(wSubCmdID:uint, baBuffer:ByteArray, wDataSize:uint):void{
			var obj:Object=new Object;
			obj.dataBuffer = baBuffer;
			obj.dataSize = wDataSize;
			
			sendNotification(NotificationString.CMD_SERVER_LIST,obj,wSubCmdID.toString());
		}
	}
}