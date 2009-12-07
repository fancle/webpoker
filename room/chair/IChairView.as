package chair
{
	import flash.display.Bitmap;
	
	import mx.core.IFlexDisplayObject;
	
	public interface IChairView extends IFlexDisplayObject
	{
		function set chairId(value:int):void;
		function get chairId():int;
		function set tableId(value:int):void;
		function get tableId():int;	
		function set isSit(value:Boolean):void	
		function setHead(value:Bitmap,userName:String,userId:int):void
		function clearHead():void;
		function get userId():int;
		
	}
}