package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_OutCard
	{
		public static const sizeof_CMD_S_OutCard:uint = 2 + 2 + 1 + 1 + 2 + 1 + 3;
		
		public var wCurrentUser:uint;//当前用户word		不使用---接牌用户
		public var wOutCardUser:uint;//出牌用户word		使用
		public var cbOutSparrowData:uint;//出牌扑克byte	使用
		public var cbCurrentCard:uint;//当前扑克byte		不使用---接牌数据
		public var bIsTing:Boolean;//是否停boolean		不使用
		
		public function CMD_S_OutCard()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_OutCard
		{
			var result:CMD_S_OutCard = new CMD_S_OutCard();
			
			result.wCurrentUser = data.readUnsignedShort();
			result.wOutCardUser = data.readUnsignedShort();
			result.cbOutSparrowData = data.readUnsignedByte();
			result.cbCurrentCard = data.readUnsignedByte();
			data.readShort();
			result.bIsTing = data.readBoolean();
			
			return result;
		}
	}
}