package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_TableInfo
	{
		//public static const sizeof_CMD_GR_TableInfo:int = 
		
		public var wTableCount:int;						//桌子数目WORD
		public var TableStatus:Array=new Array;			//状态数组tagTableStatus[512]
		
		public static function readData(bytes:ByteArray):CMD_GQ_TableInfo{
			var result:CMD_GQ_TableInfo = new CMD_GQ_TableInfo;
			
			result.wTableCount = bytes.readShort();
			for(var i:int = 0; i<result.wTableCount; i++){
				result.TableStatus.push(tagTableStatus.readData(bytes));
			}
			
			return result;
		}
		
		public function CMD_GQ_TableInfo()
		{
		}

	}
}