package common.data
{
	import flash.events.EventDispatcher;

	/**
	 * 
	 * 单例事件发送类
	 */
	public class CommonEvent extends EventDispatcher
	{
		private static var  _instance:CommonEvent;
		public function CommonEvent()
		{
			
		
			if(_instance!=null){
				throw new Error("CommonEvent单例错误");
				
			}
			
		}
		public static function getInstance():CommonEvent{
			if(_instance==null){
				_instance = new CommonEvent();
			}
			return _instance;
		}		
	}
}