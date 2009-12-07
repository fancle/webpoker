package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GF_GiftNotify
	{
		public static const sizeof_CMD_GF_GiftNotify:int = 1 + 3 + 4 + 4 + 2 + 2 + 2 + 2 + 2 + 2;
		
		public var cbSendLocation:int;				//发送场所 BYTE
		public var dwSendUserID:uint;				//赠送者ID DWORD
		public var dwRcvUserID:uint;					//接受者ID DWORD
		public var wGiftID:int;						//礼物	ID WORD
		public var wFlowerCount:int = 0;				//鲜花数目 WORD
		public var WRecverLoveliness:int = 0;			//接受者总魅力值 WORD
		public var WSenderFlowerCount = 0; 				//赠送者身上剩余道具数目 WORD
		public var WSenderGameGoldCount:int = 0;		//赠送者身上的 UD WORD

		public function CMD_GF_GiftNotify()
		{
		}
		
		public static function readData(data:ByteArray):CMD_GF_GiftNotify{
			var result:CMD_GF_GiftNotify = new CMD_GF_GiftNotify;
			
			result.cbSendLocation = data.readByte();
			data.readByte();
			data.readShort();
			
			result.dwSendUserID = data.readUnsignedInt();
			result.dwRcvUserID = data.readUnsignedInt();
			result.wGiftID = data.readShort();
			result.wFlowerCount = data.readShort();
			result.WRecverLoveliness = data.readShort();
			result.WSenderFlowerCount = data.readShort();
			result.WSenderGameGoldCount = data.readShort();
			
			return result;
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
			bytes.writeShort(WRecverLoveliness);
			bytes.writeShort(WSenderFlowerCount);
			bytes.writeShort(WSenderGameGoldCount);
			bytes.writeShort(0);
			
			return bytes;
		}

	}
}