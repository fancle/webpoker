package Application.view.mediator.room
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.user.UserItem;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.tagColumnItem;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	import Application.utils.GameUtil;
	
	import common.data.GlobalDef;
	import common.data.HallConfig;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.IFlexDisplayObject;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class UserListMediator extends Mediator implements IMediator
	{
		public static const NAME:String="UserListMediator";
		private var _userInfo:UserInfo=new UserInfo();
		private var listArray:Array=new Array();
		private var clickType:Boolean = false; //单双击状态判断
		private var _timer:Timer = new Timer(300,1);
		private var _itemValue:ListEvent;	
		private var _userArr:ArrayCollection = new ArrayCollection();
		public function UserListMediator(viewComponent:Object=null)
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

		public function get view():DataGrid
		{
			return viewComponent as DataGrid;
		}

		public function get roomView():RoomModule
		{
			return (facade.retrieveMediator(RoomMediator.NAME) as RoomMediator).view;
		}

		override public function setViewComponent(viewComponent:Object):void
		{
		}

		override public function listNotificationInterests():Array
		{
			return [NotificationString.GAME_ROOM_INIT_DATA,
				    NotificationString.GAME_ROOM_DATA,
				    NotificationString.ROOM_SOCKET_CLOSE,
				    NotificationString.SHOW_USERINFO,
				    NotificationString.CLOSE_USERINFO];
		}

		override public function handleNotification(notification:INotification):void
		{
			switch (notification.getName())
			{
				case NotificationString.GAME_ROOM_INIT_DATA:
					switch (notification.getType())
				{
					case "CMD_GQ_ColumnInfo": //列表配置信息							
						addEvent(); //注册侦听
						listConfig(notification.getBody() as CMD_GQ_ColumnInfo);
						break;
				}
					break;

				case NotificationString.GAME_ROOM_DATA:
					switch (notification.getType())
					{
						case "user_come"://初始化座位
						{
							listAddData(notification.getBody() as UserItem);
							break;
						}						
						case "user_status":		//更改用户状态
					    {
					    	changeStatue(notification.getBody() as Object);
					    	break;
					    }
					    case "user_score":		//更改用户分数
					    {
					    	changeScore(notification.getBody() as uint);
					    	break;
					    }
					}
					break;
				case NotificationString.ROOM_SOCKET_CLOSE:					
					clearUserList();
					break;
				case NotificationString.SHOW_USERINFO:
					findUserInfo(notification.getBody());
					break;
				case NotificationString.CLOSE_USERINFO:
				  closeUserInfo(null);
				   break;
			}
		}

		/**
		 * 注册事件命令
		 */
		private function addEvent():void
		{
			view.addEventListener(ListEvent.ITEM_CLICK,laterClickFunction); //单击网格			
			view.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutDataGrid); //网格失去鼠标焦点
			_userInfo.addEventListener("Close", closeUserInfo);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onClick);

		}
		private function onClick(evt:TimerEvent):void{
		
			if(clickType==true){
			
				//onClickDataGrid(_itemValue);//单击
			}
			else{
				onDoubleClickDataGrid(_itemValue);//双击
				
			}
			clickType = false;
		}
		private function laterClickFunction(evt:ListEvent):void
		{		
			_itemValue = evt;	
			clickType = !clickType;
			
		     if(!_timer.running){		    	
		    	
		    	 _timer.start()
		    } 
		}



		//添加数据进入 dataGrid
		private function listAddData(value:UserItem):void
		{
			var userData:tagUserData=value.GetUserData();
			var arrTemp:Object=new Object();
			
			var columnInfo:CMD_GQ_ColumnInfo = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerColumnInfo();
			for each(var item:tagColumnItem in columnInfo.ColumnItem){
				arrTemp[item.szColumnName] = GameUtil.convertToProperty(userData,item.szColumnName);
			}
			arrTemp["__userID"] = userData.dwUserID;
			
			
			//dataArr为试图端得数据绑定
			roomView.dataArr.addItem(arrTemp);
			
		}
		private function updataListData(_userID:uint):void
		{
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(_userID);
			var userData:tagUserData = pUserItem.GetUserData();
						
			var columnInfo:CMD_GQ_ColumnInfo = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerColumnInfo();	
			for(var index:* in _userArr){
				if(_userArr[index]["__userID"]==_userID){
						var arrTemp:Object=_userArr.getItemAt(index) as Object;
						
						for each(var item:tagColumnItem in columnInfo.ColumnItem){
							arrTemp[item.szColumnName] = GameUtil.convertToProperty(userData,item.szColumnName);
						}
						
						_userArr.enableAutoUpdate();
						view.invalidateList();
						 
						break;
				}
			}
		}

		private function listConfig(value:CMD_GQ_ColumnInfo):void
		{
			for each (var index:tagColumnItem in value.ColumnItem)
			{
				if(index.wFlag & 0x01){		//需要在房间当中显示的列表
					var headDataGrid:DataGridColumn=new DataGridColumn(index.szColumnName);
					headDataGrid.dataField = index.szColumnName;
					headDataGrid.minWidth=index.wColumnWidth;
					headDataGrid.width=index.wColumnWidth;
					listArray.push(headDataGrid);
				} 
							
			}
			view.columns=listArray;
		}

		/**
		 *
		 * 单击用户列表的响应事件
		 */
		private function onClickDataGrid(evt:ListEvent):void
		{
			
			var _p:Point=new Point(evt.itemRenderer.mouseX, evt.itemRenderer.mouseY);
			var _gp:Point=evt.itemRenderer.localToGlobal(_p);
			_userInfo.x=(_gp.x) - _userInfo.width - 20;
			_userInfo.y=(_gp.y);
			//未弹出人物信息	
			if (_userInfo.isPopUp == false)
	     	{
		
				PopUpManager.addPopUp((_userInfo as IFlexDisplayObject), view);
			}
			setUserInfoData(evt.itemRenderer.data);
		}

		/**
		 *
		 * 设置用户信息
		 */
		private function setUserInfoData(value:Object):void
		{
			_userInfo.nickname.text=value["head0"];
			_userInfo.userId.text=value["head1"];
			_userInfo.total.text=value["head9"];
			_userInfo.winCont.text=value["head10"];
			_userInfo.lostCount.text=value["head11"];
			_userInfo.drawCount.text=value["head12"];
			_userInfo.score.text=value["score"];
			_userInfo.lostPercent.text=value["head8"];
			_userInfo.U_bean.text = value["uBean"];
			
			 var headUrl:String;
			 if(value["headId"]<10){
            	 headUrl = HallConfig.getInstance().getPhotoFile()+"0"+value["headId"]+".png";
            }else{
            	headUrl = HallConfig.getInstance().getPhotoFile()+value["headId"]+".png"
           	}
			 _userInfo.headPic.url = headUrl;
		}

		/**
		 *
		 * 双击网格 弹出聊天窗口
		 */
		private function onDoubleClickDataGrid(evt:ListEvent):void
		{  
			var _userID:uint = (evt.itemRenderer.data)["__userID"];
			var _userName:String = UserManager.getInstance().SearchUserByUserID(_userID).GetUserName();
			var obj:Object = {userName:_userName,userId:_userID};
		    if(tagGlobalUserData.dwUserID!=obj["userId"]){
		    	sendNotification(NotificationString.OPEN_WISPER,obj);
		    }
			
		}

		/**
		 * 
		 * 改变用户状态
		 */
		private function changeStatue(value:Object):void{	
			var user:tagUserStatus = value["userNowStatus"];		
			var preUser:tagUserStatus = value["userPreStatus"];
			switch(user.cbUserStatus){
				case GlobalDef.US_NULL ://没有状态			
					deleteUserList(user.dwUserID);
					break;
				case GlobalDef.US_FREE://站立状态
				    //桌椅区删掉
			 		changeUserList(user.dwUserID,user.wTableID);
					break;
				case GlobalDef.US_SIT:  //坐下状态
					//桌椅区添加				
					changeUserList(user.dwUserID,user.wTableID);
					if(user.dwUserID == tagGlobalUserData.dwUserID){
						 
					}
					
					break;
				case GlobalDef.US_READY://同意状态
					break;
				case GlobalDef.US_LOOKON://旁观状态
					break;
				case GlobalDef.US_PLAY://游戏状态
					break;
				case GlobalDef.US_OFFLINE://断线状态					
					break;
			}
			
		}
		/**
		 * 更改用户分数
		 * @param value
		 * 
		 */
		private function changeScore(_userID:uint):void
		{
			updataListData(_userID);
		}
		private function onFocusOutDataGrid(evt:FocusEvent):void
		{
			closeUserInfo(null);
		}

		/**
		 *
		 * 关闭用户显示
		 */
		private function closeUserInfo(evt:Event=null):void
		{    
			
			
			if (_userInfo.isPopUp)
				PopUpManager.removePopUp(_userInfo);			
		}

		
		/**
		 * 
		 * 删除用户列表中的信息
		 */
		private function deleteUserList(value:int):void{
			for(var index:* in _userArr){
					if(_userArr[index]["__userID"]==value){						
						_userArr.removeItemAt(index);
						break;
					}
			}
		}

		/**
		 * 
		 * @param _userID 用户id
		 * @param tableId 桌子id
		 * 改变用户列表中的桌子编号
		 */
		private function changeUserList(_userID:int, tableId:int):void
		{
			
			updataListData(_userID);
			/* for(var index:* in _userArr){
				if(_userArr[index]["__userID"]==_userID){						
						(_userArr.getItemAt(index) as Object)["head3"] = tableId;
						_userArr.enableAutoUpdate();
						view.invalidateList();
						 
						break;
				}
			} */
		}
		
		/**
		 * 清除数据
		 */
		private function clearUserList():void{
		
			roomView.dataArr.removeAll();
			listArray = [];
		
		}
		/**
		 * 
		 * @param userId 用户id
		 * 根据用户id经行查找
		 */
		private function findUserInfo(userInfo:Object):void{
			for each(var index:* in _userArr){
				if(userInfo["userId"]== index["head1"]&&tagGlobalUserData.dwUserID!=userInfo["userId"]){
					_userInfo.y = userInfo["mouseY"];
					_userInfo.x = userInfo["mouseX"];
					if (_userInfo.isPopUp == false)
	     			{			     			
						PopUpManager.addPopUp((_userInfo as IFlexDisplayObject), view);						
					}
					setUserInfoData(index);
					break;
				}
			}
		}
		override public function onRegister():void
		{
			 _userArr = roomView.dataArr;//数据绑定
		}
		public function get dataHeadCloumnArr():Array{
			 return listArray;
		}
		override public function onRemove():void
		{
		}

	}
}