package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_ListenCard
	{
		public static const sizeof_CMD_S_ListenCard:uint = 2 + 1 + 1;
		
		public var wListenUser:uint;	//听牌用户word
		public var cbCardData:uint;		//牌数据byte			//不使用--因为之后会有outCard消息
		
		public function CMD_S_ListenCard()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_ListenCard
		{
			var result:CMD_S_ListenCard = new CMD_S_ListenCard();
			
			result.wListenUser = data.readUnsignedShort();	////听牌用户
			result.cbCardData = data.readUnsignedByte();	//牌数据
			
			return result;
		}
	}
}