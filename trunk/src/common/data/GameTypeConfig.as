package common.data
{
	public class GameTypeConfig
	{
		private static var _instance:GameTypeConfig;
		private var data:XML;
		public function GameTypeConfig(value:XML)
		{
			if(_instance!=null){
				throw  new Error("游戏单例出错");
			}
			data = value;
		}
		public static function getInstance(value:* = null):GameTypeConfig{
			var xml:XML= XML(value);
			if(_instance==null){
				_instance = new GameTypeConfig(xml);
			}
			return _instance;
		}
		//给如游戏名获取桌子类名
		public function getClassType(value:String):Object{		
			var typeName:String = value;	
			var xmlList:XMLList= data.item;
			for (var index:* in xmlList){
				 var testName:RegExp = new RegExp(xmlList[index].@name);
				 if(testName.test(typeName)){
				 	 return xmlList[index].@type;
				 }
			}
			return null;
		}
		/**
		 * 
		 * @param value 传入的游戏名
		 * @return  传回游戏配置文件里的名字
		 * 例如 
		 *  传入 视频斗地主
		 *  返回 doudizhu
		 * 完全按照配置文件来获取
		 */
		public function getGameName(value:String):String{
		    var typeName:String = value;	
			var xmlList:XMLList= data.item;
			for (var index:* in xmlList){
				 var testName:RegExp = new RegExp(xmlList[index].@name);
				 if(testName.test(typeName)){
				 	 return (xmlList[index].@gamename);
				 }
			}
			return null;
		}

	}
}