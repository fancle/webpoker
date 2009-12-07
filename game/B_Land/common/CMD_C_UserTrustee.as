package B_Land.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_C_UserTrustee
	{
		public static const sizeof_CMD_C_UserTrustee:int = 2 + 1 + 1;
		
		public var wUserChairID:int;						//玩家椅子WORD
		public var bTrustee:Boolean;						//托管标识bool
		
		public static function readData(data:ByteArray):CMD_C_UserTrustee
		{
			var result:CMD_C_UserTrustee = new CMD_C_UserTrustee;
			
			result.wUserChairID = data.readShort();
			result.bTrustee = data.readBoolean();
			
			return result;
		}
		
		public function toByteArray():ByteArray
		{
			var bytes:ByteArray = Memory.newLitteEndianByteArray();
			
			bytes.writeShort(this.wUserChairID);
			bytes.writeBoolean(this.bTrustee);
			bytes.writeByte(0);//补齐
			
			return bytes;
		}
		
		public function CMD_C_UserTrustee()
		{
		}

	}
}