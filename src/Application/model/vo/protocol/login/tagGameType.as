package Application.model.vo.protocol.login
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class tagGameType
	{
		public static const sizeof_tagGameType:int = 2 + 2 + GlobalDef.TYPE_LEN;
		
		public var wSortID:uint;							//排序号码 WORD
		public var wTypeID:uint;							//种类号码WORD
		public var szTypeName:String;						//种类名字TCHAR[TYPE_LEN]
		
		public static function readData(bytes:ByteArray):tagGameType{
			var result:tagGameType = new tagGameType;
			
			result.wSortID = bytes.readUnsignedShort();
			result.wTypeID = bytes.readUnsignedShort();
			result.szTypeName = Memory.readStringByByteArray(bytes,GlobalDef.TYPE_LEN);
			
			return result;
		}
		
		public function tagGameType()
		{
		}

	}
}