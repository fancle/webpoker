package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_TableStatus
	{
		public static const sizeof_CMD_GQ_TableStatus:int = 2 + 1 + 1;
		
		public var wTableID:int;							//桌子号码WORD		
		public var bTableLock:Boolean;						//锁定状态BYTE	
		public var bPlayStatus:Boolean;						//游戏状态BYTE	
		
		public static function readData(bytes:ByteArray):CMD_GQ_TableStatus{
			var result:CMD_GQ_TableStatus = new CMD_GQ_TableStatus;
			
			result.wTableID = bytes.readShort();
			result.bTableLock = bytes.readBoolean();
			result.bPlayStatus = bytes.readBoolean();
			
			return result;			
		}
		
		public function CMD_GQ_TableStatus()
		{
		}

	}
}