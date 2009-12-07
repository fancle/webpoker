package Application.model.interfaces
{
	public interface IGameClassContainer extends IChannelMessageSink
	{
		//销毁游戏端
		function DestroyGameClass(game:IGameClass, bAutoSitChairAgain:Boolean = false):void;
	}
}