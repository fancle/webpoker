package common.game.interfaces
{

	import mx.flash.UIMovieClip

	public interface IClockView
	{
		function createClockView(nSecond:int):Boolean;
		function destroy():void;

		function setSecond(nSecond:int):void;
		function getSecond():int;

		function getMovieClip():UIMovieClip;
		function moveMovieClip(x:Number, y:Number):void;
	}
}