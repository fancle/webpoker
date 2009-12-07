package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class tagUserStatus
	{
		public static const sizeof_tagUserStatus:uint = 4 + 2 + 2 + 1;
		public var dwUserID:uint;							//用户 ID DWORD
		public var wTableID:int;							//桌子位置 WORD
		public var wChairID:int;							//椅子位置 WORD
		public var cbUserStatus:uint;						//用户状态 BYTE
		
		public static function readData(bytes:ByteArray):tagUserStatus{
			var result:tagUserStatus = new tagUserStatus;
			
			result.dwUserID = bytes.readUnsignedInt();
			result.wTableID = bytes.readShort();
			result.wChairID = bytes.readShort();
			result.cbUserStatus = bytes.readUnsignedByte();
			
			return result;
		}
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeUnsignedInt(dwUserID);
			result.writeShort(wTableID);
			result.writeShort(wChairID);
			result.writeByte(cbUserStatus);
			
			return result;
		}
		public function tagUserStatus()
		{
		}

	}
}