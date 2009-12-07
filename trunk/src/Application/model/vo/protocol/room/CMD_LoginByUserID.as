package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class CMD_LoginByUserID
	{
		public static const sizeof_CMD_LoginByUserID:int = 4 + 4 + 4 + GlobalDef.PASS_LEN;
		//public static const sizeof_CMD_LoginByUserID:int = 4 + 4 + 4 + 4 + GlobalDef.PASS_LEN;
		
		public var dwPlazaVersion:uint;														//广场版本 DWORD
		public var dwProcessVersion:uint;													//进程版本 DWORD
		//public var dwClientLogo:uint;														//客户端标志 DWORD
		public var dwUserID:uint;															//用户 I D DWORD
		public var szPassWord:String;														//登录密码 TCHAR[PASS_LEN]
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeUnsignedInt(dwPlazaVersion);
			result.writeUnsignedInt(dwProcessVersion);
			//result.writeUnsignedInt(dwClientLogo);
			result.writeUnsignedInt(dwUserID);
			Memory.writeStringToByteArray(result,szPassWord,GlobalDef.PASS_LEN);
			
			return result;
		}
		
		public function CMD_LoginByUserID()
		{
		}

	}
}