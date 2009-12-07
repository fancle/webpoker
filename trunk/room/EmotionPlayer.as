package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	
	import org.gif.player.GIFPlayer;
	
	public class EmotionPlayer extends Object
	{
		public static var emotionHolder:MovieClip;
		
		public function EmotionPlayer()
		{
			return;
		}//end function
		
		
		public static function getPlayerByName(_name:String):DisplayObject
		{
			var _emotionClassRef:Class;
			var _gifLoader:GIFPlayer;
			_emotionClassRef = emotionHolder[_name] as Class;
			// ModuleLib.getInstance().getClass(_name);
			_gifLoader = new GIFPlayer();
			(_gifLoader as GIFPlayer).loadBytes(new _emotionClassRef as ByteArray);//.loadBytes(new _emotionClassref as ByteArray);
			return _gifLoader;
		}
		
		public static function getPlayerByIndex(_index:uint):DisplayObject
		{
			var _emotionClassRef:Class;
			var _gifLoader:GIFPlayer;
			
			_emotionClassRef = emotionHolder["EmotionData" + _index] as Class;
			if(_emotionClassRef)
			{
				_gifLoader = new GIFPlayer();
				(_gifLoader as GIFPlayer).loadBytes(new _emotionClassRef as ByteArray);
				return _gifLoader;
			}// end if
			return null;
		}
	}
}