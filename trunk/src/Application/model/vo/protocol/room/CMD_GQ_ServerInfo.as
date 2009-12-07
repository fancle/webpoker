package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_ServerInfo
	{
		public static const sizeof_CMD_GQ_ServerInfo:int = 2 + 2 + 2 + 2 + 4 + 2 + 1;
		//房间属性
		public var wKindID:uint;							//类型 I D WORD
		public var wTableCount:uint;						//桌子数目 WORD
		public var wChairCount:uint;						//椅子数目 WORD
		public var dwVideoAddr:uint;						//视频地址 DWORD
		//扩展配置
		public var wGameGenre:uint;							//游戏类型 WORD	
		public var cbHideUserInfo:uint;						//隐藏信息 BYTE
		
		public static function readData(bytes:ByteArray):CMD_GQ_ServerInfo{
			var result:CMD_GQ_ServerInfo = new CMD_GQ_ServerInfo;
			
			result.wKindID = bytes.readUnsignedShort();
			result.wTableCount = bytes.readUnsignedShort();
			
			result.wChairCount = bytes.readUnsignedShort();
			bytes.readUnsignedShort();//
			
			result.dwVideoAddr = bytes.readUnsignedInt();
			
			result.wGameGenre = bytes.readUnsignedShort();
			result.cbHideUserInfo = bytes.readUnsignedByte();
			
			return result;
		}
		public function CMD_GQ_ServerInfo()
		{
		}

	}
}