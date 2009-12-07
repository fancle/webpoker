package common.data
{
	public class GameListConfig
	{   
		private var _data:XML;
		private static var instance:GameListConfig;
		private var root:String;
		public function GameListConfig(value:XML)
		{
			 if(instance!=null){
			 	 throw new Error("实例化单例类出错-GameConfig");
			 }
			 data = value;
			 init();
			 return;
		}
		private function init():void
		{
			root =GameConfig.getInstance().root;
		}
        public function set data(value:XML):void{
        	 _data =  value;
        }
        public function get data():XML{
        	 return _data;
        }
        //获取版本号
		public function get version():String{
			var version:String;
			if(data!=null){
				version = data.version.@no;
			}
			if(version==""){
				throw new Error("加载版本号出错");
			}
		    return version;
		}
		//获取指定加载指定游戏模块 返回2维的object 其中属性有[模块名][属性名] 返回的2维对象根据配置文件的不同而又可能不同
		public function getGameModule(value:String):Object{
			var obj:Object = {};
			obj["module"] = {};
			if(data!=null){
				var prefix:String = data.moduleList.@prefix;
				var dataxml:XMLList = data.moduleList.module;	            
				for(var key:* in dataxml){
					if(value==dataxml[key].@name){														
                         obj["module"]["url"] = root+dataxml[key].@url;
                         obj["module"]["statusText"] = dataxml[key].@statusText;  
                         obj["module"]["type"] = dataxml[key].@type;                        	
                         if(dataxml[key].material.@url!=""){
                         	      obj["material"] = {};
                         	      obj["material"]["url"] = root+dataxml[key].material.@url;
                                  obj["material"]["stausText"] = dataxml[key].material.@statusText;
                                  obj["material"]["type"] = dataxml[key].material.@type;                               
                         }
 						 if(dataxml[key].config.@url!=""){
 						 	      obj["config"] = {};
 						 	      obj["config"]["url"] = root+dataxml[key].config.@url;
                     		      obj["config"]["stausText"] = dataxml[key].config.@statusText;
                     		     	
 						 }
						 if(dataxml[key].framework.@url!="")
						 {
						   		  obj["framework"] = {};
						 		  obj["framework"]["url"] = root+dataxml[key].framework.@url;
						 		  obj["framework"]["stausText"] = dataxml[key].framework.@statusText;
						 		  obj["framework"]["type"] = dataxml[key].framework.@type;
						 }				
					}				
				}
				if(obj.hasOwnProperty("module")==false){
					throw new Error("加载游戏模块出错");
				}			
			}
		    return obj;
		}
		public  static function getInstance(value:Object = null):GameListConfig{
			var xml:XML = XML(value);
			if(instance==null){
				instance = new  GameListConfig(xml);
			}
			return instance;
		}
	}
}