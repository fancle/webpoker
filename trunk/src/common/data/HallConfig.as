package common.data
{
	public class HallConfig
	{    
		private static var instance:HallConfig;
		private var _data:XML;
		private var root:String;
		public function HallConfig(value:XML)
		{ 
			if(instance!=null){
				throw new Error("实例化单例类出错-HallConfig");
			}
			data = value;
			init();
		}
		private function init():void
		{
			root =GameConfig.getInstance().root;
		}
		public function set data(value:XML):void{
			_data = value;
		}
		public function get data():XML{
			return _data;
		}
		//获取版本  
		public function get version():String{
			var version:String;
			if(data!=null){
				version = data.version.@no;
			}
			if(version==""){
				throw new Error("大厅版本获取出错");
			}
			return version
		}
		//获取scoket信息 id scoket名 host scoket地址 port scoket号
		public function getScoket(value:String):Object{
			var obj:Object = {};			
			if(data!=null){
				var dataxml:XMLList = data.servers.server;				
				for(var key:* in dataxml){
					if(value==dataxml[key].@id){
						obj["id"] = dataxml[key].@id;
						obj["host"] = dataxml[key].@host;
						obj["port"] = dataxml[key].@port;															
					}				
				}
				
				if(obj.hasOwnProperty("id")==false){
					 throw new Error("加载scoket出错");
				}
				
			}
			return obj;	
		}
		//获取指定大厅资源地址
		public function getHall(value:String):String{
			 var url:String;
			 var prefix:String;
			 if(data!=null){
			 	prefix = data.hallRes.@prefix;			 	
			 	var dataxml:XMLList = data.hallRes.res;
			 	for(var key:* in dataxml ){
			 		 if(value==dataxml[key].name){
			 		 	url = root+dataxml[key].@url;			 		 	
			 		 }			 		
			 	}
			 	if(url==""){
			 		throw new Error("加载指定大厅文件地址出错");
			 	}
			 			
			 	
			 }
			 return url;	 
		}
		//获取大厅资源列表
		public function getHallList():Array{
			var list:Array = new Array();
			var prefix:String;			
			if(data!=null){
				prefix = data.hallRes.@prefix;		 	
			 	var dataxml:XMLList = data.hallRes.res;			
			 	for(var key:* in dataxml){
			 		var obj:Object = new Object();
			 		obj["name"] = dataxml[key].@name;
			 		obj["url"] = ((dataxml[key].@url).toString().substr(0,7)=="http://")?(dataxml[key].@url):(root+dataxml[key].@url);
			 		obj["type"] = dataxml[key].@type;
			 		list.push(obj);			 		
			 	}
			}
			if(list.length==0){
				throw new Error("加载大厅列表文件地址出错==HallConfig");
			}
			return list;
		}
		//获取游戏配置文件地址
		public function getGameList():String{
			var url:String;
			if(data!=null){
				url = root+data.gameList.@url;
				
			}
			if(url==""){
				throw new Error("加载游戏配置文件出错");
			}
		    return  url;
		}
		//获取策略文件地址
	    public function getCrossdomain():String{
	    	var url:String;
	    	if(data!=null){
	    		url=data.crossdomain.@url;
	    	}
	    	if(url==""){
	    		throw new Error("获取策略文件出错");
	    	}
	    	return url;
	    }
	    //获取 制定名的广告的资源连接和 超链接的地址
	    public function getAd(value:String):Object{
	    	var obj:Object = {}	    
	        if(data!=null){
	        	var dataxml:XMLList = data.ads.ad;
	        	for(var index:* in dataxml){
	        		if(value==dataxml[index].@name){
	        		   obj["url"] =  dataxml[index].@url;
	        		   obj["link"] = dataxml[index].@link;
	        		   break;	
	        		}
	        	}
	        }   	
	        if(obj["url"]==""){
	        	throw new Error("加载广告出错");
	        }
	        return obj;

	    }
	    //获取 指定的连接
	    public function getLink(value:String):Object{
	    	var obj:Object = {};
	    	if(data!=null){
	    		var dataxml:XMLList = data.links.link;
	    		for(var index:* in dataxml){
	    			if(value==dataxml[index].@name){
	    				obj["url"] = dataxml[index].@url;
	    				obj["text"] = dataxml[index].@text;
	    				break;
	    			}
	    		}
	    	}
	    	if(obj["url"]==""){
	    		throw new Error("加载连接出错");
	    	}
	    	return obj;
	    }
	    //获取网站上头像资源的路经
	    public function getPhotoFile():String{
	    	var url:String;
	    	if(data!=null){
	    		url = data.photo.@url;
	    	}
	    	if(url==""){
	    		throw new Error("加载头像出错");
	    	}
	    	return url;
	    }
	    //获取游戏类型房间中的对应类的对应类
	    public function getGameType():String{
	    	var url:String;
	    	if(data!=null){
	    		url = root+data.gametype.@url;
	    	}
	    	if(url==""){
	    		throw new Error("加载游戏配置类出错");
	    	}
	    	return url;
	    }
	    public function getEmotionFace():String{
	    	var url:String;
	    	if(data!=null){
	    		url=root+data.emotion.@url;
	    		
	    	}
	    	if(url==""){
	    		throw new Error("加载表情配置文件出错");
	    	}
	    	return url;
	    }
	    public function getServerObject(serverID:int):Object
		{
			var xml:XMLList = data.serverNameRule.server.(@id == String(serverID));
			
			if(xml.length()==0) 
				return null;
			
			var obj:Object = new Object;
			obj["name"] = xml.name;
			obj["multiple"] = xml.multiple;
			obj["description"] = xml.description;
			obj["limit"] = xml.limit;
			
			return obj;
		}
	    //////////////////////////////////////////////////////////////////////
		public static function getInstance(value:* = null):HallConfig{
			var xml:XML = XML(value);
			if(instance==null){
				instance = new HallConfig(value);
			}
			return instance;
		}
		

	}
}