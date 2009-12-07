package Application.model.interfaces
{
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserScore;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	public interface IUserItem
	{
		function set m_UserData(userData:tagUserData):void;
		function set m_bActive(b:Boolean):void;
		//访问判断
		function IsActive():Boolean;

		//////////////////////////////////////////////////////////////////////////
		//获取用户
		function GetUserData():tagUserData;
		//获取用户头像索引
		function GetUserFaceID():uint
		//用户 I D
		function GetUserID():uint;
		//用户名字
		function GetUserName():String;
		//用户状态
		function GetUserStatus():tagUserStatus;
		//游戏局数
		function GetUserPlayCount():uint;
		

		//////////////////////////////////////////////////////////////////////////
		//设置积分
		function SetUserScore(pUserScore:tagUserScore):void;
		//设置状态
		function SetUserStatus(pUserStatus:tagUserStatus):void;
	}
}