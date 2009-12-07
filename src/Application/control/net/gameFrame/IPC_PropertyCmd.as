package Application.control.net.gameFrame
{
	import Application.NotificationString;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IPropertyItem;
	import Application.model.present.PresentManager;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.gameFrame.IPC_Property;
	import Application.model.vo.protocol.room.CMD_GF_Gift;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.IPC_DEF;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class IPC_PropertyCmd extends SimpleCommand implements ICommand
	{
		public function IPC_PropertyCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var p:IPC_Property = notification.getBody()["dataBuffer"] as IPC_Property;
			if(!p) return ;
			
			switch(notification.getType()){
				case IPC_DEF.IPC_SUB_PROPERTY_RECV.toString():		//接收到道具信息
				{
					//这个是经游戏convertUserIDToCoordinate再传回来的信息
					
					var obj:Object = new Object;
					//obj["coordinate"] = new Point(300,200);
					obj["coordinate"] = p.userCoordinate;
					obj["propertyID"] = p.propertyID;
					
					//传给框架来做显示处理---给框架发送通知
					
					sendNotification(NotificationString.GAME_FRAME_PROPERTY,obj);
					break;
				}
				case IPC_DEF.IPC_SUB_PROPERTY_SEND.toString():		//发送道具信息
				{
					//这个是游戏直接根据点击处的用户头像转化为UserID传过来的
						//组装一个CMD_GF_GiftNotify对象，ByteArray
					//取得当前使用道具情况----是否是使用道具状态
					var propertyItem:IPropertyItem = PresentManager.getInstance().getCurrentProperty();
					if(!propertyItem) return;
					
					var cmd_Gif:CMD_GF_Gift = new CMD_GF_Gift;
					
					cmd_Gif.cbSendLocation = GlobalDef.LOCATION_GAME_ROOM;
					cmd_Gif.dwRcvUserID = p.userID;
					cmd_Gif.wFlowerCount = 1;
					cmd_Gif.wGiftID = propertyItem.getPropertyID();
					cmd_Gif.dwSendUserID = UserManager.getInstance().getMeItem().GetUserID();
					
					
					var bytes:ByteArray = cmd_Gif.toByteArray();
					
					//发送给服务器
					(facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy).OnIPCSocketMessage(CMD_DEF_ROOM.MDM_GF_PRESENT,CMD_DEF_ROOM.SUB_GF_FLOWER,bytes,CMD_GF_Gift.sizeof_CMD_GF_Gift);
					
					break;
				}
			}
		}
		
	}
}