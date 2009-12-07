package  
{

	import common.game.interfaces.IUserReadyView;
	
	import mx.flash.UIMovieClip;
	public class UserReadyView extends UIMovieClip implements IUserReadyView
	{
		private var _pos:int;
		public function UserReadyView(pos:int)
		{
			_pos = pos;
			super();
			
		}
		public function createUserReadyView(nIndex:int):Boolean
		{
			return true;
		}
		public function destroy():void
		{
		}
		public function getMovieClip():UIMovieClip
		{
			return this;
		}
		public function moveMovieClip(x:Number,y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		public function get pos():int{
			return _pos;
		}

	}
}