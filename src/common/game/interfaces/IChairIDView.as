package common.game.interfaces
{
	import mx.core.UIComponent;
	
	public interface IChairIDView
	{
		function createChairIDView(nChairID:int):Boolean;
		function destroy():void;
		
		function setChairID(nChairID:int):void;
		function getChairID():int;
		
		function getMovieClip():UIComponent;
		function moveMovieClip(x:Number,y:Number):void;
		function setOffLine(bOffLine:Boolean):void;
	}
}