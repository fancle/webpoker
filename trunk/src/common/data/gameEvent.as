package common.data
{
	import flash.events.Event;

	public class gameEvent extends Event
	{   
		public static const USER_POS:String = "user_pos";//玩家的桌椅号
		public static const USER_ID:String = "user_ID"; //玩家id
		public static const USE_PROP:String = "user_prop";//使用道具
		public var data:Object = new Object();
		public function gameEvent(type:String,value:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = value;
			super(type, bubbles, cancelable);
		}
		
	}
}