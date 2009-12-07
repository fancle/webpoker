package common.game.timeutils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TimerPair
	{
		public var m_nIDEvent:int;
		public var m_handler:Function;
		public var m_timer:Timer;
		public function TimerPair(nIDEvent:int, handler:Function, uElapse:int)					
		{
			m_nIDEvent = nIDEvent;
			m_handler = handler;
			m_timer = new Timer(uElapse);
			m_timer.addEventListener(TimerEvent.TIMER,timerHandler);
		}
		//开始
		public function start():void
		{
			m_timer.start();
		}
		//停止
		public function stop():void
		{
			m_timer.stop();
		}
		//重新开始
		public function restart(uElapse:int, handler:Function):void
		{
			kill();
			m_handler  = handler;
			m_timer    = new Timer(uElapse);
			m_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			m_timer.start();
		}

		//销毁
		public function kill():void
		{
			if(m_timer)
			{
				m_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				m_timer.stop();
				m_timer = null;
				m_handler = null;
			}
		}
		private function timerHandler(evt:TimerEvent):void{
				m_handler(m_nIDEvent);
		}

	}
}