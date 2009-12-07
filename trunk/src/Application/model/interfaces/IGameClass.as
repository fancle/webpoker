package Application.model.interfaces
{
	import flash.display.LoaderInfo;
	
	import mx.core.UIComponent;
	
	public interface IGameClass extends IChannelMessageSink
	{
		function  get assets():LoaderInfo;//获取资源
 		//创建游戏端
		function CreateGameClient(clientContainer:IGameClassContainer,assets:LoaderInfo=null):Boolean;
		//销毁游戏端
 		function DestroyGameClient():void;
		//获取影片
		function GetMovieClip():UIComponent;
		//获取游戏视图
		function GetGameView():IGameView;
		//退出游戏
		function SendEventExitGameClient(bAutoSitChairAgain:Boolean = false):void;  
		
	}
}