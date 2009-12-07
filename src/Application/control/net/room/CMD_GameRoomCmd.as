package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.user.UserManager;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_GameRoomCmd extends SimpleCommand implements ICommand
	{
		public static const ROOM_SOCKET_CLOSE:String = "room_socket_close";//房间socket断开
		
		public function CMD_GameRoomCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var type:String = notification.getType();
			
			switch(type){
				case ROOM_SOCKET_CLOSE:{
					//判断是否在游戏当中
					if(facade.hasProxy(GameFrameProxy.NAME)){
						//在游戏当中
						var obj:Object = new Object;
						obj["socketConnected"]=0;
						sendNotification(NotificationString.CMD_GAME_FRAME,obj,"closeGameClient");
					}
					//清除用户
					UserManager.getInstance().DeleteAllUserItem();
					//清除房间配置信息
					(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).exitServer();
					//关闭socket
					(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).close();
					//发送通知
					sendNotification(NotificationString.ROOM_SOCKET_CLOSE,null,null);
					break;
				}
			}
		}
		
	}
}