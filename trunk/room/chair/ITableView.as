package chair
{
	import flash.display.BitmapData;
	
	public interface ITableView
	{
		function set tableId(value:int):void;
		function get tableId():int;
		function setSitDownId(value:int,value1:BitmapData,value2:String,userId:int):void;
		function setStandUp(value:int):void
		function set playStatus(b:Boolean):void;
		function dispose():void;
	}
}