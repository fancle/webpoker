package common.game.interfaces
{
	import mx.core.UIComponent;
	

	public interface IFaceView
	{
		function createFace(nIndex:int,pos:int):Boolean;
		function destroy():void;

		//function switchFaceIndex(nNewIndex:int):Boolean;
		function getMovieClip():UIComponent;
		function moveMovieClip(x:Number, y:Number):void;
		function get pos():int;
		//function showMotion(strMotionName:String, bImmediately:Boolean):void;
		function setOffLine(bOffLine:Boolean):void;
	}
}