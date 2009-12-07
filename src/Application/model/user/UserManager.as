package Application.model.user
{
	import Application.model.interfaces.IUserItem;
	import Application.model.interfaces.IUserManager;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import __AS3__.vec.Vector;
	
	import common.data.GlobalDef;

	public class UserManager implements IUserManager
	{
		private static var instance:UserManager;
		
		private var arr_m_UserItemActive:Vector.<IUserItem> = new Vector.<IUserItem>;//活动数组
		private var arr_m_UserItemStorage:Vector.<IUserItem> = new Vector.<IUserItem>;//存储数组
		
		public static function getInstance():UserManager{
			if(instance==null){
				instance = new UserManager;
			}
			return instance;
		}
		
		public function UserManager()
		{
			if(instance!=null){
				throw Error("UserManger is a signleInstance!");
			}
		}

		public function ActiveUserItem(UserData:tagUserData):IUserItem
		{
			var pUserItem:UserItem
			
			pUserItem = new UserItem;
			pUserItem.m_UserData = UserData;
			
			arr_m_UserItemActive.push(pUserItem);
			 
			return pUserItem;
		}
		
		public function DeleteUserItem(pIUserItem:IUserItem):Boolean
		{
			var bSuccess:Boolean = false;
			
			for(var key:String in arr_m_UserItemActive){
				var _pUserItem:IUserItem = arr_m_UserItemActive[key] as IUserItem;
				
				if(_pUserItem == pIUserItem){
					arr_m_UserItemActive.splice(int(key),1);
					bSuccess = true;
					break;
				}
			}
			return bSuccess;
		}
		public function DeleteAllUserItem():void{
			arr_m_UserItemActive.splice(0,arr_m_UserItemActive.length);
		}
		/* public function UpdateUserItemScore(IUserItem:, pIUserItem:, pUserScore:tagUserScore):Boolean
		{
			return false;
		} */
		
		public function UpdateUserItemStatus(pIUserItem:IUserItem, pUserStatus:tagUserStatus):Boolean
		{
			return false;
		}
		
		public function GetOnLineCount():int
		{
			return arr_m_UserItemActive.length;
		}
		
		public function getUserItemList():Vector.<IUserItem>{
			return arr_m_UserItemActive;
		}
		
		//获取同桌玩家
		public function getUserListByTableID(tableID:int):Vector.<IUserItem>{
			if(tableID == GlobalDef.INVALID_TABLE) return null;
			
			var v:Vector.<IUserItem> = new Vector.<IUserItem>();
			for each(var pUserItem:IUserItem in arr_m_UserItemActive){
				if(pUserItem.GetUserStatus().wTableID == tableID){
					v.push(pUserItem);
				}
			}
			return v;
		}
		
		//得到自己		
		public function getMeItem():IUserItem{
			return SearchUserByUserID(tagGlobalUserData.dwUserID);
		}
		
		public function EnumUserItem(wEnumIndex:uint):IUserItem
		{
			return null;
		}
		
		public function SearchUserByUserID(dwUserID:uint):IUserItem
		{
			var pUserItem:UserItem;
			for each(var keyuser:IUserItem in arr_m_UserItemActive){
				if(dwUserID == keyuser.GetUserID()) return keyuser;
			}
			return null;
		}
		
		public function SearchUserByGameID(dwUserID:uint):IUserItem
		{
			return null;
		}
		
	}
}