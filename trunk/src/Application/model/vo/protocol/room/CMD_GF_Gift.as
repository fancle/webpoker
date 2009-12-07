package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GF_Gift
	{
		public static const sizeof_CMD_GF_Gift:int = 1 + 3 + 4 + 4 + 2 + 2;
		
		public var cbSendLocation:int;				//发送场所 BYTE
		public var dwSendUserID:uint;				//赠送者ID DWORD
		public var dwRcvUserID:uint;					//接受者ID DWORD
		public var wGiftID:int;						//礼物	ID WORD
		public var wFlowerCount:int;				//鲜花数目 WORD
		
		public function CMD_GF_Gift()
		{
		}
		
		public function toByteArray():ByteArray{
			var bytes:ByteArray = Memory.newLitteEndianByteArray();
			
			bytes.writeByte(cbSendLocation);
			bytes.writeByte(0);
			bytes.writeByte(0);
			bytes.writeByte(0);
			bytes.writeInt(dwSendUserID);
			bytes.writeInt(dwRcvUserID);
			bytes.writeShort(wGiftID);
			bytes.writeShort(wFlowerCount);
			
			return bytes;
		}
	}
}