package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_GameStart
	{
		public static const sizeof_CMD_S_GameStart:uint = 2 + 2 + 2 + 2 + 1 * 14;
		
		public var wSiceCount:uint;//骰子点数
		public var wSiceUserCount:uint;//选择用户的骰子点数
		public var wBankerUser:uint;//庄家用户
		public var wCurrentUser:uint;//当前用户
		public var cbCardData:Array = new Array(14);	//扑克列表
		//public var bTrustee:Array = new Array(2);	//是否托管
		
		public function CMD_S_GameStart()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_GameStart
		{
			var result:CMD_S_GameStart = new CMD_S_GameStart;
			
			result.wSiceCount = data.readUnsignedShort();//骰子点数
			result.wSiceUserCount = data.readUnsignedShort();//选择用户的骰子点数
			result.wBankerUser = data.readUnsignedShort();//庄家用户
			result.wCurrentUser = data.readUnsignedShort();//当前用户			
			for(var i:uint = 0; i < result.cbCardData.length; i++)
			{
				result.cbCardData[i] = data.readUnsignedByte();//扑克列表
			}
			
			/* for(i = 0; i < result.bTrustee.length; i++)
			{
				result.bTrustee[i] = data.readUnsignedByte();
			} */
			
			return result;
		}
	}
}