package B_Land.common
{
	import flash.utils.ByteArray;
	//发送扑克
	public class CMD_S_SendCard
	{
		public static const sizeof_CMD_S_SendCard:uint = 2  + 17 + 1;
		public var wCurrentUser:uint;//当前玩家
		public var bCardData:Array = new Array(17);//扑克列表
		public function CMD_S_SendCard()
		{
		}
		public static function readData(data:ByteArray):CMD_S_SendCard
		{
			var result:CMD_S_SendCard=new CMD_S_SendCard;
			
			result.wCurrentUser = data.readUnsignedShort();
			for(var i:uint = 0; i < result.bCardData.length;i ++)
			{
				result.bCardData[i] = data.readUnsignedByte();
			}
			
			return result;
		}
	}
}