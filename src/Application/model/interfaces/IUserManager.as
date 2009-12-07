package Application.model.interfaces
{
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import __AS3__.vec.Vector;
	
	public interface IUserManager
	{
		//管理接口

		//增加用户
		function ActiveUserItem(UserData:tagUserData):IUserItem;
		//删除用户
		function DeleteUserItem(pIUserItem:IUserItem):Boolean;
		//删除全部用户
		function DeleteAllUserItem():void;
		//更新积分
 		//function UpdateUserItemScore(IUserItem * pIUserItem, pUserScore:tagUserScore):Boolean;
		//更新状态
		function UpdateUserItemStatus(pIUserItem:IUserItem, pUserStatus:tagUserStatus):Boolean;

		//信息接口

		//获取人数
		function GetOnLineCount():int;
		function getUserItemList():Vector.<IUserItem>;
		function getUserListByTableID(tableID:int):Vector.<IUserItem>;
		function getMeItem():IUserItem;
		//查找接口

		//枚举用户
		function EnumUserItem(wEnumIndex:uint):IUserItem;
		//查找用户
		function SearchUserByUserID(dwUserID:uint):IUserItem;
		//查找用户
		function SearchUserByGameID(dwUserID:uint):IUserItem;
	}
}