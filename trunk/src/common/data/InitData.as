package common.data
{
	import com.dynamicflash.util.Base64;
	

	/**
	 * 初始化信息  保存 gamexml地址 和用户名密码
	 * @author Administrator
	 *
	 */
	public class InitData
	{
		private static var instance:InitData=new InitData();
		private var _xmlUrl:String = "config/gameconfig.xml";
		private var _userName:String;
		private var _passWord:String;
		private var _personInfo:String;
		private var _personArray:Array = new Array();
		public function InitData()
		{
			if (instance != null)
			{
				throw new Error("实例化单例类出错-InitData");
			}
			
		}

		public static function getInstance():InitData
		{
			if (instance == null)
			{
				instance=new InitData();
			
			}
			return instance;
		}

		public function set userName(value:String):void
		{  
			_userName=value;
		}

		public function get userName():String
		{
			return _personArray[0].toString();
		}

		public function set passWord(value:String):void
		{
			_passWord=value;
		}

		public function get passWord():String
		{
			return  (_personArray[1].toString()).substr(0,32);
		}

		public function set xmlUrl(value:String):void
		{   
			if(value!=null)
			{
				_xmlUrl=value;
			}
			
		}

		public function get xmlUrl():String
		{  
			
			return _xmlUrl;
		}
		public function set personInfo(value:String):void
		{
			if(value!=null){
				  _personInfo = Base64.decode(value);
				 analysis(_personInfo);   
			}
			

		}
		public function get personInfo():String
		{
			 return _personInfo;
		}
		/**
		 * 解析用户数据 
		 * @param value
		 * 
		 */
		private function analysis(value:String):void
		{   
			
			_personArray = value.split("#");
		}

	}
}