package B_Sparrow.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_C_OperateCard
	{
		public static const sizeof_CMD_C_OperateCard:int = 2 + 1 + 1 ;
		
		public var cbOperateCode:uint;						//操作代码WORD
		public var cbOperateCard:uint = 0;						//操作扑克BYTE
				
		public function CMD_C_OperateCard()
		{
		}
		
		public function toByteArray():ByteArray
		{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			result.writeShort(cbOperateCode);
			result.writeByte(cbOperateCard);
			result.writeByte(0);
			return result;
		}

	}
}