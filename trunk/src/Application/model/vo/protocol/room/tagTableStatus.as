package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class tagTableStatus
	{
		public static const sizeof_tagTableStatus:int = 1 + 1;
		
		public var bTableLock:Boolean;						//锁定状态BYTE	
		public var bPlayStatus:Boolean;						//游戏状态BYTE	
		
		public static function readData(bytes:ByteArray):tagTableStatus{
			var result:tagTableStatus = new tagTableStatus;
			
			result.bTableLock = bytes.readBoolean();
			result.bPlayStatus = bytes.readBoolean();
			
			return result;
		}
		
		public function tagTableStatus()
		{
		}

	}
}