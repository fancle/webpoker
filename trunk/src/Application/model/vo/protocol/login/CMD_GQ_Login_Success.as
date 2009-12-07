package Application.model.vo.protocol.login
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_Login_Success
	{
		public static const sizeof_CMD_GQ_Login_Success:uint = 2 + 1 + 1 + 1 + 3 + 4 + 4 + 4 + 4 + 4 + 4;
		//////////////////////////////////////////////////////////////////////////////////////////
		//属性资料
		public var wFaceID:uint;					//头像索引 WORD
		public var cbGender:uint;					//用户性别 BYTE	
		public var cbMember:uint;					//会员等级 BYTE	
		public var cbHonorLevel:uint;				//荣誉等级BYTE
		public var dwUserID:uint;					//用户 I D DWORD
		public var dwGameID:uint;					//游戏 I D DWORD
		public var dwExperience:uint;				//用户经验 DWORD
		public var dwCustomFaceVer:uint;			//头像版本 DWORD
		public var lGameGold:int;					//用户U豆long
		public var lGameUQ:int;						//用户LONG	UQ
		//////////////////////////////////////////////////////////////////////////////////////////
		public function CMD_GQ_Login_Success()
		{
		}
		
		public static function readData(bytes:ByteArray):CMD_GQ_Login_Success{
			var result:CMD_GQ_Login_Success = new CMD_GQ_Login_Success;
			
			result.wFaceID = bytes.readUnsignedShort();
			result.cbGender = bytes.readUnsignedByte();
			result.cbMember = bytes.readUnsignedByte();
			
			result.cbHonorLevel = bytes.readUnsignedByte();
			bytes.readShort();
			bytes.readByte();
			
			result.dwUserID =  bytes.readUnsignedInt();
			result.dwGameID = bytes.readUnsignedInt();
			result.dwExperience = bytes.readUnsignedInt();
			result.dwCustomFaceVer = bytes.readUnsignedInt();
			result.lGameGold = bytes.readInt();
			result.lGameUQ = bytes.readInt();
			
			return result;
		}
		
	}
}