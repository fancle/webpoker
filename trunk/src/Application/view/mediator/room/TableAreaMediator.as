package Application.view.mediator.room
{
	import Application.NotificationString;
	import Application.control.net.room.CMD_RoomTableCmd;
	import Application.control.net.room.CMD_RoomUserCmd;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.user.UserItem;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	import Application.model.vo.protocol.room.CMD_GQ_TableInfo;
	import Application.model.vo.protocol.room.CMD_GQ_TableStatus;
	import Application.model.vo.protocol.room.tagTableStatus;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	import Application.utils.FaceMap;
	import Application.view.mediator.gameframe.GameFrameMediator;
	
	import chair.ITableView;
	import chair.LandLordTableView;
	import chair.MahjongTableView;
	
	import common.assets.ModuleLib;
	import common.data.CMD_DEF_ROOM;
	import common.data.CommonEvent;
	import common.data.GameTypeConfig;
	import common.data.GlobalDef;
	import common.data.gameEvent;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	
	import mx.containers.Tile;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TableAreaMediator extends Mediator implements IMediator
	{
		public static const NAME:String="TableAreaMediator";

		private var _tableHash:HashMap=new HashMap();
		private var gameName:String; //反射的类名

		public function TableAreaMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
	
		}

		override public function getMediatorName():String
		{
			return NAME;
		}

		override public function getViewComponent():Object
		{
			return viewComponent;
		}

		public function get view():Tile
		{
			return viewComponent as Tile;
		}

		override public function setViewComponent(viewComponent:Object):void
		{
		}

		override public function listNotificationInterests():Array
		{
			return [NotificationString.GAME_ROOM_INIT_DATA,
				    NotificationString.GAME_ROOM_DATA,
				    NotificationString.ROOM_SOCKET_CLOSE,
				    NotificationString.GAME_ROOM_SUCCESS
				    ];
		}

		/**
		 *
		 * @param notification
		 */
		override public function handleNotification(notification:INotification):void
		{
			switch (notification.getName())
			{
				case NotificationString.GAME_ROOM_INIT_DATA:
				{
					switch (notification.getType())
					{
						case "CMD_GQ_ServerInfo":
						{
							initTables(notification.getBody() as CMD_GQ_ServerInfo);
							break;
						}
					}
					break;
				}
				case NotificationString.GAME_ROOM_DATA:
					switch(notification.getType()){
						case "user_come":
							listAddData(notification.getBody() as UserItem);
							break;
						case "user_status":   
							changeStatue(notification.getBody() as Object);
							
							break;
						case CMD_RoomTableCmd.TABLE_STATUS:	//单个桌子状态			   
							changeTableStatue(notification.getBody() as CMD_GQ_TableStatus);
							break;
						case CMD_RoomTableCmd.TABLE_INFO: //桌子状态列表
							configTables(notification.getBody() as CMD_GQ_TableInfo);
							break;
						case CMD_RoomUserCmd.USER_SIT_FAILED://坐椅上失败
					
							break;
					}
					break;
				case NotificationString.ROOM_SOCKET_CLOSE:
					clearTableArea();
					break;
				case NotificationString.GAME_ROOM_SUCCESS:
				{
					if((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre==GlobalDef.GAME_GENRE_MATCH){
						loginGame();
					}
					break;
				}
			}
		}
		
		private function listAddData(value:UserItem):void
		{
			var userData:tagUserData=value.GetUserData();
			var headMap:BitmapData = FaceMap.getInstance().getFace(userData.wFaceID);
			if(GlobalDef.DEBUG)trace("in TableAreaMediator listAddData: userDataszName = " + userData.szName);
			if(GlobalDef.DEBUG)trace("in TableAreaMediator listAddData: userData.cbUserStatus = " + userData.cbUserStatus);
			if(userData.cbUserStatus>GlobalDef.US_FREE){
				setSitDown(userData.wTableID,userData.wChairID,headMap,userData.szName,userData.dwUserID);
			}			
		
		}
		/**
		 *
		 * 改变用户状态
		 */
		private function changeStatue(value:Object):void
		{
			var user:tagUserStatus=value["userNowStatus"];
			var preUser:tagUserStatus=value["userPreStatus"];
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(user.dwUserID);
			switch (user.cbUserStatus)
			{
				case GlobalDef.US_NULL: //没有状态			

					break;
				case GlobalDef.US_FREE: //站立状态
					//桌椅区删掉
					if (user.wTableID < 0)
					{
						standUp(preUser.wTableID, preUser.wChairID);
					}
					
					break;
				case GlobalDef.US_SIT: //坐下状态
					//桌椅区添加						
					setSitDown(user.wTableID, user.wChairID,FaceMap.getInstance().getFace(pUserItem.GetUserFaceID()),pUserItem.GetUserName(),user.dwUserID);					
					if(user.dwUserID == tagGlobalUserData.dwUserID){
						loginGame();
					}
					break;
				case GlobalDef.US_READY: //同意状态
					break;
				case GlobalDef.US_LOOKON: //旁观状态
					break;
				case GlobalDef.US_PLAY: //游戏状态
					break;
				case GlobalDef.US_OFFLINE: //断线状态					
					break;
			}

		}
		
		public function set ClassName(value:String):void
		{
			gameName=value;
		}

		public function get ClassName():String
		{
			return gameName;
		}
		
		/**
		 * 
		 * 构造所有桌子 
		 */
		private function initTables(value:CMD_GQ_ServerInfo):void
		{

			//没有办法因为是自定义类  反射必须先引用 所以先声明
			var _temp1:LandLordTableView;
			var _temp2:MahjongTableView;
			//===================================//
			var typeName:String=(GameTypeConfig.getInstance().getClassType(gameName).toString());
			var type:Class=getDefinitionByName(typeName) as Class;


			for (var index:int=0; index < value.wTableCount; index++)
			{
				var temp:ITableView = new type as ITableView;			
				_tableHash.insert(index, temp);
				temp.tableId=index;
				view.addChild(temp as DisplayObject);
			}
			addEvent();
		}
		/**
		 * 
		 * 配置桌子
		 */
		private function configTables(value:CMD_GQ_TableInfo):void
		{

			for (var index:int=0; index < value.wTableCount; index++)
			{
		        var temp:ITableView =  _tableHash.find(index) as ITableView;	
				temp.playStatus = (value.TableStatus[index] as tagTableStatus).bPlayStatus;		
				view.validateNow();
			}


		}
		/**
		 * 
		 * @param value 桌子状态改变
		 */
		private function changeTableStatue(value:CMD_GQ_TableStatus):void{
			if(value.wTableID>0){
				(_tableHash.find(value.wTableID) as ITableView).playStatus = value.bPlayStatus;
			}
		}
		private function addEvent():void
		{
			CommonEvent.getInstance().addEventListener(gameEvent.USER_POS, sendServerPos);
			CommonEvent.getInstance().addEventListener(gameEvent.USER_ID,showUserList);
		}

		private function sendServerPos(evt:gameEvent):void
		{
			
			sendNotification(NotificationString.CMD_ROOM_USER, (evt.data), CMD_DEF_ROOM.SUB_GP_USER_SIT_REQ.toString());
		}

		//设置座位已坐下
		/**
		 * 
		 * @param tableId 桌子id
		 * @param chairId 椅子id
		 * @param bitmapData 头像信息
		 * @param username 用户名
		 */
		public function setSitDown(tableId:int, chairId:int,bitmapData:BitmapData,username:String,userId:int):void
		{
			if (tableId >= 0 && chairId >=0)
			{  
				
				var tempTable:ITableView=(_tableHash.find(tableId) as ITableView);
				tempTable.setSitDownId(chairId,bitmapData,username,userId);
			
			}


		}

		/**
		 * 设置座位站起来
		 */
		public function standUp(tableId:int, chairId:int):void
		{
			if (tableId >= 0 && chairId >= 0)
			{
				var tempTable:ITableView=(_tableHash.find(tableId) as ITableView);
				tempTable.setStandUp(chairId);
			}


		}
		/**
		 * 清理删除桌椅区内容
		 */
		private function clearTableArea():void{
			view.removeAllChildren();
			_tableHash.clear();			
		}
		/**
		 * 
		 * @param evt 发送通知显示用户信息
		 * 发送玩家id信息obj["userId"];
		 */
		private function showUserList(evt:gameEvent):void{
			sendNotification(NotificationString.SHOW_USERINFO,evt.data);
		}
		private function closeUserInfo(evt:MouseEvent):void{		
			sendNotification(NotificationString.CLOSE_USERINFO);
		}
		/**
		 * 进入游戏框架 显示游戏
		 */
		private function loginGame():void
		{ 
			if(!facade.hasMediator(GameFrameMediator.NAME))
			{
				
				var gamelib:HashMap = ModuleLib.getInstance().gameLib.find(gameName) as HashMap;				
				var _frame:gameFrame = gamelib.find(GlobalDef.GAME_FRAMEWORK);		
				facade.registerMediator(new GameFrameMediator(_frame));
				
			}
		}
		override public function onRegister():void
		{
			view.addEventListener(MouseEvent.CLICK,closeUserInfo);
		}

		override public function onRemove():void
		{
		}

	}
}