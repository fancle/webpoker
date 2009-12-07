package Application.model.user
{
	import Application.model.interfaces.IUserItem;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserScore;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import mx.utils.ObjectUtil;

	public class UserItem implements IUserItem
	{
		private var _m_UserData:tagUserData;
		private var _m_bActive:Boolean = true;
		
		public function set m_UserData(userData:tagUserData):void
		{
			_m_UserData = userData;
		}
		
		public function set m_bActive(b:Boolean):void{
			_m_bActive = b;
		}
		
		///////////////////////////////////////////////////////////	
		public function UserItem()
		{
		}

		
		public function IsActive():Boolean
		{
			return _m_bActive;
		}
		//获取用户
		public function GetUserData():tagUserData
		{
			return _m_UserData;
		}
		public function GetUserFaceID():uint{
			return _m_UserData.wFaceID;
		}
		//获取用户ID
		public function GetUserID():uint
		{
			if(_m_UserData) return _m_UserData.dwUserID;
			return 0;
		}
		//获取用户名称
		public function GetUserName():String
		{
			if(_m_UserData) return _m_UserData.szName;
			return null;
		}
		//
		public function GetUserStatus():tagUserStatus{
			var userStatus:tagUserStatus = new tagUserStatus;
			
			userStatus.dwUserID = _m_UserData.dwUserID;
			userStatus.wTableID = _m_UserData.wTableID;
			userStatus.wChairID = _m_UserData.wChairID;
			userStatus.cbUserStatus = _m_UserData.cbUserStatus;
			
			return userStatus;
		}
		//获取游戏局数
		public function GetUserPlayCount():uint
		{
			return 0;
		}
		//////////////////////////////////////////////////////////////////////////
		//设置游戏积分		
		public function SetUserScore(pUserScore:tagUserScore):void
		{
			if(pUserScore){
				var classInfo:Object =ObjectUtil.getClassInfo(pUserScore);
				var arr:Array = classInfo["properties"];
				for each(var key:String in arr){
					if(_m_UserData.hasOwnProperty(key)&&(pUserScore.hasOwnProperty(key))){
						_m_UserData[key] = pUserScore[key];
					}
				}
			}
		}
		//设置用户状态
		public function SetUserStatus(pUserStatus:tagUserStatus):void
		{
			if(pUserStatus){
				_m_UserData.wTableID = pUserStatus.wTableID;
				_m_UserData.wChairID = pUserStatus.wChairID;
				_m_UserData.cbUserStatus = pUserStatus.cbUserStatus;
			}
		}
		
	}
}