package Application.model.vo.protocol.login
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class CMD_GP_Login
	{
		public static const sizeof_CMD_GP_Login:uint = 4 + GlobalDef.NAME_LEN + GlobalDef.PASS_LEN;
		
		public var dwPlazaVersion:uint= GlobalDef.VER_PLAZA_LOW | (GlobalDef.VER_PLAZA_HIGH<<16); //广场版本 DWORD
		public var strUser_name:String; //登录帐号 TCHAR[NAME_LEN]
		public var strPassword:String; //登录密码 TCHAR[PASS_LEN]

		
		public function CMD_GP_Login()
		{
		}
		
		public function toByteArray():ByteArray{
			var result:ByteArray=Memory.newLitteEndianByteArray();
			result.writeInt(dwPlazaVersion);
			Memory.writeStringToByteArray(result,strUser_name,GlobalDef.NAME_LEN);
			Memory.writeStringToByteArray(result,strPassword,GlobalDef.PASS_LEN);
			
			return result;
		}

	}
}