package Application.model.interfaces
{
	import Application.model.vo.protocol.room.tagPropertyInfo;
	
	public interface IPresentManager
	{
		function hasProperty(preportyID:uint):Boolean;
		function addProperty(property:tagPropertyInfo):IPropertyItem;
		function getPropertyByID(propertyID:uint):IPropertyItem;
	}
}