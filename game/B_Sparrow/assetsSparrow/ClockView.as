package {
	import common.game.interfaces.IClockView;
	import flash.text.TextField;
	import mx.flash.UIMovieClip;
	import flash.display.MovieClip;


	public class ClockView extends UIMovieClip implements IClockView{
		private var m_nSecond:int;
		public function ClockView(nSecond:int = 0):void{
			super();
			clock_txt.selectable = false;
			createClockView(nSecond);
			this.stop();
			
		}
		public function createClockView(nSecond:int):Boolean{
			setSecond(nSecond);
			return  true;
		}
		public function destroy():void
		{
		}
		public function setSecond(nSecond:int):void
		{
			m_nSecond = nSecond;
			if(m_nSecond > 0)
			{
				this.visible = true;
				clock_txt.text = String(nSecond);
			}else
			{
				this.visible = false;
			}

		}
		public function getSecond():int
		{
			return m_nSecond;
		}
		public function getMovieClip():UIMovieClip
		{
			return this;
		}
		//改变指针角度
		public function isMe(value:Boolean):void{
			 if(value==true){
				 this.gotoAndStop(1);
				 
			 }else{
				 this.gotoAndStop(2);
			 }

		}
		public function moveMovieClip(x:Number,y:Number):void
		{
			this.x = x;
			this.y = y;
		}
	}
}