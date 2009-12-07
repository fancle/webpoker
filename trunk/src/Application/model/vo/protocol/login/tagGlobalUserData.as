package Application.model.vo.protocol.login
{
	import common.data.GlobalDef;
	
	public class tagGlobalUserData
	{
		//属性资料
		public static var dwUserID:uint;							//用户标识 DWORD
		public static var dwGameID:uint;							//游戏标识 DWORD
		public static var dwExperience:uint;						//经验数值 DWORD
		public static var szPassword:String;						//登录密码 TCHAR[PASS_LEN]
		public static var szAccounts:String;						//登录帐号 TCHAR[NAME_LEN]

		//用户资料
		public static var wFaceID:uint;								//头像标识 WORD
		public static var cbGender:uint;							//用户性别 BYTE
		public static var dwCustomFaceVer:uint;						//头像版本 DWORD
		public static var cbMember:uint;							//会员等级 BYTE
		public static var cbHonorLevel:uint;						//荣誉等级BYTE
		public static var szUnderWrite:String;						//个性签名 TCHAR[UNDER_WRITE_LEN]
		public static var lGameGold:int;                        	//用户U豆 LONG
		public static var lUserUQ:int;								//用户U券 LONG

		//描述信息
		public static var szDescribeString:String;					//描述消息 TCHAR[128]
		public static var szNickName:String;						//用户昵称 TCHAR[NAME_LEN]
		
		
		
		public function tagGlobalUserData()
		{
		}

	}
}