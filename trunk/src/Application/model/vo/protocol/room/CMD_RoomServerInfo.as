package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_RoomServerInfo
	{
		public static const sizeof_CMD_RoomServerInfo:int = 2 + 2 + 4;
		
		public var wKindID:int;							//类型标识 WORD
		public var dwOnLineCount:int;					//在线人数DWORD
		
		public static function readData(bytes:ByteArray):CMD_RoomServerInfo{
			var result:CMD_RoomServerInfo = new CMD_RoomServerInfo;
			
			result.wKindID = bytes.readShort();
			bytes.readShort();
			
			result.dwOnLineCount = bytes.readInt(); 
			
			return result;
		}
		public function CMD_RoomServerInfo()
		{
		}

	}
}