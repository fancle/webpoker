package common.game.timeutils
{
	import de.polygonal.ds.HashMap;
	
	public class TimerMap
	{
		public var m_timerMap:HashMap;
		public function TimerMap()
		{
			m_timerMap = new HashMap();
		}
		//销毁
		public function Destroy():void
		{
			var arr:Array = m_timerMap.toArray();
			for(var i:uint = 0; i < arr.length; i ++)
			{
				arr[i].kill();
			}
			m_timerMap.clear();
			m_timerMap = null;
		}
		//设置定时
		public function setTimer(nIDEvent:int,
								 uElapse:int,
								 listener:Function):int{
				var timer:TimerPair = m_timerMap.find(nIDEvent);
				if(timer==null){
					timer = new TimerPair(nIDEvent,listener,uElapse);
					m_timerMap.insert(nIDEvent,timer);
					timer.start();
					return nIDEvent;
				}else{
					timer.restart(uElapse,listener);
					return nIDEvent;
				}
				
			
		}
		public function killTimer(nIDEvent:int):void{
			var timer:TimerPair = m_timerMap.find(nIDEvent);
			if(timer){
				timer.kill();
				m_timerMap.remove(nIDEvent);
				timer = null;
			}
		}

	}
}