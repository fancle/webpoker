package Application.control.net.room
{
	import Application.NotificationString;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.net.socket.RoomClientSocketSinkProxy;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.gameFrame.IPC_UserStatus;
	import Application.model.vo.protocol.login.tagDataDescribe;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.CMD_GP_UserSitReq;
	import Application.model.vo.protocol.room.CMD_GQ_SitFailed;
	import Application.model.vo.protocol.room.CMD_GQ_UserInfoHead;
	import Application.model.vo.protocol.room.CMD_GR_UserChat;
	import Application.model.vo.protocol.room.CMD_GR_UserScore;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	import Application.utils.Memory;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.HallConfig;
	
	import flash.utils.ByteArray;
	
	import mx.utils.ObjectUtil;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CMD_RoomUserCmd extends SimpleCommand implements ICommand
	{
		
		public static const USER_COME:String = CMD_DEF_ROOM.SUB_GQ_USER_COME.toString();//用户进入
		public static const USER_SIT:String = CMD_DEF_ROOM.SUB_GP_USER_SIT_REQ.toString();//用户请求坐下
		public static const USER_AUTOSIT:String = "user_autoSit";						//自动坐下
		public static const USER_SIT_FAILED:String = CMD_DEF_ROOM.SUB_GQ_SIT_FAILED.toString();//坐下失败
		public static const USER_STATUS:String = CMD_DEF_ROOM.SUB_GQ_USER_STATUS.toString();//用户状态
		public static const USER_SCORE:String = CMD_DEF_ROOM.SUB_GR_USER_SCORE.toString();//用户分数
		public static const USER_CHAT:String = CMD_DEF_ROOM.SUB_GR_USER_CHAT.toString();//公聊
		public static const USER_WISPER:String = CMD_DEF_ROOM.SUB_GR_USER_WISPER.toString();//私聊
		public static const TABLE_STATUS:String = CMD_DEF_ROOM.SUB_GQ_TABLE_STATUS.toString();//桌子状态		
		
		public function CMD_RoomUserCmd()
		{
			super();
		}

		override public function execute(notification:INotification):void
		{
			switch (notification.getType())
			{
				//用户进入
				case USER_COME:
				{
					recvUserCome(notification.getBody());
					break;
				}
				//用户坐下
				case USER_SIT:{
					sendSitQequest(notification.getBody());
					break;
				}
				//自动坐下
				case USER_AUTOSIT:
				{
					var obj:Object = new Object;
					obj["tableId"] = GlobalDef.INVALID_TABLE;
					obj["chairId"] = GlobalDef.INVALID_CHAIR;
					sendSitQequest(obj);
					break;
				}
				//坐下失败
				case USER_SIT_FAILED:{
					recvSitFailed(notification.getBody());
					break;
				}
				//用户状态
				case USER_STATUS:{
					recvUserStatus(notification.getBody());
					break;
				}
				//用户分数
				case USER_SCORE:{
					recvUserScore(notification.getBody());
					break;
				}
				//公聊
				case USER_CHAT:{
					userChatHandle(notification.getBody(),CMD_DEF_ROOM.SUB_GR_USER_CHAT);
					break;
				}
				//私聊
				case USER_WISPER:{
					userChatHandle(notification.getBody(),CMD_DEF_ROOM.SUB_GR_USER_WISPER);
					break;
				}
			}
		}

		private function recvUserCome(obj:Object):void
		{
			var bytes:ByteArray=obj["dataBuffer"];
			var wDataSize:int=obj["dataSize"];
			var userData:tagUserData=new tagUserData;

			//读取基本信息
			var userDataHead:CMD_GQ_UserInfoHead=CMD_GQ_UserInfoHead.readData(bytes);
			
			//赋值给userData
			var claInfo:Object=ObjectUtil.getClassInfo(userDataHead);
			var props:Array=claInfo["properties"];

			for each (var key:String in props)
			{
				if (userData.hasOwnProperty(key) && userDataHead.hasOwnProperty(key))
				{
					userData[key]=userDataHead[key];
				}
				//最后删除 随机头像
				
				userData.wFaceID = userData.wFaceID;
			}

			claInfo=ObjectUtil.getClassInfo(userDataHead.UserScoreInfo);
			props=claInfo["properties"];

			for each (key in props)
			{
				if (userData.hasOwnProperty(key) && userDataHead.UserScoreInfo.hasOwnProperty(key))
				{
					userData[key]=userDataHead.UserScoreInfo[key];
				}
			}
			
			//读取扩展信息
			while (bytes.bytesAvailable >= tagDataDescribe.sizeof_tagDataDescribe)
			{
				var dataDescribe:tagDataDescribe=tagDataDescribe.readData(bytes);

				switch (dataDescribe.wDataDescribe)
				{
					case GlobalDef.DTP_USER_ACCOUNTS: //用户帐户
					{
						userData.szName=Memory.readStringByByteArray(bytes, dataDescribe.wDataSize);

						break;
					}
					case GlobalDef.DTP_UNDER_WRITE: //个性签名
					{
						userData.szUnderWrite=Memory.readStringByByteArray(bytes, dataDescribe.wDataSize);
						break;
					}
					case GlobalDef.DTP_USER_NICKNAME: //个性签名
					{
						userData.szNickName=Memory.readStringByByteArray(bytes, dataDescribe.wDataSize);
						break;
					}
				} 
			}
			
			//查找用户--
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(userData.dwUserID);
			if(pUserItem==null){
				//填充其它信息
				
				//加入活动列表
				pUserItem  = UserManager.getInstance().ActiveUserItem(userData);	
			}
			
			//
			sendNotification(NotificationString.GAME_ROOM_DATA, pUserItem, "user_come");
		}
		
		//发送坐下请求
		private function sendSitQequest(obj:Object):void{
			//得到发送坐下请求所需数据 -- 桌子位置、椅子位置、密码长度（默认）、桌子密码（默认）
			var sitQeq:CMD_GP_UserSitReq = new CMD_GP_UserSitReq;			
			sitQeq.wTableID = obj["tableId"];
			sitQeq.wChairID = obj["chairId"];
			
			var bytes:ByteArray = sitQeq.toByteArray();
			
			(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(CMD_DEF_ROOM.MDM_GR_USER, CMD_DEF_ROOM.SUB_GP_USER_SIT_REQ, bytes, CMD_GP_UserSitReq.sizeof_CMD_GP_UserSitReq );
		}
		//收到用户状态信息
		private function recvUserStatus(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var dataSize:int = obj["dataSize"];
			
			var userNowStatus:tagUserStatus = tagUserStatus.readData(bytes);
			
			//提取前状态
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(userNowStatus.dwUserID);
			var userPreStatus:tagUserStatus = pUserItem.GetUserStatus();
			
			//改变userData中的状态
			if(pUserItem){
				pUserItem.SetUserStatus(userNowStatus);
				if(GlobalDef.DEBUG)trace("============in CMD_RoomUserCmd recvUserStatus:userStatus = " + pUserItem.GetUserStatus().cbUserStatus);
				if(GlobalDef.DEBUG)trace("============in CMD_RoomUserCmd recvUserStatus:userid = " + pUserItem.GetUserID());
			}	 			
			
			var obj:Object = new Object;
			obj["userNowStatus"] = userNowStatus;
			obj["userPreStatus"] = userPreStatus;
			
			//通知框架逻辑
			if(facade.hasProxy(GameFrameProxy.NAME)){
				frameUserStatusHandle(pUserItem,userPreStatus,userNowStatus);
			}
			
			//通知框架界面
			sendNotification(NotificationString.GAME_ROOM_DATA, obj, "user_status");			
		}
		private function frameUserStatusHandle(pComeUserItem:IUserItem,userPreStatus:tagUserStatus,userNowStatus:tagUserStatus):void{
			var pMeUserItem:IUserItem = UserManager.getInstance().getMeItem();
			if(GlobalDef.DEBUG)trace("in CMD_RoomUserCmd frameUserStatusHandle:userPreStatus.wTableID = "+userPreStatus.wTableID);
			if(GlobalDef.DEBUG)trace("in CMD_RoomUserCmd frameUserStatusHandle:userNowStatus.wTableID = "+userNowStatus.wTableID);
			//判断是否同桌人
			var bNotifyGame:Boolean=(pMeUserItem.GetUserStatus().wTableID!=GlobalDef.INVALID_TABLE)
									&&((pComeUserItem==pMeUserItem)
										||(pMeUserItem.GetUserStatus().wTableID==userPreStatus.wTableID)
										||(pMeUserItem.GetUserStatus().wTableID==userNowStatus.wTableID)
										);
			
			if(bNotifyGame){
				var ipc_UserStatus:IPC_UserStatus=new IPC_UserStatus;
					
				ipc_UserStatus.dwUserID=userNowStatus.dwUserID;
				ipc_UserStatus.cbUserStatus=userNowStatus.cbUserStatus;
				
				sendNotification(NotificationString.CMD_FRAME_USER,ipc_UserStatus,"userStatus");
			}
			//新玩家
			var b:Boolean = (pMeUserItem.GetUserStatus().wTableID!=GlobalDef.INVALID_TABLE)
							&&(userNowStatus.wTableID!=userPreStatus.wTableID)
							&&((pComeUserItem==pMeUserItem)
								||(pMeUserItem.GetUserStatus().wTableID==userNowStatus.wTableID)
								);
			if(b)
			{
				var userData:tagUserData = pComeUserItem.GetUserData();
				sendNotification(NotificationString.CMD_FRAME_USER,userData,"userCome");
			}
			
			//自己站起---移除GameFrameProxy
			if(pComeUserItem == pMeUserItem){
				//如果是自己
				if(userNowStatus.cbUserStatus == GlobalDef.US_FREE){
					sendNotification(NotificationString.CMD_GAME_FRAME,null,"remove");
				}
			}
		}
		private function recvUserScore(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var dataSize:int = obj["dataSize"];
			
			var cmd_userScore:CMD_GR_UserScore = CMD_GR_UserScore.readData(bytes);
			
			//更新用户积分
			var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(cmd_userScore.dwUserID);
			pUserItem.SetUserScore(cmd_userScore.UserScore);
			pUserItem.GetUserData().lLoveliness = cmd_userScore.lLoveliness;//魅力
			pUserItem.GetUserData().dwHonorRank = cmd_userScore.dwHonorRank;//排名
						
			sendNotification(NotificationString.GAME_ROOM_DATA, pUserItem.GetUserID(), "user_score");	
		}
		//用户坐下失败信息
		private function recvSitFailed(obj:Object):void{
			var bytes:ByteArray = obj["dataBuffer"];
			var dataSize:int = obj["dataSize"];
			
			var sitFailed:CMD_GQ_SitFailed =  CMD_GQ_SitFailed.readData(bytes);
			
			var chongzhi_link:String = " <a href='" + HallConfig.getInstance().getLink("charge")["url"] + "' target='_blank'><b><u><font color='#0000ff' size='12'>请充值</font></u></b></a>";
			var failMessage:String = "<span>" + sitFailed.szFailedDescribe + "</span>" + chongzhi_link;
			
			if(GlobalDef.DEBUG)trace("in CMD_RoomUserCmd recvSitFailed: " + sitFailed.szFailedDescribe);
			sendNotification(NotificationString.GAME_ROOM_DATA,null,USER_SIT_FAILED);
			sendNotification(NotificationString.ALERT,failMessage);
		}
		//用户聊天信息
		private function userChatHandle(obj:Object,subCmd:int):void{
			//发送信息
			if(obj.hasOwnProperty("send")){
				var userChatSendMessage:CMD_GR_UserChat = new CMD_GR_UserChat;
				//填写属性
				userChatSendMessage.crFontColor = uint(obj["color"]);
				userChatSendMessage.dwSendUserID = tagGlobalUserData.dwUserID;
				userChatSendMessage.dwTargetUserID = uint(obj["targetUserID"]);
				userChatSendMessage.szChatMessage = obj["chatMessage"];
				
				var strBytes:ByteArray = new ByteArray;
				strBytes.writeUTFBytes(String(obj["chatMessage"]));
				
				userChatSendMessage.wChatLength = strBytes.length;
				
				var bytes:ByteArray = userChatSendMessage.toByteArray();
				
				(facade.retrieveProxy(RoomClientSocketSinkProxy.NAME) as RoomClientSocketSinkProxy).send(CMD_DEF_ROOM.MDM_GR_USER,subCmd,bytes,CMD_GR_UserChat.sizeof_Head_CMD_GR_UserChat+strBytes.length);				
			}
			//接收信息
			else{
				var dataBuffer:ByteArray = obj["dataBuffer"];
				var dataSize:int = obj["dataSize"];
				
				var userChatMessage:CMD_GR_UserChat = CMD_GR_UserChat.readData(dataBuffer);
				
				var pUserItem:IUserItem = UserManager.getInstance().SearchUserByUserID(userChatMessage.dwSendUserID);
				var sendUserName:String = pUserItem.GetUserName();
				
				pUserItem = UserManager.getInstance().SearchUserByUserID(userChatMessage.dwTargetUserID);
				if(pUserItem){
					var targetUserName:String = pUserItem.GetUserName();
				}			
				
				var recvObj:Object = new Object;
				recvObj["color"] = userChatMessage.crFontColor;
				recvObj["sendUser"] = userChatMessage.dwSendUserID + "|" + sendUserName;
				recvObj["targetUser"] = userChatMessage.dwTargetUserID + "|" + targetUserName;
				recvObj["chatMessage"] = userChatMessage.szChatMessage;
				 
				//接收到公共消息
				if(subCmd==CMD_DEF_ROOM.SUB_GR_USER_CHAT){
					recvObj["sendUserName"] = sendUserName;
					//recvObj["targetUser"] = userChatMessage.dwTargetUserID + "|" + targetUserName;
					sendNotification(NotificationString.CHAT_INPUT,recvObj);
				}
				//接收到私聊消息
				else if(subCmd==CMD_DEF_ROOM.SUB_GR_USER_WISPER){
					recvObj["sendUser"] = userChatMessage.dwSendUserID + "|" + sendUserName;
					recvObj["targetUser"] = userChatMessage.dwTargetUserID + "|" + targetUserName;
					
					sendNotification(NotificationString.WISPER_INPUT,recvObj);
				}
			}
		}
	}
}