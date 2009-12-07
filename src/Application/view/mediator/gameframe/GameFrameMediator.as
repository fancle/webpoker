package Application.view.mediator.gameframe
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.gameFrame.GameFrameProxy;
	import Application.model.interfaces.IUserItem;
	import Application.model.present.PresentManager;
	import Application.model.user.UserManager;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserStatus;
	import Application.utils.GameUtil;
	import Application.utils.PopUpEffect;
	import Application.utils.SoundManager;
	import Application.view.mediator.room.TableAreaMediator;
	
	import common.assets.ModuleLib;
	import common.data.CMD_DEF_ROOM;
	import common.data.EmotionFaceConfig;
	import common.data.GlobalDef;
	import common.data.HallConfig;
	import common.data.gameEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class GameFrameMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "GameFrameMediator"
		
		private var _emotionData:XML;
		
		private var _outPutMsg:String = "";
		
		private var bForceExitFrame:Boolean = false;
		
		private var msgTimer:Timer;
		
		private var matchOver:MatchOver;
		
		private var props:PropsAction = new PropsAction();
		public function GameFrameMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			_emotionData = EmotionFaceConfig.getInstacne().data;
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent;
		}
		public function get view():gameFrame
		{
			return viewComponent as gameFrame;
		}
		
		override public function setViewComponent(viewComponent:Object):void
		{
		}
		/**
		 * 
		 * @param evt 组件初始化
		 */
		private function init(evt:FlexEvent=null):void
		{
			//初始化游戏区消息的Timer
			msgTimer = new Timer(0,1);
			msgTimer.addEventListener(TimerEvent.TIMER,onMsgTimer);
			//界面上的事件侦听
			addEvent();	
			//注册用户列表的视图
			facade.registerMediator(new GameFrameDataGridMediator(view.dg));
			//初始化游戏
			readyGame();
			//如果是比赛场
			/* if((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre == GlobalDef.GAME_GENRE_MATCH){
				var msgObj:Object = new Object;
				msgObj["timeDelay"] = -1;
				msgObj["message"] = StringDef.WEIT_TO_GET_TABLE;
				displayGameMessage(msgObj);
			} */
			
			view.addChild(props);
			//奖状
			matchOver =  new MatchOver;
			matchOver.addEventListener("close",matchOverHandle,false,0,true);
		
		}
		private function readyGame():void
		{
			
			if(UserManager.getInstance().getMeItem().GetUserStatus().cbUserStatus >GlobalDef.US_FREE){
				setData();
				initGame();
				
			}
		}
		/**
		 * 注册监听事件
		 */
		private function addEvent():void
		{
			view.closeBtn.addEventListener(MouseEvent.CLICK,closeView);
			view.question_btn.addEventListener(MouseEvent.CLICK,questionBtn);
			view.emotionChooser.addEventListener("select_emotion",onSelectEmotion);
			view.sendBtn.addEventListener(MouseEvent.CLICK,onClickSendHandler);
			view.emotionBtn.addEventListener(MouseEvent.CLICK,onShowEmotionChooser);
			view.music_btn.addEventListener(MouseEvent.CLICK,musicControl);
			
			view.zhuan_btn.addEventListener(MouseEvent.CLICK,changeMouse);
			view.hua_btn.addEventListener(MouseEvent.CLICK,changeMouse);
			view.poshui_btn.addEventListener(MouseEvent.CLICK,changeMouse);
			view.guzhang_btn.addEventListener(MouseEvent.CLICK,changeMouse);
			view.gameArea.addEventListener(MouseEvent.CLICK,mouseRestore);
			view.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			view.topGameFrame.addEventListener(MouseEvent.MOUSE_OVER,mouseRestore);
			
			
			//view.fullScreen_btn.addEventListener(MouseEvent.CLICK,changeScreen);
		}
		/**
		 * 判断点击那个鼠标样式 
		 * @param evt
		 * 
		 */
		private function changeMouse(evt:MouseEvent):void
		{
			mouseRestore();
			switch(String(evt.target.name)){
				case "poshui_btn":
					mouseChange(poshui_ico);	
					PresentManager.getInstance().setCurrentProperty(508);				
					break;
				case "guzhang_btn":
					mouseChange(guzhang_ico);
					PresentManager.getInstance().setCurrentProperty(500);	
					break;
				case "zhuan_btn":
					mouseChange(zhuan_ico);
					PresentManager.getInstance().setCurrentProperty(509);	
					break;
				case "hua_btn":
					mouseChange(hua_ico);
					PresentManager.getInstance().setCurrentProperty(502);	
					break;				
			}	

		}
		/**
		 * 
		 * @param value
		 * 
		 */
		private function mouseChange(value:Class):void
		{			
			 CursorManager.getInstance().setCursor(value,CursorManagerPriority.HIGH);
		}
		private function mouseRestore(evt:MouseEvent = null):void
		{			
			CursorManager.getInstance().removeAllCursors();
		}
		/**
		 * 播放道具动画 
		 * @param propId  道具id
		 * @param propPos 道具坐标
		 * 
		 */
		private function playProps(propId:int,propPos:Point):void{
			 props.playAction(propId,propPos.x,propPos.y);
		}
		private function removeEvent():void
		{
			view.closeBtn.removeEventListener(MouseEvent.CLICK,closeView);
			view.question_btn.removeEventListener(MouseEvent.CLICK,questionBtn);
			view.emotionChooser.removeEventListener("select_emotion",onSelectEmotion);
			view.sendBtn.removeEventListener(MouseEvent.CLICK,onClickSendHandler);
			view.emotionBtn.removeEventListener(MouseEvent.CLICK,onShowEmotionChooser);
			view.music_btn.removeEventListener(MouseEvent.CLICK,musicControl);
			
			view.zhuan_btn.removeEventListener(MouseEvent.CLICK,changeMouse);
			view.hua_btn.removeEventListener(MouseEvent.CLICK,changeMouse);
			view.poshui_btn.removeEventListener(MouseEvent.CLICK,changeMouse);
			view.guzhang_btn.removeEventListener(MouseEvent.CLICK,changeMouse);
			view.gameArea.removeEventListener(MouseEvent.CLICK,mouseRestore);
			view.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			//view.fullScreen_btn.removeEventListener(MouseEvent.CLICK,changeScreen);
		}
		private function closeView(evt:MouseEvent = null):void
		{
			sendNotification(NotificationString.CMD_GAME_FRAME,null,"closeGameClient");
		}
		private function musicControl(evt:MouseEvent):void{
			if(view.music_btn.selected==true){
				sendNotification(NotificationString.IPC_CONTROL,SoundManager.CLOSE,SoundManager.SOUND);
			}else{
				sendNotification(NotificationString.IPC_CONTROL,SoundManager.OPEN,SoundManager.SOUND);
			}
			
		}
		private function changeScreen(evt:MouseEvent):void{
			 ModuleLib.getInstance().gameStage.setFullScreen();

		}
		override public function listNotificationInterests():Array
		{
			return [NotificationString.GAME_ROOM_DATA,
			     	NotificationString.CMD_GAME_FRAME,
			        NotificationString.GAME_CHAT_INPUT,
			        NotificationString.MSG_GAMEFRAME,
			        NotificationString.MSG_MATCHOVER,
			        NotificationString.GAME_FRAME_PROPERTY
					];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName()){
				case NotificationString.GAME_ROOM_DATA:{
					switch(notification.getType()){
						case "user_status":{
							recvUserStatus(notification.getBody());
							break;
						}
					}
					
					break;
				}
				case NotificationString.CMD_GAME_FRAME:{					
					switch(notification.getType()){
						case "start" :
							var body:DisplayObject = notification.getBody() as DisplayObject;
							body.name = "gameBody";					
							view.gameArea.addChild(body);
							break
						case "remove" :
							if(view.gameArea.getChildByName("gameBody")!=null){
								view.gameArea.removeChild(view.gameArea.getChildByName("gameBody"));
							}
							break;
						case "exitFrame":
							var obj:Object = notification.getBody();
							switch(obj["messageCode"])
							{
								case 0:		//用户强制关闭
								{
									bForceExitFrame = true;
									break;
								}
								case 1:		//因网络断开而关
								{
									exitFrame();
									break;
								}
								case 2:		//比赛场中的强制关闭
								{
									//需要退到大厅
									exitFrame();
									sendNotification(NotificationString.EXIT_ROOM);
									break;
								}
							}
							
							break;
					}				
					break;			
				}
				case NotificationString.GAME_CHAT_INPUT:{
					//trace("NotificationString.GAME_CHAT_INPUT---------------------->>");
					displayMessage(notification.getBody() as Object);
					break;
				}
				case NotificationString.MSG_GAMEFRAME:		//在游戏区上方显示的消息
				{
					displayGameMessage(notification.getBody() as Object);
					break;
				}
				case NotificationString.MSG_MATCHOVER:		//比赛场中比赛结束的奖状
				{
					displayMacthOver(notification.getBody() as Object);					
					break;
				}
				case NotificationString.GAME_FRAME_PROPERTY:
				{
					//道具动画播放
					var obj = notification.getBody();
					playProps(obj["propertyID"],obj["coordinate"]);
		
				}
			}
		}
		private function recvUserStatus(obj:Object):void{
			var userNowStatus:tagUserStatus = obj["userNowStatus"];
			//站立状态 退出框架
			if(
			  (userNowStatus.dwUserID == tagGlobalUserData.dwUserID) 
			  && (userNowStatus.cbUserStatus == GlobalDef.US_FREE)
			  && (
				  ((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre!=GlobalDef.GAME_GENRE_MATCH)
				  ||bForceExitFrame
				 )
			)
			{
				exitFrame();
			}
			if(UserManager.getInstance().getMeItem().GetUserID() == userNowStatus.dwUserID){
				switch(userNowStatus.cbUserStatus){
					case GlobalDef.US_SIT:
					{
						if((facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).getCurrentGameItem().getServerConfigInfo().wGameGenre==GlobalDef.GAME_GENRE_MATCH){
							readyGame();
						}
						break;
					}
				}
			}
			if(userNowStatus.dwUserID == UserManager.getInstance().getMeItem().GetUserID())
				updateData();
		}
		
		/**
		 * 关闭游戏框架
		 * 
		 */
		private function exitFrame():void{
			if(facade.hasMediator(GameFrameMediator.NAME)){
				facade.removeMediator(GameFrameMediator.NAME);
			}
		}
		override public function onRegister():void
		{
			if(view.initialized){
				init();
			}else{
				view.addEventListener(FlexEvent.INITIALIZE,init);
			}

			if(view.isPopUp == false){ 
				//PopUpManager.addPopUp(view,ModuleLib.getInstance().gameStage,true);
				  PopUpEffect.Show(view,ModuleLib.getInstance().gameStage,true);			
			}	

	
		}
		public function dataGridArr():ArrayCollection{
			return view.dataArr as ArrayCollection
		}

		
		override public function onRemove():void
		{
			msgTimer.reset();
			msgTimer.removeEventListener(TimerEvent.TIMER,onMsgTimer);
			
			view.MessageText.text = "";
			
			//清空聊天面板上的信息
			view.chatGameText.cleanAll();
			
			bForceExitFrame = false;
			
			//view.waitLabel.visible = false;
			//移除GameFrameDataGridMediator
			if(facade.hasMediator(GameFrameDataGridMediator.NAME)){
				facade.removeMediator(GameFrameDataGridMediator.NAME);
			}
			//
			if(facade.hasProxy(GameFrameProxy.NAME)){
				facade.removeProxy(GameFrameProxy.NAME);
			}
			//
			removeEvent();
			//
			if(view.isPopUp==true){
				//PopUpManager.removePopUp(view);
				PopUpEffect.Hide(view);
			}
			if(matchOver){
				if(matchOver.isPopUp == true){
					PopUpManager.removePopUp(matchOver as IFlexDisplayObject);
				}
			} 
			mouseRestore();
		}
		
		/**
		 *  设置个人信息
		 */
		private function setData():void{		
			 var itemMe:IUserItem =  UserManager.getInstance().getMeItem();
			 var userData:tagUserData = itemMe.GetUserData();
			 view.nickname.text = userData.szNickName;
			
			var gameManager:GameManagerProxy = facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy;
			 view.title.text =  gameManager.getCurrentGameItem().getGameName() + " - " + gameManager.getCurrentServerItem().getServerName();
			 var headUrl:String;
			 if(userData.wFaceID<10){
            	 headUrl = HallConfig.getInstance().getPhotoFile()+"0"+userData.wFaceID+".png";
            }else{
            	headUrl = HallConfig.getInstance().getPhotoFile()+userData.wFaceID+".png"
           	}
			 view.headPic.url = headUrl;
			 
			//更新积分
			updateData();
			 
		}
		
		/**
		 * 更新积分状态信息
		 * 
		 */
		private function updateData():void
		{
			var itemMe:IUserItem =  UserManager.getInstance().getMeItem();
			var userData:tagUserData = itemMe.GetUserData();
			
			view.U_quan.text = userData.lUserUQ.toString();
			view.U_bean.text = userData.lGameGold.toString();
			view.grade.level = userData.cbHonorLevel;
		}
		
		/**
		 * 
		 * @param evt 游戏说明的网址
		 */
		private function questionBtn(evt:MouseEvent):void{
			var _name:String = ((facade.retrieveMediator(TableAreaMediator.NAME) as TableAreaMediator).ClassName);
			var obj:Object = HallConfig.getInstance().getLink(_name);
			GameUtil.webLink(obj["url"]);
		}
		/**
		 * 初始化游戏
		 * 发送游戏名至GameFrameProxy
		 */
		private function initGame():void{
			var gameName:String = ((facade.retrieveMediator(TableAreaMediator.NAME) as TableAreaMediator).ClassName);
			sendNotification(NotificationString.CMD_GAME_FRAME,gameName,"regist");
			
		}
		
		private function onClickSendHandler(event:MouseEvent):void
		{
			sendMessage();	
		}
		
		private function onShowEmotionChooser(event:MouseEvent):void
		{
			view.emotionChooser.visible = !view.emotionChooser.visible;	
		}
		
		private function onSelectEmotion(event:gameEvent):void
		{
			var _id:String = event.data.toString();
		 	var _name:String = findEmotionName(_id);
		 	
		 	if((view.chatMsg.text + _name).length > 40)
		 	{
		 		return;	
		 	}
		 	else
		 	{
		 		view.chatMsg.text += _name;
		 	}	
		}
		private function onKeyDown(evt:KeyboardEvent):void{
			if(evt.charCode==Keyboard.ENTER){
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
		 		view.chatMsg.text = "";
		 		//_targetUserID = view.chatTarget.selectedLabel;
		 		var _msgObj:Object = {"send":"","color":_color,"targetUserID":_targetUserID,"chatMessage":_chatMessage};
		 		sendNotification(NotificationString.CMD_FRAME_USER,_msgObj,CMD_DEF_ROOM.SUB_GF_USER_CHAT.toString());
		 		view.validateNow();
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
		 				if(_msg.indexOf("/",_startIndex) == 0)
		 				{
		 					_chatMessage +=("|"+_subStr+"|");
		 				}
		 				else if(_msg.indexOf("/",_startIndex) != 0 && !_preEmotion)
		 				{
		 					
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
		 		
		 		if((_startIndex <_msg.indexOf("/",_startIndex)) && (_msg.substring(_startIndex,_msg.indexOf("/",_startIndex)) != ""))
		 		{
		 			_preEmotion = false;
		 			_chatMessage += _msg.substring(_startIndex,_msg.indexOf("/",_startIndex));
		 		}
		 		else if(_msg.indexOf("/",_startIndex) < 0)
		 		{
		 			_chatMessage += _msg.substring(_startIndex,_msg.length);
		 			_preEmotion = false;
		 			_startIndex  = -1;
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
		 	var _timer:Timer = event.target as Timer;
		 	_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
		 	view.chatGameText.dispalyMsg(_outPutMsg);
		 	_outPutMsg = "";
		 	//view.chatMsg.text = "";
		 }
		 
		 /**
		  * 显示消息
		  * @param msgObj
		  * 
		  */
		 private function displayGameMessage(msgObj:Object):void
		 {
		 	view.MessageText.text = msgObj["message"];
		 	
		 	if(msgObj["timeDelay"]>0){
		 		if(msgTimer.running){
		 			msgTimer.reset();
		 		}
		 		msgTimer.delay = msgObj["timeDelay"];
		 		msgTimer.start();
		 	}
		 	
		 }
		 private function onMsgTimer(evt:TimerEvent = null):void{
		 	msgTimer.stop();
		 	
		 	view.MessageText.text = "";
		 }
		 
		 private function matchOverHandle(evt:Event):void
		 {
		 	PopUpManager.removePopUp(matchOver as IFlexDisplayObject);
		 	closeView();
		 }
		 
		 private function displayMacthOver(obj:Object):void
		 {
		 	//给matchOver传参
		 	matchOver.userName = obj["userName"];
		 	matchOver.roomName = obj["roomName"];
		 	matchOver.rank = obj["rank"];
		 	matchOver.UD = obj["UD"];
		 	matchOver.honour = obj["honour"];
		 	matchOver.date = obj["date"];
		 	
		 	//更新matchOver显示
		 	matchOver.updateView();
		 	
		 	//显示
			PopUpManager.addPopUp(matchOver as IFlexDisplayObject,this.view,true,PopUpManagerChildList.PARENT);
			PopUpManager.centerPopUp(matchOver as IFlexDisplayObject);
		 }
	}
}