package Application.model.present
{
	import Application.model.interfaces.IPropertyItem;
	import Application.model.vo.protocol.room.tagFlowerInfo;
	
	import __AS3__.vec.Vector;
	
	public class PresentManager
	{
		private static var instance:PresentManager = null;
		
		private var arr_property:Vector.<IPropertyItem>;
		
		private var _currentProperty:IPropertyItem = null;
		
		public static function getInstance():PresentManager{
			if(!instance){
				instance = new PresentManager;
			}
			return instance;			
		}
		public function PresentManager()
		{
			if(instance) throw new Error("PresentManager is signal class!");
			arr_property = new Vector.<IPropertyItem>();
		}
		
		//////////////////////////////////////////////////////////////////////
		/**
		 * 是否有指定道具
		 * @param propertyID
		 * @return 
		 * 
		 */
		public function hasProperty(propertyID:uint):Boolean{
			var has_Prop:Boolean = false;
			for each(var propertyItem:IPropertyItem in arr_property){
				if(propertyItem.getPropertyID() == propertyID){
					has_Prop = true;
					break;
				}
			}
			return has_Prop;
		}
		
		/**
		 * 添加道具
		 * @param property
		 * @return 
		 * 
		 */
		public function addProperty(property:tagFlowerInfo):IPropertyItem
		{
			var propertyItem:IPropertyItem;
			if(!hasProperty(property.nFlowerID)){
				propertyItem = new PropertyItem();
				propertyItem.setPropertyData(property);
				arr_property.push(propertyItem);
			}
			else{
				propertyItem = getPropertyByID(property.nFlowerID);
			}
			return propertyItem;
		}
		
		public function getAllProperty():Vector.<IPropertyItem>{
			return arr_property;
		}
		/**
		 * 根据道具ID取得道具
		 * @param propertyID
		 * @return 
		 * 
		 */
		public function getPropertyByID(propertyID:uint):IPropertyItem
		{
			for each(var item:IPropertyItem in arr_property){
				if(item.getPropertyID() == propertyID){
					return item;
				}
			}
			
			return null;
		}
		
		/**
		 * 取得当前使用道具
		 * @return 
		 * 
		 */
		public function getCurrentProperty():IPropertyItem
		{
			return _currentProperty;
		}
		
		/**
		 * 设置当前使用道具
		 * @param prop
		 * 
		 */
		public function setCurrentProperty(propID:int):void
		{
			var prop:IPropertyItem = getPropertyByID(propID);
			_currentProperty = prop;
		}
	}
}