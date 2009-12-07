package Application.model
{
	import Application.NotificationString;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SingleGameProxy extends Proxy implements IProxy
	{  
		public static const NAME:String = "SingleGameProxy";
		private static var gameModuleLib:HashMap = new HashMap();
		private var module:IModuleInfo;
		private var rsl:Loader = new Loader();
		private var downArray:Array = new Array();
		private var _name:String;
		private var _dataObj:Object = new Object();
		private var _moduleArr:Array = new Array();
		private var _typeArr:Array = new Array();
		public function SingleGameProxy(data:Object=null)
		{
			super(NAME, data);
		
		}
		private function init():void{
			
		}
		/**
		 * 
		 * @param value  游戏的各种配置信息
		 * @param value1 游戏名 房间地址
		 */
		public function setGame(value:Object,value1:Object):void{
			_name = value1["gamename"];
			_dataObj = value1;
			if(gameModuleLib.containsKey(_name)==true){
				sendNotification(NotificationString.LOAD_GAME_MODULE_COMPLETE,_dataObj);	
				return;			
			}			
			for(var key:String in value){
				_moduleArr.push(key);// 添加模块名
				downArray.push(value[key]["url"]);//加载各种模块
				_typeArr.push(value[key]["type"]);//添加模块类型
			}
            benginDown();
		}
		private function benginDown():void{
		
			if(_typeArr[0]=="module"){
			
			    module = ModuleManager.getModule(downArray[0]);
				if(module.hasEventListener(ModuleEvent.PROGRESS)==false){
					module.addEventListener(ModuleEvent.PROGRESS,onProgress,false,0,true);
					module.addEventListener(ModuleEvent.READY,onReady,false,0,true);
					module.addEventListener(ModuleEvent.ERROR,onError,false,0,true);
				}			
				module.load();
			}else{
				
				if(rsl.hasEventListener(ProgressEvent.PROGRESS)==false){
					 rsl.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressRsl,false,0,true);
					 rsl.contentLoaderInfo.addEventListener(Event.COMPLETE,onReady,false,0,true);
					 rsl.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onErrorRsl,false,0,true);
				}
				rsl.load(new URLRequest(downArray[0].toString()));
			}		

			
		}
		private function onProgress(evt:ModuleEvent):void{			
			sendNotification(NotificationString.LOAD_EVENT,{bytesLoaded:evt.bytesLoaded,bytesTotal:evt.bytesTotal},"1");
		}
		private function onProgressRsl(evt:ProgressEvent):void{
			sendNotification(NotificationString.LOAD_EVENT,{bytesLoaded:evt.bytesLoaded,bytesTotal:evt.bytesTotal},"1");
		}
        private function onReady(evt:Event):void{   
        	if(!gameModuleLib.containsKey(_name))
        	{
        		var itemMap:HashMap = new HashMap();
        		gameModuleLib.insert(_name,itemMap);
        		
           	}
           	var tempMap:HashMap = gameModuleLib.find(_name);
           	if(_typeArr[0].toString()=="module"){           		
           	   	tempMap.insert(_moduleArr[0],((evt.currentTarget as IModuleInfo).factory.create())); 
           	}else{
           		tempMap.insert(_moduleArr[0],(evt.currentTarget as LoaderInfo));
           	}      	
            _moduleArr.shift(); 	 	      
        	downArray.shift();
        	_typeArr.shift();
        	if(downArray.length!=0){
        		 benginDown();
        	}else{
        		sendNotification(NotificationString.LOAD_EVENT,null,"2");        	 
        		sendNotification(NotificationString.LOAD_GAME_MODULE_COMPLETE, _dataObj);
        	}        
        }
        
        //获取游戏资源
        public function get lib():HashMap{     
        	return gameModuleLib as HashMap;
        	
        }
        private function onError(evt:ModuleEvent):void{   
        	throw new Error(evt.errorText);
        	
        }
        private function onErrorRsl(evt:IOErrorEvent):void{
        	throw new Error(evt.text);
        }
		override public function getProxyName():String
		{
			return NAME;
		}
		
		override public function setData(data:Object):void
		{
		}
		
		override public function getData():Object
		{
			return null;
		}
		
		override public function onRegister():void
		{
				init();
		}
		
		override public function onRemove():void
		{
		}
		
	}
}