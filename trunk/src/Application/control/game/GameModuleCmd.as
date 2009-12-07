package Application.control.game
{
	import Application.NotificationString;
	import Application.view.mediator.room.RoomMediator;
	
	import common.assets.ModuleLib;
	import common.data.GlobalDef;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * 
	 * 游戏模块加载控制类
	 */
	public class GameModuleCmd extends SimpleCommand implements ICommand
	{
		public function GameModuleCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			
			//加载完所有素材 开始进入房间 这里注意 可能以后需要加入type 来对判断是否快速进入游戏
			var obj:Object = notification.getBody()["address"];
            sendNotification(NotificationString.CONNECT_SOCKET,obj,GlobalDef.SOCKETPROXY_GAME);
			//注册RoomMediator		
			if(!facade.hasMediator(RoomMediator.NAME)){
				facade.registerMediator(new RoomMediator(((ModuleLib.getInstance().lib).find("room") as RoomModule)));
			}	 
			
			(facade.retrieveMediator(RoomMediator.NAME) as RoomMediator).gameName = notification.getBody()["gamename"];	
		}
		
	}
}