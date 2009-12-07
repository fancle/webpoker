package common.data
{
	public class EmotionFaceConfig
	{	
		private var _data:XML;
		private  static var instance:EmotionFaceConfig;
		public function EmotionFaceConfig(value:XML):void
		{
			if(instance!=null){
				 throw new Error("实例化单例类出错-emotion");
			}
			_data = value;
			return;
		}
		public static function getInstacne(value:Object = null):EmotionFaceConfig{
			var xml:XML = XML(value);
			if(instance==null){
				instance = new EmotionFaceConfig(xml);
			}
			return instance;
		} 
		public function get data():XML{
			return _data
		}
	}
}