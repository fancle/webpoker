package Application.model.interfaces
{
	import mx.core.UIComponent;
	
	public interface IGameView
	{
		//初始游戏视图
		function InitGameView():Boolean;
		//销毁游戏视图
		function DestroyGameView():void;
		//获取游戏视图影片
		function GetGameViewMC():UIComponent;	
	}
}