package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_ColumnInfo
	{
		//public static const sizeof_CMD_GQ_ColumnInfo:int = ;
		
		public var wColumnCount:uint;						//列表数目 WORD
		public var ColumnItem:Array = new Array(32);						//列表描述 tagColumnItem
		
		public static function readData(bytes:ByteArray):CMD_GQ_ColumnInfo{
			var result:CMD_GQ_ColumnInfo = new CMD_GQ_ColumnInfo;
			
			result.wColumnCount = bytes.readUnsignedShort();
			for(var i:int = 0; i<result.wColumnCount; i++){
				result.ColumnItem[i] = tagColumnItem.readData(bytes);
			}
			
			return result;
		}
		public function CMD_GQ_ColumnInfo()
		{
		}

	}
}