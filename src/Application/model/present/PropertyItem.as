package Application.model.present
{
	import Application.model.interfaces.IPropertyItem;
	import Application.model.vo.protocol.room.tagFlowerInfo;

	public class PropertyItem implements IPropertyItem
	{
		private var _propertyInfo:tagFlowerInfo;
		private var _propertyCount:int;
		
		public function PropertyItem()
		{
		}
		
		/**
		 * 设置道具数据
		 * @param propertyData
		 * 
		 */
		public function setPropertyData(propertyData:tagFlowerInfo):void
		{
			_propertyInfo = propertyData;
		}
		/**
		 * 设置道具数量
		 * @param count
		 * 
		 */
		public function setPropertyCount(count:int):void{
			_propertyCount = count;
		}
		/**
		 * 取道具数量
		 * @return 
		 * 
		 */
		public function getPropertyCount():int{
			return _propertyCount;
		}
		/**
		 * 取道具ID
		 * @return 
		 * 
		 */
		public function getPropertyID():int
		{
			if(_propertyInfo){
				return _propertyInfo.nFlowerID;
			} 
			return -1;
		}
		/**
		 * 取道具价格
		 * @param propertyCount
		 * @return 
		 * 
		 */
		public function getPropertyPrice(propertyCount:int = 1):int{
			//根据道具数据目及是否会员来决定道具价格
			
			return 0;
		}
		/**
		 * 取道具赠送魅力
		 * @return 
		 * 
		 */
		public function getPropertySendCharm():int{
			if(_propertyInfo){
				return _propertyInfo.lSendUserCharm;
			} 
			return 0;
		}
		/**
		 * 取道具接收魅力
		 * @return 
		 * 
		 */
		public function getPropertyRecvCharm():int{
			if(_propertyInfo){
				return _propertyInfo.lRcvUserCharm;
			} 
			return 0;
		}
		//////////////////////////////////////////////////////////////////
		//使用道具
		public function execute():void
		{
			
		}
	}
}