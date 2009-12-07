package Application.view.mediator.room
{
	import Application.NotificationString;
	
	import common.data.CMD_DEF_ROOM;
	import common.data.EmotionFaceConfig;
	import common.data.gameEvent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.events.ListEvent;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ChatMediator extends Mediator implements IMediator
	{
		public static const NAME:String="ChatMediator";
		private var _outMsg:String = "";
		private var _outPutMsg:String = "";
		
		private var _isClick:Boolean = false;
		private var _timer:Timer;
		
		private var _emotionData:XML;
		
		//private var _msgUsers:Array = [];
		
		public function ChatMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			//TODO: implement function

		}
		
		private function init():void
		{
			_timer = new Timer(300,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			
			view.addEventListener(KeyboardEvent.KEY_DOWN,onEnterKey);
			
			view.msgAlet.gotoAndStop(5);
			_emotionData = EmotionFaceConfig.getInstacne().data;
		}
		
		override public function getMediatorName():String
		{
			return NAME;	
		}
		
		private function get view():ChatComponent
		{
			return viewComponent as ChatComponent;	
		}
		
		override public function listNotificationInterests():Array
		{
			return [NotificationString.CHAT_INPUT,
					NotificationString.CHANGE_MSG_ALERT];
		}
		
		override public function handleNotification(note:INotification):void
		{
			switch(note.getName())
			{
				case NotificationString.CHAT_INPUT:
				{
					//trace("NotificationString.CHAT_INPUT---------------------------->>");
					displayMessage(note.getBody() as Object);
					break;	
				}
				case NotificationString.CHANGE_MSG_ALERT:
				{
					//trace("CHANGE_MSG_ALERT-------------------------->>::"+(note.getBody()as int));
					changeMsgAlert((note.getBody()as int));
					break;
				}
				default:
					break;
			}
		}
		override public function onRegister():void
		{
			//TODO: implement function
			configEvent();
			init();
		}


		/**
		 *  添加事件监听器
		 */
		  private function configEvent():void
		  {
		  	view.emotionChooser.addEventListener("select_emotion",onSelectEmotion);
		  	
		  	view.chatMsg.addEventListener(ListEvent.CHANGE,onChangeHandler);
		  	
		  	view.emotionBtn.addEventListener(MouseEvent.CLICK,showEmotionChooser);
		  	view.sendBtn.addEventListener(MouseEvent.CLICK,onClickSendHandler);
		  	view.msgAlet.addEventListener(MouseEvent.CLICK,onClickMsgAlert);
		  	
		  }
		  
		  /**
		  * 隐藏显示表情选择器
		  */
		  private function showEmotionChooser(event:MouseEvent):void
		  {
		  		//trace("showEmotionChooser==========================>>"+view.emotionChooser.visible);
		  		view.emotionChooser.visible = !view.emotionChooser.visible;
		  }
		
		/**
		 * 响应发送按钮点击事件
		 */
		private function onClickSendHandler(event:MouseEvent = null):void
		{
			sendMessage();
		}
		/**
		 *	回车键发送消息 
		 * @param evt
		 * 
		 */
		private function onEnterKey(evt:KeyboardEvent):void{
			if(evt.charCode== Keyboard.ENTER){
				//onClickSendHandler(null);
				sendMessage();
			}
		}
		/**
		 * 发送聊天消息
		 */
 		 private function sendMessage():void
		 {
		 	var _chatMessage:String = "";
		 	var _color:String = "0x000000";
		 	var _targetUserID:String = "0";
		 	
		 	if(view.chatMsg.text != "")
		 	{
		 		//_chatMessage= view.chatMsg.text;
		 		
		 		_chatMessage = getChatMsg(view.chatMsg.text);		 	
		 	
	
		 		//_targetUserID = view.chatTarget.selectedLabel;
		 		var _msgObj:Object = {"send":"","color":_color,"targetUserID":_targetUserID,"chatMessage":_chatMessage};
		 		sendNotification(NotificationString.CMD_ROOM_USER,_msgObj,CMD_DEF_ROOM.SUB_GR_USER_CHAT.toString());
		 		view.chatMsg.text = "";
		 		view.validateNow();//不调用不刷新的
		 		//trace("_chatMessage===============>>::"+_chatMessage);
		 	}
		 }
		 
		 // 开关聊天消息提示功能---->>>模仿单击双击
		 private function onClickMsgAlert(event:MouseEvent):void
		 {
		 	if(!_timer.running)
		 	{
		 		_timer.start();	
		 	}
		 	
		 	_isClick = !_isClick;
		 }
		 
		 //	当聊天消息提示按钮处于激活状态时改变消息提示状态
		 private function changeMsgAlert(_len:int):void
		 {
		 	_len > 0 ? (view.msgAlet.gotoAndStop(10)) : (view.msgAlet.gotoAndStop(5));
		 }
		 
		 /**
		 * 显示聊天消息
		 */
		 private function displayMessage(msgObj:Object):void
		 {
		 	
		 	var _userName:String = msgObj["sendUserName"];
		 	var _chatMsg:String = msgObj["chatMessage"];
		 	
		 	_outPutMsg = _userName +":"+ _chatMsg;
		 	
		 	var _timer:Timer = new Timer(200,1);
		 	_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
		 	_timer.start()
		 }
		 
		 private function onTimer(event:TimerEvent):void
		 {
		 	_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
		 	view.chatText.dispalyMsg(_outPutMsg);
		 	_outPutMsg = "";
		 //	view.chatMsg.text = "";  //这几进行了更改 先注释掉 防止对方的已输入信息 把我正在敲入的信息挤掉
		 }
		 
		 /**
		 * Check 
		 */
		 private function checkOutMsg(_txt:String):void
		 {
		 	var _aray:Array = _txt.split("\n");	
		 	if(_aray.length >= 20)
		 	{
		 		_outMsg = "";
		 	}
		 }
		 
		 //	响应_timer计时器结束事件，执行单击或双击操作
		 private function onTimerComplete(event:TimerEvent):void
		 {
		 	if(this._isClick == true)
		 	{
		 		//trace("单击-----------------------》》");
		 		//单击事件处理
		 		if(view.msgAlet.currentFrame == 1)
			 	{
			 		//	开启聊天新消息提示功能
			 		sendNotification(NotificationString.START_MSG_ALERT);
			 	}
			 	else 
			 	{
			 		//	关闭聊天新消息提示功能
			 		view.msgAlet.gotoAndStop(1);
			 		sendNotification(NotificationString.CLOSE_MSG_ALERT);
			 	}
		 	}
		 	else
		 	{
		 		//	双击事件处理
		 		//	发出读取打开聊天框，读取新消息的通告
		 		if(view.msgAlet.currentFrame != 1)
		 		{
		 			//trace("读取消息----------------------->>>>");
		 			this.sendNotification(NotificationString.READ_MSG_ALERT);
		 		}
		 	}
		 	_isClick = false;
		 }
		 
		 private function onSelectEmotion(event:gameEvent):void
		 {
		 	var _id:String = event.data.toString();
		 	var _name:String = findEmotionName(_id);
		 	
		 	if((view.chatMsg.text + _name).length > 40)
		 	{
		 		//view.chatMsg.text
		 		return;	
		 	}
		 	else
		 	{
		 		view.chatMsg.text += _name;
		 	}
		 	 
		 }
		 
		 //	根据表情ID查找表情名字
		 private function findEmotionName(_id:String):String
		 {
		 	var _xml:XML = EmotionFaceConfig.getInstacne().data as XML;
		 	var _xmlList:XMLList = _xml.emotion;
		 	
		 	for(var i:int = 0;i < _xmlList.length(); i++)
		 	{
		 		if(_xmlList[i].@id == _id)
		 		{
		 			return _xmlList[i].@name;
		 		}
		 	}
		 	return "/az";
		 }
		 
		 private function onChangeHandler(event:ListEvent):void
		 {
		 	if(view.chatMsg.text.length > 40)
		 	{
		 		view.chatMsg.text = view.chatMsg.text.substr(0,50);
		 	}
		 }
		 
		 //	检查要发送出的消息，并用"|"将表情和文字隔开
		 private function getChatMsg(_msg:String):String
		 {
		 	//trace("==============EEEEEEEEEEEEEEEEEEEEEE==============>>"+_msg);
		 	
		 	var _startIndex:int = 0;
		 	var _preEmotion:Boolean = false;
		 	var _chatMessage:String = "";
		 	
		 	if(_msg.indexOf("/",0) >= 0)
		 	{
		 		_chatMessage += _msg.substring(0,_msg.indexOf("/",_startIndex));
		 		_startIndex = _msg.indexOf("/",_startIndex);
		 	}
		 	else if(_msg.indexOf("/",0) < 0)
		 	{
		 		_chatMessage = _msg;
		 		return _msg;
		 	}	
		 	
		 	while( _startIndex >= 0 && _startIndex <= _msg.length )
		 	{
		 		if(_msg.indexOf("/",_startIndex) >= 0)
		 		{
		 			var _subStr:String = _msg.substr(_msg.indexOf("/",_startIndex),3);
		 			if(isEmotion(_subStr))
		 			{
		 				//trace("index========================>>"+_msg.indexOf("/",_startIndex));
		 				//trace("_preEmotion====================>>::"+_preEmotion);
		 				if(_msg.indexOf("/",_startIndex) == 0)
		 				{
		 					_chatMessage +=("|"+_subStr+"|");
		 				}
		 				else if(_msg.indexOf("/",_startIndex) != 0 && !_preEmotion)
		 				{
		 					//trace("index=========000============>>"+_msg.indexOf("/",_startIndex)+3);
		 					//trace("_msg.length - 1====000=======>>::"+(_msg.length) );
		 					
		 					if((_msg.indexOf("/",_startIndex) + 3) == (_msg.length))
		 					{
		 						_chatMessage +=("|"+_subStr);
		 					}
		 					else
		 					{
		 						_chatMessage+=("|"+(_subStr+"|"));	
		 					}
		 					
		 				}
		 				else if(_msg.indexOf("/",_startIndex) != 0 && _preEmotion)
		 				{
		 					//trace("index=========111============>>"+_msg.indexOf("/",_startIndex)+3);
		 					//trace("_msg.length - 1====111=======>>::"+(_msg.length ));
		 					
		 					if((_msg.indexOf("/",_startIndex) + 3) == (_msg.length))
		 					{
		 						_chatMessage +=(_subStr);
		 					}
		 					else
		 					{
		 						_chatMessage+=((_subStr+"|"));
		 					}	
		 				}
		 				
		 				_preEmotion = true;
		 				//trace("_chatMessage------------------->>>"+_chatMessage);
		 			}
		 			else
		 			{
		 				_chatMessage += _subStr;
		 				_preEmotion = false;
		 			}
		 			
		 			//trace("chatMessage===============111111111111===============>>:"+_chatMessage);
		 			_startIndex = _msg.indexOf("/",_startIndex)+3;
		 			//trace("_startIndex======>>::"+_startIndex+"_subStr=======>>::"+_subStr);
		 		}
		 		else
		 		{
		 			//trace("notEmotion=====_subStr=============>>:;"+_subStr);
		 			_chatMessage += _subStr;
		 			_startIndex += 3;
		 			_preEmotion = false;	
		 		}
		 		
		 		//trace("_startIndex==================?>>>>>::"+_startIndex);
		 		//trace("msg.indexOf(/)=================?>>>>>::"+_msg.indexOf("/",_startIndex));
		 		
		 		if((_startIndex <_msg.indexOf("/",_startIndex)) && (_msg.substring(_startIndex,_msg.indexOf("/",_startIndex)) != ""))
		 		{
		 			_preEmotion = false;
		 			_chatMessage += _msg.substring(_startIndex,_msg.indexOf("/",_startIndex));
		 			//trace("chatMessage===============22222222===============>>:"+_chatMessage);
		 		}
		 		else if(_msg.indexOf("/",_startIndex) < 0)
		 		{
		 			_chatMessage += _msg.substring(_startIndex,_msg.length);
		 			_preEmotion = false;
		 			_startIndex  = -1;
		 			//trace("chatMessage===============333333333===============>>:"+_chatMessage);
		 		}
		 	}
		 	return _chatMessage;
		 }
		 
		 // 检查输入的特殊字符串(以"/"开头)是不是表情字段
		 private function isEmotion(_key:String):Boolean
		 {
		 	//trace("isEmotion--------KEY===========>>::"+_key);
		 	var _xmlList:XMLList = _emotionData.emotion;
		 	var _len:int = _xmlList.length();
		 	var i:int = 0;
		 	
		 	while(i < _xmlList.length())
		 	{
		 		if(_key == _xmlList[i].@name)
		 		{
		 			return true;
		 		}
		 		i++;
		 	}
		 	
		 	return false;
		 }
		 
		 
	}
}