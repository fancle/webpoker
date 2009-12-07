package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class tagColumnItem
	{
		public static const sizeof_tagColumnItem:int = 2 + 2 + 2 + 16;
		
		public var wColumnWidth:int;						//列表宽度 WORD
		public var wDataDescribe:int;						//字段类型 WORD
		public var wFlag:int;								//在房间还是游戏显示的标识　0x01 0x02 0x03 二进制第一位房间显示，第二位为游戏显示
		public var szColumnName:String;						//列表名字 TCHAR[16]
		
		public static function readData(bytes:ByteArray):tagColumnItem{
			var result:tagColumnItem = new tagColumnItem;
			
			result.wColumnWidth = bytes.readShort();
			result.wDataDescribe = bytes.readShort();
			result.wFlag = bytes.readShort();
			result.szColumnName = Memory.readStringByByteArray(bytes,16);			
			
			return result;
		}
		
		public function tagColumnItem()
		{
		}

	}
}