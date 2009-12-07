package common.game
{
	import flash.events.Event;

	public class BaseGameViewEvent extends Event
	{
		public var m_nMsg:int;
		public var m_nWParam:*;
		public var m_nLParam:*;

		public function BaseGameViewEvent(strName:String, nMsg:int=0, nWParam:*=0, nLParam:*=0):void
		{
			super(strName,true);
			m_nMsg=nMsg;
			m_nWParam=nWParam;
			m_nLParam=nLParam;
		}

	}
}