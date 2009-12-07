package B_Sparrow.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_C_Trustee
	{
		public static const sizeof_CMD_C_Trustee:uint = 1;
		public var bTrustee:uint;		//是否托管
		
		public function CMD_C_Trustee()
		{
		}
		
		public function toByteArray():ByteArray
		{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			result.writeBoolean(bTrustee);
			return result;	
		}
	}
}