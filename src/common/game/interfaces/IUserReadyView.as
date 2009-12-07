package common.game.interfaces
{
	import mx.flash.UIMovieClip;
	
	public interface IUserReadyView
	{
		function createUserReadyView(nIndex:int):Boolean;
		function destroy():void;
		function get pos():int;
		function getMovieClip():UIMovieClip;
		function moveMovieClip(x:Number,y:Number):void;
	}
}