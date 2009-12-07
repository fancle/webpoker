package Application.model.load
{
	import Application.NotificationString;
	
	import common.data.GameConfig;
	import common.data.HallConfig;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LoaderProxy extends Proxy implements IProxy
	{  
		private const NAME:String = "LoaderProxy";
		private var _hallUrl:String = GameConfig.getInstance().hallConfigUrl;//大厅配置文件路径	
		private var _load:Loader = new Loader();
		private var hallResList:Array = new Array();//大厅资源列表	
	    private var _index:int = 0; 
	    private var _length:int = 0;
	    private var _module:IModuleInfo;
	    private var moduleLib:HashMap = new HashMap();
		public function LoaderProxy(data:Object=null)
		{
			super(NAME, data);

		}
		private function init():void{			
			
			hallResList = HallConfig.getInstance().getHallList();
			_length = hallResList.length;
			trace("hallResList.length = " + _length);	
			beginLoad();	
					
		}
		private function beginLoad():void{
			if(_index<_length){			  
				if(hallResList[_index]["type"]=="module"){					  
					  _module =  ModuleManager.getModule(hallResList[_index]["url"]);//加载module
					  if(_module.hasEventListener(ModuleEvent.PROGRESS)==false&&_module.hasEventListener(ModuleEvent.READY)==false&&_module.hasEventListener(ModuleEvent.ERROR)==false){
			   	  	 		_module.addEventListener(ModuleEvent.PROGRESS,onProgressHandle);
			   		 		_module.addEventListener(ModuleEvent.READY,onCompleteHandle);
			  				_module.addEventListener(ModuleEvent.ERROR,onError);
			   		 }
			   	   	_module.load();		
				}else{
					if(_load.contentLoaderInfo.hasEventListener(Event.COMPLETE)==false){
						 _load.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteHandle);
						 _load.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressHandleSwf);
						 _load.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError1);
					}
					 _load.load(new URLRequest(hallResList[_index]["url"]));
				}					 
			   //_index++; 
			}
		}
		private function onProgressHandle(evt:ModuleEvent):void{		
			sendNotification(NotificationString.LOAD_EVENT,{bytesLoaded:evt.bytesLoaded,bytesTotal:evt.bytesTotal},"1");
		   
		}
		private function onProgressHandleSwf(evt:ProgressEvent):void{
			sendNotification(NotificationString.LOAD_EVENT,{bytesLoaded:evt.bytesLoaded,bytesTotal:evt.bytesTotal},"1");
		}
		//所有资源加载完成
		private function onCompleteHandle(evt:Event):void{
			if(hallResList[_index]["type"]=="module"){
				  var info:IModuleInfo = evt.currentTarget as  IModuleInfo;				  
			      moduleLib.insert(String(hallResList[_index++]["name"]),info.factory.create());   //存入容器类
			}else{				  	
				  var _loaderInfo:LoaderInfo = (evt.currentTarget) as LoaderInfo;
				  moduleLib.insert(String(hallResList[_index++]["name"]),((evt.currentTarget) as LoaderInfo).applicationDomain);		   
			}		
                     
			if(_index==_length){				
				
				sendNotification(NotificationString.LOAD_MODULE_COMPLETE,moduleLib);//显示登陆框登陆框
				sendNotification(NotificationString.LOAD_EVENT,null,"2");//关闭loadpane			
			}else{		
				beginLoad();//再次读取
			}
		}
		public function get Lib():HashMap{
			 return moduleLib;
		}
		private function  onError(evt:ModuleEvent):void{
			throw new Error(evt.errorText);
		}
		private function onError1(evt:IOErrorEvent):void{
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