package Application.model.vo.protocol.login
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class tagGameKind
	{
		public static const sizeof_tagGameKind:uint = 2 + 2 + 2 + 2 + 4 + 4 + GlobalDef.KIND_LEN + GlobalDef.MODULE_LEN;
		
		public var wSortID:uint;							//排序号码 WORD
		public var wTypeID:uint;							//类型号码 WORD
		public var wKindID:uint;							//名称号码 WORD
		public var dwMaxVersion:uint;						//最新版本 DWORD
		public var dwOnLineCount:uint;						//在线数目 DWORD
		public var szKindName:String;						//游戏名字TCHAR[KIND_LEN]
		public var szProcessName:String;					//进程名字TCHAR[MODULE_LEN]
		
		public static function readData(bytes:ByteArray):tagGameKind{
			var result:tagGameKind=new tagGameKind;
			
			result.wSortID = bytes.readUnsignedShort();
			result.wTypeID = bytes.readUnsignedShort();
			
			result.wKindID = bytes.readUnsignedShort();
			bytes.readShort();//处理结构体边界对齐
			
			result.dwMaxVersion = bytes.readUnsignedInt();
			result.dwOnLineCount = bytes.readUnsignedInt();			
			result.szKindName = Memory.readStringByByteArray(bytes,GlobalDef.KIND_LEN);
			result.szProcessName = Memory.readStringByByteArray(bytes,GlobalDef.MODULE_LEN);
			
			return result;
		}
		public function tagGameKind()
		{
		}

	}
}