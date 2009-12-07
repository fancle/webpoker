package B_Land.common
{
	import flash.utils.ByteArray;
	//用户叫分
	public class CMD_S_LandScore
	{
		public static const sizeof_CMD_S_LandScore:uint = 2 + 2 + 1 + 1;
		public var wLandUser:uint;//叫分玩家
		public var wCurrentUser:uint;//当前玩家
		public var bLandScore:uint;//上次叫分
		public var bCurrentScore:uint;//当前叫分
		public function CMD_S_LandScore()
		{
		}
		public static function readData(data:ByteArray):CMD_S_LandScore
		{
			var result:CMD_S_LandScore=new CMD_S_LandScore;
			result.wLandUser = data.readUnsignedShort();
			result.wCurrentUser = data.readUnsignedShort();
			result.bLandScore = data.readUnsignedByte();
			result.bCurrentScore = data.readUnsignedByte();
			
			return result;
		}
	}
}