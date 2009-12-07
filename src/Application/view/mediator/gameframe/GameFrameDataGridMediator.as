package Application.view.mediator.gameframe
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.tagColumnItem;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	import Application.utils.GameUtil;
	
	import common.data.GlobalDef;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	public class GameFrameDataGridMediator extends Mediator implements IMediator
	{
		public static const NAME:String="GameFrameDataGridMediator";

		public function GameFrameDataGridMediator(viewComponent:Object=null)
		{

			super(NAME, viewComponent);
		}
		private var dataGridData:ArrayCollection=new ArrayCollection();
		private var dataHeadArr:Array=new Array();

		override public function getMediatorName():String
		{
			return NAME;
		}

		override public function getViewComponent():Object
		{
			return viewComponent;
		}

		override public function handleNotification(notification:INotification):void
		{
			switch (notification.getName())
			{
				case NotificationString.GAME_ROOM_DATA:
				{
					switch (notification.getType())
					{
						case "user_status":
						{
							recvUserStatus(notification.getBody());
							break;
						}
					}

					break;
				}
			}
		}
		private function recvUserStatus(obj:Object):void{
			var userNowStatus:tagUserStatus = obj["userNowStatus"];
			var userPreStatus:tagUserStatus = obj["userPreStatus"];
			
			var wMeTableID:uint = UserManager.getInstance().getMeItem().GetUserStatus().wTableID;
			//是否同桌人
			var isSameTable:Boolean = (userNowStatus.wTableID!=GlobalDef.INVALID_TABLE||userPreStatus.wTableID!=GlobalDef.INVALID_TABLE)
			   						  &&UserManager.getInstance().getMeItem().GetUserStatus().wTableID!=GlobalDef.INVALID_TABLE
			  						  &&(userNowStatus.wTableID == wMeTableID||userPreStatus.wTableID==wMeTableID);
			//其他玩家加入玩家
			if(isSameTable){
				if(userNowStatus.cbUserStatus!=userPreStatus.cbUserStatus&&userNowStatus.cbUserStatus==GlobalDef.US_SIT/* 新玩家进桌 */)
				{
					dataGridData.removeAll();
					addDataGrid();
				}
				else if( userNowStatus.cbUserStatus == GlobalDef.US_FREE/* 同桌人离开 */)
				{
					deleteUserList(userNowStatus.dwUserID);
				}
				else		//更新状态
				{
					updataListData(userNowStatus.dwUserID);
				}
				
			}			
			/* if(userNowStatus.cbUserStatus == GlobalDef.US_SIT||userNowStatus.cbUserStatus == GlobalDef.US_FREE){
				    dataGridData.removeAll();
					addDataGrid();
			} */
			
		}
		
		private function updataListData(_userID:uint):void
		{
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(_userID);
			var userData:tagUserData = pUserItem.GetUserData();
						
			var columnInfo:CMD_GQ_ColumnInfo = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerColumnInfo();	
			for(var index:* in dataGridData){
				if(dataGridData[index]["__userID"]==_userID){
						var arrTemp:Object=dataGridData.getItemAt(index) as Object;
						
						for each(var item:tagColumnItem in columnInfo.ColumnItem){
							arrTemp[item.szColumnName] = GameUtil.convertToProperty(userData,item.szColumnName);
						}
						
						dataGridData.enableAutoUpdate();
						view.invalidateList();
						 
						break;
				}
			}
		}
		/**
		 * 
		 * 删除用户列表中的信息
		 */
		private function deleteUserList(value:int):void{
			for(var index:* in dataGridData){
					if(dataGridData[index]["__userID"]==value){						
						dataGridData.removeItemAt(index);
						break;
					}
			}
		}
		
		override public function initializeNotifier(key:String):void
		{
			super.initializeNotifier(key);
			
			var columnInfo:CMD_GQ_ColumnInfo = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerColumnInfo();
			for each (var index:tagColumnItem in columnInfo.ColumnItem)
			{
				if(index.wFlag & 0x02){		//需要在游戏戏当中显示的列表
					var headDataGrid:DataGridColumn=new DataGridColumn(index.szColumnName);
					headDataGrid.dataField = index.szColumnName;
					headDataGrid.minWidth=index.wColumnWidth;
					headDataGrid.width=index.wColumnWidth;
					
					dataHeadArr.push(headDataGrid);		
				} 
				
			}
			//dataHeadArr=(facade.retrieveMediator(UserListMediator.NAME) as UserListMediator).dataHeadCloumnArr;
			dataGridData=(facade.retrieveMediator(GameFrameMediator.NAME) as GameFrameMediator).dataGridArr();

		}

		override public function listNotificationInterests():Array
		{
			return [NotificationString.GAME_ROOM_DATA];
		}

		override public function onRegister():void
		{

			initDataGrid(); //初始化表格


		}

		override public function onRemove():void
		{
			//清空玩家列表
			dataGridData.removeAll();
		}

		override public function sendNotification(notificationName:String, body:Object=null, type:String=null):void
		{
		}

		override public function setViewComponent(viewComponent:Object):void
		{
		}

		public function get view():DataGrid
		{
			return viewComponent as DataGrid;
		}

		private function addDataGrid():void
		{
			var meItem:IUserItem=UserManager.getInstance().getMeItem();
			var vItem:Vector.<IUserItem>=UserManager.getInstance().getUserListByTableID(meItem.GetUserStatus().wTableID);
			if(!vItem) return ;
			for each (var index:IUserItem in vItem)
			{
				var userData:tagUserData=index.GetUserData();
				var arrTemp:Object=new Object();
				var columnInfo:CMD_GQ_ColumnInfo = (facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerColumnInfo();
				for each(var item:tagColumnItem in columnInfo.ColumnItem){
					arrTemp[item.szColumnName] = GameUtil.convertToProperty(userData,item.szColumnName);
				}
				arrTemp["__userID"] = userData.dwUserID;

				//dataArr为试图端得数据绑定
				dataGridData.addItem(arrTemp);
			}
		}

		/**
		 * 初始化用户列表
		 */
		private function initDataGrid():void
		{
			view.columns=dataHeadArr;
			//添加数据
			addDataGrid();
		}
	}
}