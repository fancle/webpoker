package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.interfaces.IPropertyItem;
	import Application.model.present.PresentManager;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.room.tagFlowerInfo;
	import Application.model.vo.protocol.room.tagUserData;
	
	import common.data.CMD_DEF_ROOM;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CMD_RoomPresentCmd extends SimpleCommand implements ICommand
	{
		public static const PROP_ATTRIBUTE:String = CMD_DEF_ROOM.SUB_GF_PROP_ATTRIBUTE.toString();//道具属性
		public static const FLOWER_ATTRIBUTE:String = CMD_DEF_ROOM.SUB_GF_FLOWER_ATTRIBUTE.toString();//鲜花属性
		public static const FLOWER:String = CMD_DEF_ROOM.SUB_GF_FLOWER.toString();//鲜花消息
		public static const PROP_BUGLE:String = CMD_DEF_ROOM.SUB_GF_PROP_BUGLE.toString();//喇叭道具
		public static const EXCHANGE_CHARM:String = CMD_DEF_ROOM.SUB_GF_EXCHANGE_CHARM.toString();//兑换魅力
		
		public function CMD_RoomPresentCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var type:String = notification.getType();
			switch(type){
				case PROP_ATTRIBUTE:		//收到道具属性
				{
					recvPropInfo(notification.getBody());
					break;
				}
				case FLOWER_ATTRIBUTE:
				{
					recvFlowerAttribute(notification.getBody());
					break;
				}
				case FLOWER:
				{
					recvFlowerCmd(notification.getBody());
					break;
				}
				case PROP_BUGLE:
				{
					
					break;
				}
				case EXCHANGE_CHARM:
				{
					
					break;
				}
			}
		}
		/**
		 * 收到道具属性
		 * @param obj
		 * 
		 */
		private function recvPropInfo(obj:Object):void{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			
			/* var propertyInfo:tagPropertyInfo;
			for(var i:int = 0 ;i<wDataSize/tagPropertyInfo.sizeof_tagPropertyInfo;i++){
				propertyInfo = tagPropertyInfo.readData(bytes);
				//var propertyItem:IPropertyItem = (facade.retrieveProxy(PresentManager.NAME) as PresentManager).addProperty(propertyInfo);
			} */
			
		}
		/**
		 * 收到鲜花属性
		 * @param obj
		 * 
		 */
		private function recvFlowerAttribute(obj:Object):void{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			
			for(var i:int = 0 ;i<wDataSize/tagFlowerInfo.sizeof_tagFlowerInfo; i++){
				var flowerInfo:tagFlowerInfo = tagFlowerInfo.readData(bytes);
				var propertyItem:IPropertyItem = PresentManager.getInstance().addProperty(flowerInfo);
				
				var meUserData:tagUserData = UserManager.getInstance().getMeItem().GetUserData();
				propertyItem.setPropertyCount(meUserData.dwPropResidualTime[propertyItem.getPropertyID()%500])
			}
			
		}
		private function recvFlowerCmd(obj:Object):void{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			
			sendNotification(NotificationString.CMD_GAME_FRAME,bytes,"property");
		}
		/////////////////////////////////////////////////////////////////////////////////
		override public function initializeNotifier(key:String):void
		{
			super.initializeNotifier(key);
		}
		
	}
}