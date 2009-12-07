package Application.model.net.socket
{
	import flash.events.Event;

	public class ClientSocketEvent extends Event
	{
		public static const SOCKET_CONNECT:String = "socket_connect";//socket连接成功事件type---注：此事件是在socket收到第一次数据（即策略文件）后调度，而不是CONNECT事件
		public static const SOCKET_CLOSE:String = "socket_close";
		public static const SOCKET_ERROR:String = "socket_error";
		public static const SOCKET_TIMEOUT:String = "socket_timerout";//socket连接超时
		
		private var _para:Object;
		
		public function ClientSocketEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_para = para;
		}
		public function get para():Object{
			return _para;
		}
		
		override public function toString():String
		{
			var __str:String = "[ClientSocketEvent type=\""+type+"\" bubbles="+bubbles+" cancelable="+cancelable+" eventPhase="+eventPhase+" para="+_para.toString()+"]";
			return __str;
		}
	}
}