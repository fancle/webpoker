package Application.view.mediator.room
{
	import Application.NotificationString;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	
	import de.polygonal.ds.HashMap;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class WisperMediator extends Mediator
	{
		public static const NAME:String="WisperMediator";
		private var _userInfo:Object;
		
		private var _sendMsgs:HashMap;
		private var _inceptMsgs:HashMap;
		private var _msgUsers:Array;
		
		private var _outMsg:String = "";
		
		private var _testID:String = "";
		
		private var _gameName:String;
		
		//	新消息是否提示标识
		private var _isMsgAlert:Boolean = true;
		
		public function WisperMediator(gameName:String,viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			//TODO: implement function
			_gameName = gameName;
			init();
		}
		
		private function init():void
		{
			_sendMsgs = new HashMap(100);
			_inceptMsgs = new HashMap(100);
			_msgUsers = [];
			
			configEvent();	
		}
		
		private function configEvent():void
		{
			view.addEventListener("close",onCloseHandler);
			view.closeBtn.addEventListener(MouseEvent.CLICK,onCloseHandler);
			view.sendBtn.addEventListener(MouseEvent.CLICK,onSendHandler);
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		private function get view():WisperComponent
		{
			return viewComponent as WisperComponent;	
		}
		
		override public function listNotificationInterests():Array
		{
			return [NotificationString.WISPER_INPUT,
					NotificationString.INIT_WISPER_DATA,
					NotificationString.GAME_ROOM_DATA,
					NotificationString.START_MSG_ALERT,
					NotificationString.READ_MSG_ALERT];
		}
		
		override public function handleNotification(note:INotification):void
		{
			switch(note.getName())
			{
				case NotificationString.WISPER_INPUT:
				{
		 			saveMsgs((note.getBody() as Object));
		 			
		 			if(userInfo != null)
		 			{
		 				displayMessage(filterMsg(note.getBody() as Object));	
		 			}
		 			
		 			if(this.isMsgAlert)
		 			{
		 				checkMsgUser();
		 			}
					break;	
				}
				case NotificationString.INIT_WISPER_DATA:
				{
					initView(note.getBody()as Object);
				}
				case NotificationString.GAME_ROOM_DATA:
				{
					if(note.getType() == "user_status")
					{
						// 判断如果是否关闭聊天窗口
						var userStatus:tagUserStatus = note.getBody()["userNowStatus"] as tagUserStatus;
						if(userStatus.cbUserStatus == GlobalDef.US_FREE){
							// 关闭聊天窗口
							if(userInfo != null && userStatus.dwUserID.toString() == userInfo["userId"])
							{
								onCloseHandler();
							}
						}
					}
					break;	
				}
				case NotificationString.START_MSG_ALERT:
				{
					isMsgAlert = true;
					//调用检测信息系函数，并返回新消息记录条数
					checkMsgUser();
					break;	
				}
				case NotificationString.CLOSE_MSG_ALERT:
				{
					isMsgAlert = false;
					break;	
				}
				case NotificationString.READ_MSG_ALERT:
				{
					//trace("READ_MSG_ALERT------READ_MSG_ALERT-----READ_MSG_ALERT---->>");
					var _msgUser:String = delMsgUser();
					if(_msgUser != "")
					{
						var _userID:String =(_msgUser.split("|") as Array)[0].toString();
						var _userName:String = (_msgUser.split("|") as Array)[1].toString();
						var _data:Object = {"userId":_userID,"userName":_userName};
						sendNotification(NotificationString.OPEN_WISPER,_data);	
						checkMsgUser();
					}
				}
				default:
					break;
			}
		}
		
		private function initView(_info:Object):void
		{
			var _gameName:String = (_gameName.split("房间") as Array)[0];
			view.title ="与【"+_info["userName"]+"】在房间【"+_gameName+"】私聊中...";	
			userInfo = {userId:_info["userId"],userName:_info["userName"]};
			
			//trace("initView------EEEEEEEEEEEEEEEE---============>>::"+_info["userId"]+_info["userName"]);
			
			this.showHistoryInfo();
			view.chatText.text = _outMsg;
		}
		
		/**
		 * 响应关闭按钮，发出关闭聊天视窗通告
		 */
		 private function onCloseHandler(event:Event = null):void
		 {
		 	_outMsg = "";
		 	view.chatText.text = "";
		 	this.userInfo = null;
		 	sendNotification(NotificationString.CLOSE_WISPER);
		 }
		 
		 /**
		 * 发送私聊消息
		 */
		 private function onSendHandler(event:MouseEvent):void
		 {
		 	var _chatMessage:String = "";
		 	var _color:String = "0x000000";
		 	var _targetUserID:String = "9";
		 	var _targetUserName:String = "9";
		 	
		 	if(view.chatMsg.text != "")
		 	{
		 		_chatMessage= view.chatMsg.text;
		 		_targetUserID = userInfo["userId"];
		 		_targetUserName = userInfo["userName"];
		 		var _msgObj:Object = {"send":"","color":_color,"targetUserID":_targetUserID,"chatMessage":_chatMessage};
		 		sendNotification(NotificationString.CMD_ROOM_USER,_msgObj,CMD_DEF_ROOM.SUB_GR_USER_WISPER.toString());
		 		clearChatMsg();
		 	}
		 }
		 
		 //	显示聊天消息
		 private function displayMessage(msgObj:Object = null):void
		 {
			if(msgObj != null)
			{
				_outMsg = checkOutMsg();
				var _sendName:String = (msgObj["sendUser"].toString().split("|") as Array)[1];
				var _chatMsg:String = msgObj["chatMessage"].toString();
				
				_outMsg += (_sendName +":"+ _chatMsg + "\n");
				view.chatText.text = _outMsg;
			}
		 }
		 
		 /**
		 * Check output chatText.text is more than twenty(20) lines.
		 */
		 private function checkOutMsg():String
		 {
		 	var _aray:Array = _outMsg.split("\n");
		 	//trace("EEEEEEEEEEEEEEEEE....=======================================>>::"+_aray.length);
		 	
		 	if(_aray.length >= 20)
		 	{
		 		_outMsg = "";
		 	}
		 	
		 	return _outMsg;
		 }
		 
		 //	存储收到的消息
		 private function saveMsgs(_msg:Object):void
		 {
		 	var _chatMsg:String = "";
		 	var _sender:String = "";
		 	var _inceptor:String = "";
		 	
		 	var _date:Date;
		 	var _msgItem:Object;
		 	
		 	
		 	_sender = _msg["sendUser"].toString();
		 	_inceptor = _msg["targetUser"].toString();
		 	
		 	_testID = _inceptor;
		 	//_testID = _sender;
			
			_chatMsg = _msg["chatMessage"];	
			
			// 如果这条消息是当前玩家发出，将它存储到_sendMsgs(HashMap[key])相应的数组中;
			// 反之，则将消息存储到_inceptMsgs(HashMap[key])相应的数组中
			if(tagGlobalUserData.dwUserID.toString() == (_sender.split("|") as Array)[0] && (_inceptor.split("|") as Array)[0] != tagGlobalUserData.dwUserID.toString())
			{
				if(!_sendMsgs.containsKey(_inceptor))
				{
					_sendMsgs.insert(_inceptor,[]);
				}
				
				_date = new Date();
				_msgItem = {"time":_date.getTime(),"msg":_chatMsg,"speaker":tagGlobalUserData.szAccounts};
				
				checkMsgsNum((_sendMsgs.find(_inceptor) as Array));
				
				(_sendMsgs.find(_inceptor) as Array).push(_msgItem);
				//testHash(_sendMsgs);
			}
			else if(tagGlobalUserData.dwUserID.toString() == (_inceptor.split("|") as Array)[0] &&  (_sender.split("|") as Array)[0]!=  tagGlobalUserData.dwUserID.toString())
			{
				if(!_inceptMsgs.containsKey(_sender))
				{
					_inceptMsgs.insert(_sender,[]);
				}
				
				_date = new Date();
				_msgItem =  {"time":_date.getTime(),"msg":_chatMsg,"speaker":(_sender.split("|") as Array)[1].toString()};
				
				checkMsgsNum(_inceptMsgs.find(_sender) as Array);
				
				(_inceptMsgs.find(_sender) as Array).push(_msgItem);
				
				//	如果当前用户接收到非当前聊天对象发送过来的信息是，存储信息发送用户ID到_msgUsers。
				//trace("调试==============================================》》");
				//var temp:String = (_sender.split("|") as Array)[0].toString()//_sender.split("|") as Array)[0].toString();
				
				if(userInfo == null || (userInfo!= null && (userInfo["userId"] != (_sender.split("|") as Array)[0].toString())))
				{
					if(_msgUsers.indexOf(_sender))
					{
						this.saveMsgUser(_sender);
					}		
				}
			}
		 }
		
		//	显示与当前聊天对象的聊天历史信息
		private function showHistoryInfo():void
		{
			var _historyMsgs:Array = getHistoryInfo() as Array;
			var _historyText:String = "";
			
			if(_historyMsgs .length > 0)
			{
				_historyText = 	_historyMsgs.join("\n") + "\n";
			}
			
			_outMsg = _historyText;
		}
		
		//	获取与当前聊天对象的聊天历史信息纪录
		private function getHistoryInfo(_userInfo:Object = null):Array
		{
			var _historyMsgs:Array = [];
			
			_historyMsgs = sendeHistoryInfo.concat(inceptHistoryInfo).sortOn("time").map(formatMsg);
			testAray(_historyMsgs);
			return _historyMsgs;	
		}
		
		// 获取当前用户发给当前聊天对象的历史信息记录
		private function get sendeHistoryInfo():Array
		{
			var _msgAray:Array = [];
			var _key:String = userInfo["userId"].toString()+"|"+ userInfo["userName"].toString();
			
			if(_sendMsgs.containsKey(_key))
			{
				_msgAray = this._sendMsgs.find(_key);
			}
			
			return _msgAray;
		}
		
		//	获取当前聊天对象发给当前用户的历史信息
		private function get inceptHistoryInfo():Array
		{
			var _msgAray:Array = [];
			var _key:String = userInfo["userId"].toString()+"|"+ userInfo["userName"].toString();
			
			if(_inceptMsgs.containsKey(_key))
			{
				_msgAray = _inceptMsgs.find(_key);
			}
			
			return _msgAray;	
		}
		
		//	返回聊天对象信息
		public function get userInfo():Object
		{
		 	return _userInfo;	
		}
		 
		 //	填写聊天对象信息
		 public function set userInfo(value:Object):void
		 {
		 	_userInfo = value;	
		 }
		 
		 // 返回格式化的聊天信息
		 private function  formatMsg(element:*, index:int, arr:Array):String
		 {
		 	return element["speaker"]+": "+element["msg"];
		 }
		 
		/**
		 * 过滤聊天信息，只保留当前聊天对信息
		 */
		 private function filterMsg(_msg:Object):Object
		 {
		 	//trace("filterMsg-------FFFFFFFFFFFFFFFF---->>"+_msg);
		 	var _sendID:String = (_msg["sendUser"].toString().split("|") as Array)[0];
		 	var _inceptID:String = (_msg["targetUser"].toString().split("|") as Array)[0];
		 	var _chatMsg:String = _msg["chatMessage"];
		 	
		 	if((_sendID == tagGlobalUserData.dwUserID.toString() && _inceptID == userInfo["userId"])
		 		|| (_sendID ==  userInfo["userId"] && _inceptID == tagGlobalUserData.dwUserID.toString()))
		 	{
		 		return _msg;
		 	}
		 	
		 	return null;
		 }
		 
		 private function clearChatMsg():void
		 {
		 	view.chatMsg.text = "";
		 }
		 
		 // 在_msgUsers中保存有新消息的用户
		 private function saveMsgUser(_sender:String):int
		 {
		 	return _msgUsers.push(_sender);
		 }
		 
		 // 在_msgUsers中删除已阅读过的新消息用户
		 private function delMsgUser():String
		 {
		 	if(_msgUsers.length > 0)
		 	{
		 		return _msgUsers.shift();
		 	}
		 	else
		 	{
		 		return "";	
		 	}
		 	
		 }
		 
		 /**
		 * Check _msgUsers is [];
		 */
		 private function checkMsgUser():void
		 {
		 	// 当检测开启时，返回当前新消息记录的条数
		 	this.sendNotification(NotificationString.CHANGE_MSG_ALERT,_msgUsers.length);
		 	//return _msgUsers.length;
		 }
		 
		 private function get isMsgAlert():Boolean
		 {
		 	return _isMsgAlert;	
		 }
		 
		 private function set isMsgAlert(value:Boolean):void
		 {
		 	_isMsgAlert = value;
		 }
		 
		 private function checkMsgsNum(_aray:Array):void
		 {
		 	if(_aray.length >= 20)
		 	{
		 		_aray.shift();
		 	}	
		 }
		 
		 private function testHash(_msgs:HashMap):void
		 {
		 	//trace("testHash---------------------->>");
		 	var _aray:Array = _msgs.find(_testID);
		 	for each(var i:* in _aray)
		 	{
		 		//trace("RTTTTTT-====--->>:"+i["time"]+"-==MSG==="+i["msg"]);
		 	}
		 }
		 
		 private function testAray(_ary:Array):void
		 {
		 	for(var i:int = 0; i < _ary.length; i++)
		 	{
		 		//trace(i+"==TIME==>>::"+_ary[i]["time"]+"====MSG====>>::"+_ary[i]["msg"]);	
		 	}
		 }
		override public function onRegister():void
		{

		}
		 
	}
}