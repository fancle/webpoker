package
{
	import flash.display.MovieClip;
	
	import mx.flash.UIMovieClip;
	public class ExpBar extends UIMovieClip
	{

		public var percent_mc:MovieClip;
		
		public function ExpBar()
		{					
		}
		public function set percent(value:Number):void{
			percent_mc.scaleX = value;
		}

	}
}