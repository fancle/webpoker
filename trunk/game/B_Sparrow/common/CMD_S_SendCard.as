package B_Sparrow.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_S_SendCard
	{
		public static const sizeof_CMD_S_SendCard:uint = 1 + 1 + 2;
		
		public var cbCardData:uint;//扑克数据
		public var wCurrentUser:uint;//当前用户
		
		public function CMD_S_SendCard()
		{
		}
		public static function readData(data:ByteArray):CMD_S_SendCard
		{
			var result:CMD_S_SendCard = new CMD_S_SendCard;
			
			result.cbCardData = data.readUnsignedByte();
								data.readByte();//补齐
			result.wCurrentUser = data.readUnsignedShort();
			
			return result;
		}
		public function toByteArray():ByteArray
		{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeByte(cbCardData);
			result.writeByte(0);
			result.writeShort(wCurrentUser);
			result.position = 0;
			
			return result;
		}
	}
}