package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_StatusFree
	{
		public static const sizeof_CMD_S_StatusFree:uint = 4 + 2 + 1;
		
		public var fCellScore:int = 0;				//基础货币
		public var wBankerUser:uint;				//庄家用户
		public var bTrustee:Array = new Array(2);
		
		public function CMD_S_StatusFree()
		{
			
		} 
		
		public static function readData(data:ByteArray):CMD_S_StatusFree
		{
			var pos:int = data.position;
			var result:CMD_S_StatusFree = new CMD_S_StatusFree;
			result.fCellScore = data.readDouble();
			result.wBankerUser = data.readUnsignedInt();

			for(var i:uint = 0; result.bTrustee.length; i++)
			{
				result.bTrustee[i] = data.readUnsignedInt();
			}
			
			data.position = pos;
			return result;	
		}

	}
}