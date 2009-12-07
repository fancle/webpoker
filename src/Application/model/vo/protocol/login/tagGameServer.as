package Application.model.vo.protocol.login
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class tagGameServer
	{
		public static const sizeof_tagGameServer:int = 2 + 2 + 2 + 2 + 2 + 2 + 4 + 4 + GlobalDef.SERVER_LEN;
		
		public var wSortID:uint;							//排序号码WORD								
		public var wKindID:uint;							//名称号码WORD								
		public var wServerID:uint;							//房间号码WORD								
		public var wStationID:uint;							//站点号码WORD								
		public var wServerPort:uint;						//房间端口WORD								
		public var dwServerAddr:uint;						//房间地址DWORD								
		public var dwOnLineCount:uint;						//在线人数DWORD								
		public var szServerName:String;						//房间名称TCHAR[SERVER_LEN]							
		
		public static function readData(bytes:ByteArray):tagGameServer{
			var result:tagGameServer = new tagGameServer;
			
			result.wSortID = bytes.readUnsignedShort();
			result.wKindID = bytes.readUnsignedShort();
			
			result.wServerID = bytes.readUnsignedShort();
			result.wStationID = bytes.readUnsignedShort();
			
			result.wServerPort = bytes.readUnsignedShort();
			bytes.readShort();//处理结构体边界对齐
						
			result.dwServerAddr = bytes.readUnsignedInt();
			result.dwOnLineCount = bytes.readUnsignedInt();
			
			result.szServerName = Memory.readStringByByteArray(bytes,GlobalDef.SERVER_LEN);
			
			return result;
		}
		
		public function tagGameServer()
		{
		}

	}
}