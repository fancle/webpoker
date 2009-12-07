package Application.model
{
	import Application.NotificationString;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	
	import common.data.EmotionFaceConfig;
	import common.data.GameConfig;
	import common.data.GameListConfig;
	import common.data.GameTypeConfig;
	import common.data.HallConfig;
	import common.data.InitData;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
    //加载配置文件信息
	public class ConfigProxy extends Proxy implements IProxy
	{   
		public static const NAME:String = "ConfigProxy";
		private var loader:BulkLoader;
		public function ConfigProxy(proxyName:String=null, data:Object=null)
		{
			super(NAME, data);
	
		}
		private function init():void{
			//使用第三方BulkLoader加载类
			loader = new BulkLoader("game_config");
			loader.add(InitData.getInstance().xmlUrl,{id:"config-xml"});//首个配置文件地址
			loader.addEventListener(BulkProgressEvent.PROGRESS,progressHandle);
			loader.addEventListener(BulkProgressEvent.COMPLETE,completeHandle);
			loader.start();
			sendNotification(NotificationString.LOAD_EVENT,null,"0");//显示加载条
		}
		private function progressHandle(evt:BulkProgressEvent):void{		
			//显示加载进度	
		    sendNotification(NotificationString.LOAD_EVENT,{bytesLoaded:evt.bytesLoaded,bytesTotal:evt.bytesTotal},"1");
		}
		private function completeHandle(evt:BulkProgressEvent):void{	
			//加载完毕 把值附给GameConfig 经行解析		
			if(loader.hasItem("config-xml")==true&&loader.hasItem("hall_config")==false){
				   GameConfig.getInstance(loader.getXML("config-xml"));
                   loader.add(GameConfig.getInstance().hallConfigUrl,{id:"hall_config"});            
                   loader.start();                                    
			}else if(loader.hasItem("config-xml")==true&&loader.hasItem("hall_config")==true&&loader.hasItem("game_config")==false){
				   HallConfig.getInstance(loader.getXML("hall_config"));
				   loader.add(HallConfig.getInstance().getGameList(),{id:"game_config"});            
                   loader.start();
			}else if(loader.hasItem("config-xml")==true&&loader.hasItem("hall_config")==true&&loader.hasItem("game_config")==true&&loader.hasItem("game_type")==false){
				   GameListConfig.getInstance(loader.getXML("game_config"));
				   loader.add(HallConfig.getInstance().getGameType(),{id:"game_type"});
				   loader.start();				
			} 
			else if(loader.hasItem("config-xml")==true&&loader.hasItem("hall_config")==true&&loader.hasItem("game_config")==true&&loader.hasItem("game_type")==true&&loader.hasItem("emotion_face")==false){
				   GameTypeConfig.getInstance((loader.getXML("game_type")));	
				   loader.add(HallConfig.getInstance().getEmotionFace(),{id:"emotion_face"});
				   loader.start();
			}
			else {				 
				   EmotionFaceConfig.getInstacne(loader.getXML("emotion_face"));			
				   loader.clear();//清除loader;
				   loader = null;
				   sendNotification(NotificationString.LOAD_CONFIG_COMPLETE);				   
				   	
			}
		
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