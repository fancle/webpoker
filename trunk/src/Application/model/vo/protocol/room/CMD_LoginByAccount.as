package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	public class CMD_LoginByAccount
	{
		public static const sizeof_CMD_LoginByAccountCmd:int = 4 + 4 + GlobalDef.NAME_LEN + GlobalDef.PASS_LEN;
		
		public var dwPlazaVersion:uint= GlobalDef.VER_PLAZA_LOW | (GlobalDef.VER_PLAZA_HIGH<<16);//广场版本 DWORD
		public var dwProcessVersion:uint = 0;					//进程版本 DWORD
		public var szAccounts:String;						//登录帐号 TCHAR[NAME_LEN]
		public var szPassWord:String;				//登录密码 TCHAR[PASS_LEN]
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeUnsignedInt(dwPlazaVersion);
			result.writeUnsignedInt(dwProcessVersion);
			Memory.writeStringToByteArray(result,szAccounts,GlobalDef.NAME_LEN);
			Memory.writeStringToByteArray(result,szPassWord,GlobalDef.PASS_LEN);
			
			return result;
		}
		
		public function CMD_LoginByAccount()
		{
		}

	}
}