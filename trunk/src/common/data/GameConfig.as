package common.data
{
	public class GameConfig
	{
		private var _data:XML;
		private static var instance:GameConfig;
		public function GameConfig(value:XML):void
		{
			 if(instance!=null){
			 	 throw new Error("实例化单例类出错-GameConfig");
			 }
			 data = value;
			 
			 return;
		}
		//获取版本号
		public function get version():String{
			var version:String;
			if(data!=null){
				version = data.version.@no;
				trace(version);
			}
			if(version==""){
				throw new Error("加载版本号出错");
			}
		    return version;
		}
		//获取大厅配置文件地址
		public function get hallConfigUrl():String{
			var hallUrl:String;
			if(data!=null){
				hallUrl = root+data.hall.hallconfig.@url;
			}
			if(hallUrl==""){
				throw new Error("加载大厅配置文件地址出错");
			}
			return hallUrl;
		} 
		//设置xml
		public function set data(value:XML):void{
			_data = value;
		}
		//获取xml
		public  function get data():XML{
			return _data;
		}
		public function get root():String
		{
			 if(data!=null){
				return data.hall.@root;
			}
			return "";
		}
		public static function  getInstance(value:Object = null):GameConfig{
			var xml:XML = XML(value);
			if(instance==null){
				instance = new GameConfig(xml);
			}
			return instance;
		}
        
	}
}