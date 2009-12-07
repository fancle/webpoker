package B_Sparrow.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	/**
	 * 出牌命令
	 */
	public class CMD_C_OutCard
	{
		public static const sizeof_CMD_C_OutCard:uint = 1 + 3 + 1 + 3;
		
		public var cbCardData:uint;		//扑克数据
		public var bIsTing:Boolean = false;		//是否是听牌
		
		public function CMD_C_OutCard()
		{
		}
		
		public function toByteArray():ByteArray
		{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeByte(cbCardData);
			result.writeShort(0);
			result.writeByte(0);
			
			result.writeBoolean(bIsTing);
			result.writeShort(0);
			result.writeByte(0);
			
			return result;
		}
	}
}