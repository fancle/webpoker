package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_Trustee
	{
		public static const sizeof_CMD_S_Trustee:uint = 1 + 2;
		
		public var bTrustee:uint;	//是否托管
		public var wChairID:uint;	//托管用户
		
		public function CMD_S_Trustee()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_Trustee
		{
			var pos:int = data.position;
			var result:CMD_S_Trustee = new CMD_S_Trustee();
			
			result.bTrustee = data.readUnsignedInt();
			result.wChairID = data.readUnsignedShort();
			
			data.position = pos;
			return result;
		}

	}
}