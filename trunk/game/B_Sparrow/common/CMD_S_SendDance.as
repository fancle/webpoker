package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_SendDance
	{
		public static const sizeof_CMD_S_SendDance:uint = 2 + 1*14 + 1;
		public var wCurrentUser:uint;				//当前用户word		//明听用户
		public var cbCardList:Array = new Array(14);//扑克列表byte[14]	//明牌
		public var cbCardData:uint;					//扑克数据byte		//不使用--因为之后会有outCard命令
		
		public function CMD_S_SendDance()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_SendDance
		{
			var result:CMD_S_SendDance = new CMD_S_SendDance;
			
			result.wCurrentUser = data.readUnsignedShort();
			for(var i:int = 0; i<14; i++){
				result.cbCardList[i] = data.readUnsignedByte();
			}
			result.cbCardData = data.readUnsignedByte();
			
			return result;
		}
	}
}