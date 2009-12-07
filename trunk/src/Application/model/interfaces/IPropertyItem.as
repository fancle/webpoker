package Application.model.interfaces
{
	import Application.model.vo.protocol.room.tagFlowerInfo;
	
	public interface IPropertyItem
	{
		function setPropertyData(propertyData:tagFlowerInfo):void;			//设置道具数据
		function setPropertyCount(count:int):void;							//设置道具数量
		function getPropertyCount():int;									//取道具数量
		function getPropertyID():int;										//取道具ID
		function getPropertyPrice(propertyCount:int = 0):int; 				//取道具价格
		function getPropertySendCharm():int;								//取道具赠送魅力
		function getPropertyRecvCharm():int;								//取道具接收魅力
		
		function execute():void;											//使用道具
	}
}