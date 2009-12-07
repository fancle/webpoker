package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_WeaveItem
	{
		public static const sizeof_CMD_WeaveItem:uint = 1 + 1 + 1 + 2;
		
		public var cbWeaveKind:uint;//组合类型
		public var cbCenterCard:uint;//中心扑克
		public var cbPublicCard:uint;//公开标志
		public var wProvideUser:uint;//供应用户
		
		public function CMD_WeaveItem()
		{
		}
		
		public static function readData(data:ByteArray):CMD_WeaveItem
		{
			var result:CMD_WeaveItem = new CMD_WeaveItem();
			result.cbWeaveKind = data.readUnsignedByte();
			result.cbCenterCard = data.readUnsignedByte();
			result.cbPublicCard = data.readUnsignedByte();
			result.wProvideUser = data.readUnsignedShort();
			return result;
		}
	}
}