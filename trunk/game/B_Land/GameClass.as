package B_Land
{
	import Application.model.interfaces.IGameClass;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.utils.GameUtil;
	import Application.utils.Memory;
	
	import B_Land.common.CMD_C_LandScore;
	import B_Land.common.CMD_C_OutCard;
	import B_Land.common.CMD_C_UserTrustee;
	import B_Land.common.CMD_Land;
	import B_Land.common.CMD_S_GameEnd;
	import B_Land.common.CMD_S_GameStart;
	import B_Land.common.CMD_S_LandScore;
	import B_Land.common.CMD_S_OutCard;
	import B_Land.common.CMD_S_PassCard;
	import B_Land.common.CMD_S_SendAllCard;
	import B_Land.common.CMD_S_StatusFree;
	import B_Land.common.CMD_S_StatusPlay;
	import B_Land.common.CMD_S_StatusScore;
	import B_Land.common.GameLogic;
	import B_Land.common.GameLogicDef;
	import B_Land.common.MaterialLib;
	
	import common.data.GlobalDef;
	import common.data.StringDef;
	import common.data.gameEvent;
	import common.game.GameBaseClass;
	import common.game.GameBaseView;
	import common.game.vo.TagServerAttribute;
	
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;


	public class GameClass extends GameBaseClass
	{
		//游戏定时器
		private static const IDI_OUT_CARD:int=200; //出牌定时器
		private static const IDI_MOST_CARD:int=201; //最大定时器
		private static const IDI_EXIT_GAME:int=202; //离开游戏定时器
		private static const IDI_LAND_SCORE:int=203; //叫分定时器
		private static const IDI_LAST_TURN_CARD:uint=204; //上轮定时器

		protected static var TIME_OUT_CARD:uint=30; //出牌时间
		protected static var TIME_MOST_OUT_CARD:uint=3; //叫牌时间
		
		//游戏变量
		protected var m_wLandUser:uint; //用户
		protected var m_wBombTime:uint; //炸弹倍数
		protected var m_bCardCount:Array; //扑克数目
		protected var m_bHandCardCount:uint; //扑克数目
		protected var m_bHandCardData:Array; //手上扑克
		protected var m_cbOutCardCount:Array; //出牌数目
		protected var m_cbOutCardData:Array; //出牌列表
		protected var m_bPass:Array; //放弃数组
		protected var m_wFirstOutUser:uint;
		protected var m_wCurrentUser:uint; //当前玩家椅子号(牌权)

		//出牌变量
		protected var m_bLastTurn:Boolean; //上轮标志
		protected var m_bTurnOutType:uint; //出牌类型
		protected var m_bTurnCardCount:uint; //出牌数目
		protected var m_bTurnCardData:Array; //出牌列表

		//配置变量
		protected var m_bDeasilOrder:Boolean; //出牌顺序
		protected var m_dwCardHSpace:uint; //扑克象素
		protected var m_bStustee:Boolean; //托管标志

		//辅助变量
		protected var m_wMostUser:uint; //最大玩家
		protected var m_wTimeOutCount:uint; //超时次数

		//控件变量
		protected var m_GameLogic:GameLogic; //游戏逻辑
		
		//积分变量
		protected var lTurnScore:Array;			//积分信息LONGLONG
		protected var lCollectScore:Array;		//积分信息LONGLONG
		
		private var isBoy:Boolean = false; //是否为男性
		private var ownSex:Boolean = false;//自己是否为男性
		
		private var _sendTimer:Timer ;//发牌时间
		private var _cardCountTimer:uint = 1;//发牌计数
		private var _wCurrentUser:uint;//当前玩家编号
		
		private var _sortType:Boolean = false;//是否采用类型排序
		private var _isMathch:Boolean = false;//是否是比赛房间
		public function GameClass()
		{

			super();

		}

		/**
		 * 初始化gameClass，此时已经获得游戏资源，
		 * 	并且父类当中已经初始化好计时器及调用该子类的CreateGameView创建好游戏界面并addChild
		 * @return
		 *
		 */
		override public function InitGameClass():Boolean
		{
			if (super.InitGameClass() == false)
			{
				return false;
			}
			/*==============变量初始化==============================*/
			m_bCardCount=new Array(CMD_Land.GAME_PLAYER); //扑克数目
			m_bHandCardCount: uint; //扑克数目
			m_bHandCardData=new Array(20); //手上扑克
			m_cbOutCardCount=new Array(CMD_Land.GAME_PLAYER); //出牌数目
			m_cbOutCardData=new Array(CMD_Land.GAME_PLAYER); //出牌列表
			m_bPass=new Array(CMD_Land.GAME_PLAYER); //放弃数组
			m_bTurnCardData=new Array(20); //出牌列表
			lTurnScore= new Array(CMD_Land.GAME_PLAYER);	//上一轮积分信息LONGLONG
			lCollectScore = new Array(CMD_Land.GAME_PLAYER);//历史积分积分信息LONGLONG
			_sendTimer = new Timer(150,17);
			/*============================================*/
			m_wBombTime=1;
			m_bHandCardCount=0;
			m_wLandUser=GlobalDef.INVALID_CHAIR;


			Memory.ZeroArray(m_bCardCount, 0);
			Memory.ZeroArray(m_bHandCardData, 0x43);

			for (var i:uint=0; i < m_cbOutCardCount.length; i++)
			{
				m_cbOutCardCount[i]=new Array(2);
			}
			for (i=0; i < m_bPass.length; i++)
			{
				m_bPass[i]=new Array(2);
			}
			for (i=0; i < m_cbOutCardData.length; i++)
			{
				m_cbOutCardData[i]=new Array(2);
				for (var k:uint=0; k < m_cbOutCardData[i].length; k++)
				{
					m_cbOutCardData[i][k]=new Array(20);
				}
			}
			Memory.ZeroThreeDimensionArray(m_cbOutCardData);
			Memory.ZeroTwoDimensionArray(m_cbOutCardCount);
			Memory.ZeroTwoDimensionArray(m_bPass, false);


			//配置变量
			m_bDeasilOrder=false;
			m_dwCardHSpace=GameLogicDef.DEFAULT_PELS; //默认像素
			m_bStustee=false;
			
			//出牌变量
			m_bTurnCardCount=0;
			m_bTurnOutType=GameLogicDef.CT_INVALID;
			Memory.ZeroArray(m_bTurnCardData, 0);
			m_bLastTurn=false;
			m_wFirstOutUser=GlobalDef.INVALID_CHAIR;

			//辅助变量
			m_wTimeOutCount=0;
			m_wMostUser=GlobalDef.INVALID_CHAIR;
			m_GameLogic=new GameLogic();

			//读取配置
			m_dwCardHSpace=GameLogicDef.DEFAULT_PELS;
			m_bDeasilOrder=false;

			//调整参数
			if ((m_dwCardHSpace > GameLogicDef.MAX_PELS) || (m_dwCardHSpace < GameLogicDef.LESS_PELS))
			{
				m_dwCardHSpace=GameLogicDef.DEFAULT_PELS;
			}
			//配置控件
			GetPeerGameView().SetUserOrder(m_bDeasilOrder);
			GetPeerGameView().m_HandCardControl.SetCardSpace(m_dwCardHSpace, 0, 20);
			GetPeerGameView().addEventListener(GameViewEvent.strGameViewEvent, OnGameViewEevent);
			GetPeerGameView().addEventListener(gameEvent.USE_PROP,OnGameViewPropEvent);

			
			AddGameSound("GAME_WARN", MaterialLib.getInstance().getClass("SOUND_GAME_WARN"));
			AddGameSound("GAME_WIN", MaterialLib.getInstance().getClass("SOUND_GAME_WIN"));
			AddGameSound("GAME_LOST", MaterialLib.getInstance().getClass("SOUND_GAME_LOST"));
			AddGameSound("OUT_CARD", MaterialLib.getInstance().getClass("SOUND_OUT_CARD"));
			AddGameSound("BOMP", MaterialLib.getInstance().getClass("SOUND_BOMB"));
			AddGameSound("PASS_CARD", MaterialLib.getInstance().getClass("SOUND_PASS_CARD"));
			AddGameSound("PASS_SCORE_M", MaterialLib.getInstance().getClass("SOUND_PASSSCORE_M"));
			AddGameSound("PASS_SCORE_W", MaterialLib.getInstance().getClass("SOUND_PASSSCORE_W"));
			AddGameSound("WASH_CARD", MaterialLib.getInstance().getClass("SOUND_WASH_CARD"));
			AddGameSound("TWO_SCORE_M", MaterialLib.getInstance().getClass("SOUND_TWOSCORE_M"));
			AddGameSound("TWO_SCORE_W", MaterialLib.getInstance().getClass("SOUND_TWOSCORE_W"));
			AddGameSound("PLANE", MaterialLib.getInstance().getClass("SOUND_PLANE"));
			AddGameSound("ROCKET", MaterialLib.getInstance().getClass("SOUND_ROCKET"));
			AddGameSound("THREE_SCORE_M", MaterialLib.getInstance().getClass("SOUND_THREESCORE_M"));
			AddGameSound("THREE_SCORE_W", MaterialLib.getInstance().getClass("SOUND_THREESCORE_W"));
			AddGameSound("ONE_SCORE_M", MaterialLib.getInstance().getClass("SOUND_ONESCORE_M"));
			AddGameSound("ONE_SCORE_W", MaterialLib.getInstance().getClass("SOUND_ONESCORE_W"));
			//AddGameSound("SOUND_BG",MaterialLib.getInstance().getClass("SOUND_BG"));
			return true;
		}

		override protected function CreateGameView():GameBaseView
		{

			return new GameView(this);

		}

		public function QueryIGameClass():IGameClass
		{
			return this as GameBaseClass as IGameClass;
		}

		protected function GetPeerGameView():GameView
		{
			if (m_GameClientView == null)
			{
				throw Error("GetPeerGameView m_GameClientView == null");
				return null;
			}
			return m_GameClientView as GameView;
		}

		/*===============================================*/


		override public function DestroyGameClass():void
		{
			//游戏变量
			m_wBombTime=1;
			m_bHandCardCount=0;
			m_wLandUser=GlobalDef.INVALID_CHAIR;

			m_bCardCount=null;
			m_bHandCardData=null;
			m_cbOutCardCount=null;
			m_cbOutCardData=null;
			m_bPass=null;
			
			_isMathch = false;

			//出牌变量
			m_bTurnCardCount=0;
			m_bTurnOutType=GameLogicDef.CT_INVALID;
			Memory.ZeroArray(m_bTurnCardData);
			m_bTurnCardData=null;
			
			GetPeerGameView().viewComponent.leftExp.visible =false;
			GetPeerGameView().viewComponent.rightExp.visible = false;
			GetPeerGameView().viewComponent.ownerExp.visible = false;
			//积分变量
			if(lTurnScore) lTurnScore.splice(0,lTurnScore.length);
			if(lCollectScore) lCollectScore.splice(0,lCollectScore.length);
			lTurnScore = null;
			lCollectScore = null;
			
			//辅助变量
			m_wTimeOutCount=0;
			m_wMostUser=GlobalDef.INVALID_CHAIR;
			if (GetPeerGameView())
				GetPeerGameView().removeEventListener(GameViewEvent.strGameViewEvent, OnGameViewEevent);
			m_GameLogic=null;
			
			if(_sendTimer.hasEventListener(TimerEvent.TIMER)){
				_sendTimer.removeEventListener(TimerEvent.TIMER,onSendTimer)
				_sendTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onSendTimerOver);
				_sendTimer.stop();
			}
			_sendTimer = null;
			super.DestroyGameClass();

		}
		/* ===========================扩充父类方法=========================================== */
		/**
		 * 新玩家来
		 * @param pUserData
		 * @param wChairID
		 * @param bLookonUser
		 * 
		 */
		override protected function OnEventUserEnter(pUserData:tagUserData, wChairID:uint, bLookonUser:Boolean):void
		{
			super.OnEventUserEnter(pUserData, wChairID, bLookonUser);
			
			lCollectScore[wChairID] = 0;
			lTurnScore[wChairID] = 0;			
			
			updateCollectScoreView();


			if(GetMeChairID()==pUserData.wChairID){
				//设置准备按钮可见
				//GetPeerGameView().viewComponent.m_btStart.visible=true;
				SetGameTimer(GetMeChairID(), IDI_EXIT_GAME, 30);
				if(_isMathch){
					GetPeerGameView().viewComponent.ownerExp.visible = true;
					OnStart(0,0);
				}
				GetPeerGameView().viewComponent.ownerExp.percent = GameUtil.socreToexp(pUserData.lScore);
				GetPeerGameView().viewComponent.ownerExp.toolTip = GameUtil.replaceText(StringDef.SCORE,{num:pUserData.lScore});
			}
			var viewId:int = this.SwitchViewChairID(wChairID)
			switch(viewId){
				case 0:
					GetPeerGameView().viewComponent.leftExp.percent = GameUtil.socreToexp(pUserData.lScore);
					GetPeerGameView().viewComponent.leftExp.toolTip = GameUtil.replaceText(StringDef.SCORE,{num:pUserData.lScore});
					if((GetServerAttribute() as TagServerAttribute).wGameGenre==GlobalDef.GAME_GENRE_MATCH){
						GetPeerGameView().viewComponent.leftExp.visible = true;
					}
					break;
				case 2:
					GetPeerGameView().viewComponent.rightExp.percent = GameUtil.socreToexp(pUserData.lScore);
					GetPeerGameView().viewComponent.rightExp.toolTip = GameUtil.replaceText(StringDef.SCORE,{num:pUserData.lScore});
					if((GetServerAttribute() as TagServerAttribute).wGameGenre==GlobalDef.GAME_GENRE_MATCH){
						GetPeerGameView().viewComponent.rightExp.visible = true;
					}
					break
			}
	
		}
		/**
		 * 
		 * 重载配置完成
		 */
		override protected function configComplete():void{
			//判断是否是比赛房间是否显示积分		
			if((GetServerAttribute() as TagServerAttribute).wGameGenre==GlobalDef.GAME_GENRE_MATCH){
				GetPeerGameView().viewComponent.socreHistory.visible = false;
				GetPeerGameView().viewComponent.ownerExp.visible = true;
				_isMathch = true;
			}else{
				GetPeerGameView().viewComponent.socreHistory.visible = true;
				_isMathch = false;
			}

		}
		/**
		 * 有玩家离开
		 * @param pUserData
		 * @param wChairID
		 * @param bLookonUser
		 * 
		 */
		override protected function OnEventUserLeft(pUserData:tagUserData, wChairID:uint, bLookonUser:Boolean):void
		{
			super.OnEventUserLeft(pUserData, wChairID, bLookonUser);
			
			lCollectScore[wChairID] = 0;
			lTurnScore[wChairID] = 0;
			
			updateCollectScoreView();			
			
			var wViewChairID:uint=this.SwitchViewChairID(wChairID);
			switch(wViewChairID){
				case 0:
					GetPeerGameView().viewComponent.leftName.text = "";
					GetPeerGameView().viewComponent.leftLeaveCard.text = "";
					GetPeerGameView().viewComponent.leftExp.visible = false;
					break;
				case 2:
					GetPeerGameView().viewComponent.rightLeaveCard.text = "";
					GetPeerGameView().viewComponent.rightName.text = "";
					GetPeerGameView().viewComponent.rightExp.visible = false;
					break;

			}
		}
		
		/* ============================功能方法======================================== */
		private function updateCollectScoreView():void
		{
			for(var i:int = 0; i<CMD_Land.GAME_PLAYER; i++){
				var userName:String = (GetUserInfo(i) as tagUserData)?(GetUserInfo(i) as tagUserData).szName:"";
				GetPeerGameView().m_ScoreViewHistory.SetGameScore(userName,lTurnScore[i],lCollectScore[i]);				
			}
		}
		/* ========================================================================== */
		override protected function OnStart(wParam:uint, lParam:uint):uint
		{
			//设置变量
			Memory.ZeroThreeDimensionArray(m_cbOutCardData);
			Memory.ZeroTwoDimensionArray(m_cbOutCardCount);
			Memory.ZeroTwoDimensionArray(m_bPass, false);

			m_wBombTime=1;
			m_wTimeOutCount=0;
			m_bHandCardCount=0;
			m_bTurnCardCount=0;
			m_bTurnOutType=GameLogicDef.CT_INVALID;
			m_wMostUser=GlobalDef.INVALID_CHAIR;
			Memory.ZeroArray(m_bHandCardData);
			Memory.ZeroArray(m_bTurnCardData);

			GetPeerGameView().SetCardCount(GlobalDef.INVALID_CHAIR, 0);

			GetPeerGameView().viewComponent.m_btStart.visible=false;
			GetPeerGameView().m_ScoreView.ShowWindow(false);
			//设置扑克
			GetPeerGameView().m_BackCardControl.SetCardData(null, 0);
			GetPeerGameView().m_HandCardControl.SetCardData(null, 0);
			GetPeerGameView().m_HandCardControl.SetPositively(false);
			GetPeerGameView().m_LeaveCardControl[0].SetCardData(null, 0);
			GetPeerGameView().m_LeaveCardControl[1].SetCardData(null, 0);			
	
			GetPeerGameView().viewComponent.m_landView.landName.text = "";
			GetPeerGameView().viewComponent.m_landView.landScore.text = "";
			
			KillGameTimer(IDI_EXIT_GAME);
			for (var i:int=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				GetPeerGameView().m_UserCardControl[i].SetCardData(null, 0);
			}
			if (m_bStustee=true)
			{
				m_bStustee=false;
			
				GetPeerGameView().viewComponent.m_bTrustCard.selected = false; 
		    	GetPeerGameView().viewComponent.m_bTrustCard.enabled=false;
			
			}
			var userData:tagUserData = m_pUserItem[GetMeChairID()] as tagUserData;

		    ownSex = userData.cbGender==GlobalDef.GENDER_BOY?true:false;
		    
		    GetPeerGameView().viewComponent.leftLeaveCard.text="";
		    GetPeerGameView().viewComponent.rightLeaveCard.text="";
	     
			//发送消息
			SendUserReady(null, 0);

			return 0;
		}
		//叫分消息
		protected function OnLandScore(wParam:uint, lParam:uint):void
		{
			KillGameTimer(IDI_LAND_SCORE);
			GetPeerGameView().viewComponent.m_btGiveUpScore.visible=false;
			GetPeerGameView().viewComponent.m_btOneScore.visible=false;
			GetPeerGameView().viewComponent.m_btTwoScore.visible=false;
			GetPeerGameView().viewComponent.m_btThreeScore.visible=false;
			var landScore:CMD_C_LandScore=new CMD_C_LandScore();
			landScore.bLandScore=wParam;
			var sendData:ByteArray=landScore.toByteArray();
			SendGameData(CMD_Land.SUB_C_LAND_SCORE, sendData, CMD_C_LandScore.sizeof_CMD_C_LandScore); //这里命令号可能有问题		

		}

		//点击扑克
		protected function OnLeftHitCard(wParam:uint, lParam:uint):void
		{
			//设置控件
			var bOutCard:Boolean=VerdictOutCard();
			GetPeerGameView().viewComponent.m_btOutCard.enabled=(bOutCard ? true : false);
		}

		//左键扑克   估计没用 
		protected function OnRightHitCard(wParam:uint, lParam:uint):void
		{
			//用户出牌
			OnOutCard(0, 0);
		}

		protected function OnOutCard(wParam:uint, lParam:uint):void
		{
			//状态判断
			if ((GetPeerGameView().viewComponent.m_btOutCard.visible == false) || (GetPeerGameView().viewComponent.m_btOutCard.enabled == false))
			{
				return;
			}

			//设置界面
			KillGameTimer(IDI_OUT_CARD);
			GetPeerGameView().viewComponent.m_btOutCard.visible=false;
			GetPeerGameView().viewComponent.m_btPassCard.visible=false;
			GetPeerGameView().viewComponent.m_btAutoOutCard.visible=false;
			GetPeerGameView().viewComponent.m_btOutCard.enabled=false;
			GetPeerGameView().viewComponent.m_btPassCard.enabled=false;
			GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=false;



			var OutCard:CMD_C_OutCard=new CMD_C_OutCard;
			OutCard.bCardCount=GetPeerGameView().m_HandCardControl.GetShootCard(OutCard.bCardData, OutCard.bCardData.length);
			var sendData:ByteArray=OutCard.toByteArray();
			SendGameData(CMD_Land.SUB_C_OUT_CARD, sendData, 1 + OutCard.bCardCount);

			//预先显示
			//PlayGameSound("OUT_CARD");
			GetPeerGameView().m_UserCardControl[1].SetCardData(OutCard.bCardData, OutCard.bCardCount);

			//预先删除
			var bSourceCount:uint=m_bHandCardCount;
			m_bHandCardCount-=OutCard.bCardCount;
			m_GameLogic.RemoveCard(OutCard.bCardData, OutCard.bCardCount, m_bHandCardData, bSourceCount);
			GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);

		}

		//发牌数据
		protected function OnSubSendCard(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			//效验数据
			if (wDataSize != CMD_S_SendAllCard.sizeof_CMD_S_SendAllCard)
			{
				return false;
			}

			//变量定义
			var pSendCard:CMD_S_SendAllCard=CMD_S_SendAllCard.readData(pBuffer);
			//设置数据
			m_wCurrentUser=pSendCard.wCurrentUser;
			m_bHandCardCount=17;
			Memory.CopyArray(m_bHandCardData, pSendCard.bCardData[GetMeChairID()], pSendCard.bCardData[GetMeChairID()].length);
			for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				//fix me
				m_bCardCount[i]=17;
			}
			//设置界面
			for (i=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				m_bPass[i][0]=false;
				GetPeerGameView().SetLandScore(i, 0);
				GetPeerGameView().SetPassFlag(i, false);
				GetPeerGameView().SetCardCount(i, m_bCardCount[i]);
				GetPeerGameView().m_UserCardControl[i].SetCardData(null, 0);
			}
			//GetPeerGameView().ShowLandTitle(true);
			GetPeerGameView().SetBombTime(m_wBombTime);
			

		

			
			//设置扑克
			var bCardData:Array=GenEmptyCardData(17);
			//UpdateLeaveCardControl(bCardData);
			
		

			GetPeerGameView().m_BackCardControl.SetCardData(bCardData, 3);	
			_wCurrentUser = pSendCard.wCurrentUser;
			m_GameLogic.SortCardList(m_bHandCardData, m_bHandCardCount,_sortType);
			//GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
			//GetPeerGameView().m_HandCardControl.SetDisplayFlag(true);
			//发牌动画
			sendCardMoition();
			//当前玩家
	/* 		if ((IsLookonMode() == false) && (m_wCurrentUser == GetMeChairID()))
			{
				//ActiveGameFrame();
				GetPeerGameView().viewComponent.m_btGiveUpScore.visible=true;
				GetPeerGameView().viewComponent.m_btOneScore.visible=true;
				GetPeerGameView().viewComponent.m_btTwoScore.visible=true;
				GetPeerGameView().viewComponent.m_btThreeScore.visible=true;

			} */
			
		//	SetGameTimer(pSendCard.wCurrentUser, IDI_LAND_SCORE, 30);
			return true;
		}
		private function sendCardMoition():void{
			if(!_sendTimer.hasEventListener(TimerEvent.TIMER)){
				_sendTimer.addEventListener(TimerEvent.TIMER,onSendTimer);
				_sendTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onSendTimerOver);	
			}			
			_sendTimer.reset();	
			_sendTimer.start();
			
		}
		private function onSendTimer(evt:TimerEvent):void{
			PlayGameSound("OUT_CARD");
			GetPeerGameView().m_LeaveCardControl[0].SetCardData(GenEmptyCardData(17),_cardCountTimer);
			GetPeerGameView().m_LeaveCardControl[1].SetCardData(GenEmptyCardData(17),_cardCountTimer);
			GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, _cardCountTimer);
			_cardCountTimer++;
			
		}
		private function onSendTimerOver(evt:TimerEvent):void{
			_cardCountTimer = 1;
			UpdateLeaveCardControl(GenEmptyCardData(17));
			GetPeerGameView().viewComponent.backCardBox.visible = true;
			GetPeerGameView().viewComponent.m_landView.visible = true;
			GetPeerGameView().viewComponent.m_sortCard.enabled = true;
			if ((IsLookonMode() == false) && (_wCurrentUser == GetMeChairID()))
			{
				//ActiveGameFrame();
				GetPeerGameView().viewComponent.m_btGiveUpScore.visible=true;
				GetPeerGameView().viewComponent.m_btOneScore.visible=true;
				GetPeerGameView().viewComponent.m_btTwoScore.visible=true;
				GetPeerGameView().viewComponent.m_btThreeScore.visible=true;

			} 
			
			//设置时间
			SetGameTimer(_wCurrentUser, IDI_LAND_SCORE, 30);
		}
		//放弃出牌
		protected function OnPassCard(wParam:uint, lParam:uint):void
		{
			//状态判断
			if (GetPeerGameView().viewComponent.m_btPassCard.enabled == false)
			{
				return;
			}

			//设置界面
			KillGameTimer(IDI_OUT_CARD);
			GetPeerGameView().viewComponent.m_btOutCard.visible=false;
			GetPeerGameView().viewComponent.m_btPassCard.visible=false;
			GetPeerGameView().viewComponent.m_btAutoOutCard.visible=false;
			GetPeerGameView().viewComponent.m_btOutCard.enabled=false;
			GetPeerGameView().viewComponent.m_btPassCard.enabled=false;
			GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=false;

			//发送数据
			SendGameData(CMD_Land.SUB_C_PASS_CARD);

			//预先显示
			m_bPass[1][0]=true;
			GetPeerGameView().SetPassFlag(1, true);
			//PlayGameSound("PASS_CARD");
			GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
			var bCardData:Array=GenEmptyCardData(20);
			UpdateLeaveCardControl(bCardData);

		}

		protected function OnSubLandScore(pBuffer:ByteArray, wDataSize:uint):Boolean
		{

			if (wDataSize != CMD_S_LandScore.sizeof_CMD_S_LandScore)
			{
				return false;
			}
			//消息处理
			var pLandScore:CMD_S_LandScore=CMD_S_LandScore.readData(pBuffer);
			//设置界面
			var userData:tagUserData = m_pUserItem[pLandScore.wLandUser] as tagUserData;
		    isBoy = userData.cbGender==GlobalDef.GENDER_BOY?true:false;
			var wViewChairID:uint=SwitchViewChairID(pLandScore.wLandUser);
								 
			GetPeerGameView().SetLandScore(wViewChairID, pLandScore.bLandScore);
			//玩家设置
			if ((IsLookonMode() == false) && (pLandScore.wCurrentUser == GetMeChairID()))
			{
				//ActiveGameFrame();

				GetPeerGameView().viewComponent.m_btGiveUpScore.visible=true;
				GetPeerGameView().viewComponent.m_btOneScore.visible=(pLandScore.bCurrentScore <= 0 ? true : false);
				GetPeerGameView().viewComponent.m_btTwoScore.visible=(pLandScore.bCurrentScore <= 1 ? true : false);
				GetPeerGameView().viewComponent.m_btThreeScore.visible=(pLandScore.bCurrentScore <= 2 ? true : false);
			}
				
			//播放声音
			switch(pLandScore.bCurrentScore){
				case 1:
					(isBoy)?PlayGameSound("ONE_SCORE_M"):PlayGameSound("ONE_SCORE_W");
					break;
				case 2:
					(isBoy)?PlayGameSound("TWO_SCORE_M"):PlayGameSound("TWO_SCORE_W");
					break;
				case 3:
					(isBoy)?PlayGameSound("THREE_SCORE_M"):PlayGameSound("THREE_SCORE_W");
					break;
				default:
					(isBoy)?PlayGameSound("PASS_SCORE_M"):PlayGameSound("PASS_SCORE_W");
					break
				
			}
			

			//设置时间
			SetGameTimer(pLandScore.wCurrentUser, IDI_LAND_SCORE, 30);

			return true;
		}

		//游戏开始
		protected function OnSubGameStart(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			//效验数据

			if (wDataSize != CMD_S_GameStart.sizeof_CMD_S_GameStart)
			{
				return false;
			}

			//消息处理
			var pGameStart:CMD_S_GameStart=CMD_S_GameStart.readData(pBuffer);

			//设置变量
			m_wBombTime=1;
			m_bTurnCardCount=0;
			m_bTurnOutType=GameLogicDef.CT_INVALID;
			m_wLandUser=pGameStart.wLandUser;
			m_bCardCount[pGameStart.wLandUser]=20;
			Memory.ZeroArray(m_bTurnCardData);
			
			if(pGameStart.bLandScore==3){
					var userData:tagUserData = m_pUserItem[pGameStart.wLandUser] as tagUserData;
		    		var isboyTemp:Boolean = userData.cbGender==GlobalDef.GENDER_BOY?true:false;
		    		(isboyTemp)?PlayGameSound("THREE_SCORE_M"):PlayGameSound("THREE_SCORE_W");
			}
			//设置控件
			//	GetPeerGameView().ShowLandTitle(false);
			GetPeerGameView().m_BackCardControl.SetCardData(pGameStart.bBackCard, pGameStart.bBackCard.length);

			//设置界面
			GetPeerGameView().SetLandScore(GlobalDef.INVALID_CHAIR, 0);
			GetPeerGameView().SetCardCount(SwitchViewChairID(pGameStart.wLandUser), m_bCardCount[pGameStart.wLandUser]);

			//地主设置
			if (pGameStart.wLandUser == GetMeChairID())
			{
				var bCardCound:uint=m_bHandCardCount;
				m_bHandCardCount+=pGameStart.bBackCard.length;
				Memory.CopyArray(m_bHandCardData, pGameStart.bBackCard, pGameStart.bBackCard.length, bCardCound);
				m_GameLogic.SortCardList(m_bHandCardData, m_bHandCardCount,_sortType);
				GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
			}
			else
			{

				m_GameLogic.SortCardList(m_bHandCardData, m_bHandCardCount,_sortType);
				GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);

			}
			//设置托管按钮
			GetPeerGameView().viewComponent.m_bTrustCard.enabled=true;
			//设置地主头像
			GetPeerGameView().SetLandUser(SwitchViewChairID(pGameStart.wLandUser), pGameStart.bLandScore);

			//玩家设置
			if (IsLookonMode() == false)
			{
				GetPeerGameView().m_HandCardControl.SetPositively(true);
			}

			//当前玩家
			if ((IsLookonMode() == false) && (pGameStart.wCurrentUser == GetMeChairID()))
			{
				GetPeerGameView().viewComponent.m_btOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btPassCard.visible=true;
				GetPeerGameView().viewComponent.m_btAutoOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btOutCard.enabled=false;
				GetPeerGameView().viewComponent.m_btPassCard.enabled=false;
				GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=false;
			}

			//播放声音
			//	PlayGameSound("GAME_START");
			UpdateLeaveCardControl(GenEmptyCardData(20));
			//设置时间
			SetGameTimer(pGameStart.wCurrentUser, IDI_OUT_CARD, TIME_OUT_CARD);

			return true;
		}

		//用户出牌
		protected function OnSubOutCard(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			
			//变量定义
			var pOutCard:CMD_S_OutCard=CMD_S_OutCard.readData(pBuffer);
			var wHeadSize:uint=CMD_S_OutCard.sizeof_Header_CMD_S_OutCard;

			//效验数据
			if (wDataSize < wHeadSize)
			{
				return false;
			}

			if (wDataSize != (wHeadSize + pOutCard.bCardCount))
			{
				return false;
			}

			//删除定时器
			KillTimer(IDI_MOST_CARD);
			KillGameTimer(IDI_OUT_CARD);

			//界面设置
			var wOutViewChairID:uint=SwitchViewChairID(pOutCard.wOutCardUser);
			m_bCardCount[pOutCard.wOutCardUser]-=pOutCard.bCardCount;
			GetPeerGameView().SetCardCount(wOutViewChairID, m_bCardCount[pOutCard.wOutCardUser]);

			//出牌设置
			if ((IsLookonMode() == true) || (GetMeChairID() != pOutCard.wOutCardUser))
			{
				GetPeerGameView().m_UserCardControl[wOutViewChairID].SetCardData(pOutCard.bCardData, pOutCard.bCardCount);
			}

			//清理桌面
			if (m_bTurnCardCount == 0)
			{
				m_wFirstOutUser=pOutCard.wOutCardUser;
				for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
				{
					if (i == pOutCard.wOutCardUser)
					{
						continue;
					}
					GetPeerGameView().m_UserCardControl[SwitchViewChairID(i)].SetCardData(null, 0);
				}
				GetPeerGameView().SetPassFlag(GlobalDef.INVALID_CHAIR, false);
			}
			//历史扑克
			if ((m_bTurnCardCount == 0) && (m_wFirstOutUser != GlobalDef.INVALID_CHAIR && m_cbOutCardCount[m_wFirstOutUser][0] != 0))
			{
				//设置扑克
				for (i =0; i < CMD_Land.GAME_PLAYER; i++)
				{
					//保存扑克
					m_cbOutCardCount[i][1]=m_cbOutCardCount[i][0];
					m_bPass[i][1]=m_bPass[i][0];
					Memory.CopyArray(m_cbOutCardData[i][1], m_cbOutCardData[i][0], m_cbOutCardCount[i][0]);

					//清理扑克
					m_cbOutCardCount[i][0]=0;
					Memory.ZeroArray(m_cbOutCardData[i][0]);
					m_bPass[i][0]=false;
				}

			}
			//出牌记录
			m_cbOutCardCount[pOutCard.wOutCardUser][0]=pOutCard.bCardCount;
			Memory.CopyArray(m_cbOutCardData[pOutCard.wOutCardUser][0], pOutCard.bCardData, pOutCard.bCardCount);

			//当前界面
			SwitchToCurrentCard();

			//记录出牌
			m_bTurnCardCount=pOutCard.bCardCount;
			m_bTurnOutType=m_GameLogic.GetCardType(pOutCard.bCardData, pOutCard.bCardCount);
			Memory.CopyArray(m_bTurnCardData, pOutCard.bCardData, pOutCard.bCardCount);

			//炸弹判断
			if ((m_bTurnOutType == GameLogicDef.CT_BOMB_CARD))
			{
				m_wBombTime*=2;
				GetPeerGameView().SetBombTime(m_wBombTime);
				GetPeerGameView().ShowBombMotion();
				PlayGameSound("BOMP");
			}
			//判断火箭
			if(m_bTurnOutType == GameLogicDef.CT_MISSILE_CARD){
				m_wBombTime*=2;
				GetPeerGameView().SetBombTime(m_wBombTime);
				GetPeerGameView().showRocketMotion();
				PlayGameSound("ROCKET");
				
			}
			//判断飞机
			if( (m_bTurnOutType==GameLogicDef.CT_THREE_LINE_TAKE_ONE ||m_bTurnOutType==GameLogicDef.CT_THREE_LINE_TAKE_DOUBLE
				|| m_bTurnOutType==GameLogicDef.CT_FOUR_LINE_TAKE_ONE||  m_bTurnOutType==GameLogicDef.CT_FOUR_LINE_TAKE_DOUBLE) &&(m_bTurnCardCount>=8)){
				GetPeerGameView().showPlaneMotion();
				PlayGameSound("PLANE");
			}
			
			//自己扑克
			if ((IsLookonMode() == true) && (pOutCard.wOutCardUser == GetMeChairID()))
			{
				//删除扑克 
				var bSourceCount:uint=m_bHandCardCount;
				m_bHandCardCount-=pOutCard.bCardCount;
				m_GameLogic.RemoveCard(pOutCard.bCardData, pOutCard.bCardCount, m_bHandCardData, bSourceCount);

				//设置界面
				GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
			}
			//

			var bCardData:Array=GenEmptyCardData(20);
			UpdateLeaveCardControl(bCardData);
			//最大判断
			if (pOutCard.wCurrentUser == pOutCard.wOutCardUser)
			{
				//设置变量
				m_bTurnCardCount=0;
				m_bTurnOutType=GameLogicDef.CT_INVALID;
				m_wMostUser=pOutCard.wCurrentUser;
				Memory.ZeroArray(m_bTurnCardData);

				//设置界面
				for (i=0; i < CMD_Land.GAME_PLAYER; i++)
				{
					if (i != pOutCard.wOutCardUser)
					{
						m_bPass[i][0]=true;
						var wViewChairID:uint=SwitchViewChairID(i);
						GetPeerGameView().SetPassFlag(wViewChairID, true);
						GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);
					}
				}

	

				//设置定时器
				SetTimer(IDI_MOST_CARD, 3000);

				return true;
			}

			//播放声音
			if ((IsLookonMode() == true) || (GetMeChairID() != pOutCard.wOutCardUser))
			{
				//PlayGameSound("OUT_CARD");
			}

			//玩家设置
			if (pOutCard.wCurrentUser != GlobalDef.INVALID_CHAIR)
			{
				m_bPass[pOutCard.wCurrentUser][0]=false;
				var wViewChairID:uint=SwitchViewChairID(pOutCard.wCurrentUser);
				GetPeerGameView().SetPassFlag(wViewChairID, false);
				GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);
			}

			//玩家设置
			if ((IsLookonMode() == false) && (pOutCard.wCurrentUser == GetMeChairID()))
			{


				GetPeerGameView().viewComponent.m_btOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btPassCard.visible=true;
				GetPeerGameView().viewComponent.m_btAutoOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btPassCard.enabled=true;
				GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=true;
				GetPeerGameView().viewComponent.m_btOutCard.enabled=((VerdictOutCard() == true) ? true : false);
			}

			//设置时间
			if (pOutCard.wCurrentUser != GlobalDef.INVALID_CHAIR)
			{
				var bCardCount:uint=m_bCardCount[pOutCard.wCurrentUser];
				SetGameTimer(pOutCard.wCurrentUser, IDI_OUT_CARD, (bCardCount < m_bTurnCardCount) ? TIME_MOST_OUT_CARD : TIME_OUT_CARD);
			}
						//播放声音
			PlayGameSound("OUT_CARD");
			return true;
		}

		//放弃出牌
		protected function OnSubPassCard(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			//效验数据
			if (wDataSize != CMD_S_PassCard.sizeof_CMD_S_PassCard)
			{
				return false;
			}
			var pPassCard:CMD_S_PassCard=CMD_S_PassCard.readData(pBuffer);

			//删除定时器
			KillGameTimer(IDI_OUT_CARD);

			//玩家设置
			if ((IsLookonMode() == true) || (pPassCard.wPassUser != GetMeChairID()))
			{
				m_bPass[pPassCard.wPassUser][0]=true;
				var wViewChairID:uint=SwitchViewChairID(pPassCard.wPassUser);
				GetPeerGameView().SetPassFlag(wViewChairID, true);
				GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);
			}

			//一轮判断
			if (pPassCard.bNewTurn == true)
			{
				m_bTurnCardCount=0;
				m_bTurnOutType=GameLogicDef.CT_INVALID;
				Memory.ZeroArray(m_bTurnCardData);
			}
			m_bPass[pPassCard.wCurrentUser][0]=false;
			//设置界面
			var wViewChairID:uint=SwitchViewChairID(pPassCard.wCurrentUser);
			GetPeerGameView().SetPassFlag(wViewChairID, false);
			GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);

			//玩家设置
			if ((IsLookonMode() == false) && (pPassCard.wCurrentUser == GetMeChairID()))
			{

				GetPeerGameView().viewComponent.m_btOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btPassCard.visible=true;
				GetPeerGameView().viewComponent.m_btAutoOutCard.visible=true;
				GetPeerGameView().viewComponent.m_btPassCard.enabled=((m_bTurnCardCount > 0) ? true : false);
				GetPeerGameView().viewComponent.m_btOutCard.enabled=((VerdictOutCard() == true) ? true : false);
				GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=((m_bTurnCardCount > 0) ? true : false);
			}

			//播放声音
			if ((IsLookonMode() == true) || (pPassCard.wPassUser != GetMeChairID()))
			{
				//PlayGameSound("OUT_CARD");
			}

			//设置时间
			if (m_bTurnCardCount != 0)
			{
				var bCardCount:uint=m_bCardCount[pPassCard.wCurrentUser];
				SetGameTimer(pPassCard.wCurrentUser, IDI_OUT_CARD, (bCardCount < m_bTurnCardCount) ? TIME_MOST_OUT_CARD : TIME_OUT_CARD);
			}
			else
			{
				SetGameTimer(pPassCard.wCurrentUser, IDI_OUT_CARD, TIME_OUT_CARD);

			}
			PlayGameSound("PASS_CARD");
			return true;
		}

		//游戏结束
		protected function OnSubGameEnd(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			//效验数据

			if (wDataSize != CMD_S_GameEnd.sizeof_CMD_S_GameEnd)
			{
				return false;
			}

			//消息处理
			var pGameEnd:CMD_S_GameEnd=CMD_S_GameEnd.readData(pBuffer);

			//删除定时器
			KillTimer(IDI_MOST_CARD);
			KillGameTimer(IDI_OUT_CARD);
			KillGameTimer(IDI_LAND_SCORE);
			KillTimer(IDI_LAST_TURN_CARD);

			//隐藏控件

			GetPeerGameView().viewComponent.m_btOutCard.visible=false;
			GetPeerGameView().viewComponent.m_btPassCard.visible=false;
			GetPeerGameView().viewComponent.m_btOneScore.visible=false;
			GetPeerGameView().viewComponent.m_btTwoScore.visible=false;
			GetPeerGameView().viewComponent.m_btThreeScore.visible=false;
			GetPeerGameView().viewComponent.m_btGiveUpScore.visible=false;
			GetPeerGameView().viewComponent.m_btAutoOutCard.visible=false;
			
			GetPeerGameView().viewComponent.m_sortCard.enabled = false;
			GetPeerGameView().viewComponent.m_bTrustCard.enabled = false;
			//删除头像
			if(GetPeerGameView().viewComponent.getChildByName("landerHead")!=null){
				GetPeerGameView().viewComponent.removeChild(GetPeerGameView().viewComponent.getChildByName("landerHead"));
			}
			
			
			//禁用控件
			GetPeerGameView().viewComponent.m_btOutCard.enabled=false;
			GetPeerGameView().viewComponent.m_btPassCard.enabled=false;

			SwitchToCurrentCard();

			//设置积分
			for (var i:int=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				var pUserData:tagUserData=GetUserInfo(i);									
				GetPeerGameView().m_ScoreView.SetGameScore(pUserData.szName,pGameEnd.lGameScore[i]);
				
				//设置历史积分
				lTurnScore[i] = pGameEnd.lGameScore[i];
				lCollectScore[i] += pGameEnd.lGameScore[i];				
			}
			updateCollectScoreView();
			//GetPeerGameView().m_ScoreView.SetMeChairID(GetMeChairID());
		

			//设置扑克
			var bCardPos:uint=0;
			for (var i:int=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				var wViewChairID:uint=SwitchViewChairID(i);
				if (wViewChairID == 0)
				{
					GetPeerGameView().m_LeaveCardControl[0].SetCardData(Memory.CloneArray(pGameEnd.bCardData, bCardPos), pGameEnd.bCardCount[i]);
				}
				else if (wViewChairID == 2)
				{
					GetPeerGameView().m_LeaveCardControl[1].SetCardData(Memory.CloneArray(pGameEnd.bCardData, bCardPos), pGameEnd.bCardCount[i]);
				}
				bCardPos+=pGameEnd.bCardCount[i];
				if (pGameEnd.bCardCount[i] != 0)
				{
					m_bPass[i][0]=false;
					GetPeerGameView().SetPassFlag(wViewChairID, false);
					GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);
				}
			}

			//显示扑克
			if (IsLookonMode() == true)
			{
				GetPeerGameView().m_HandCardControl.SetDisplayFlag(true);
			}

			//播放声音
			var wMeChairID:uint=GetMeChairID();
			var fMeScore:Number=pGameEnd.lGameScore[GetMeChairID()];
			if (fMeScore > 0)
			{
				GetPeerGameView().m_ScoreView.ShowWindow(true ,true);
				PlayGameSound("GAME_WIN");
			}
			else if (fMeScore < 0)
			{
				GetPeerGameView().m_ScoreView.ShowWindow(true ,false);
				PlayGameSound("GAME_LOST");
			}
			else
			{
				//PlayGameSound("GAME_END");

			} //设置界面
			if (IsLookonMode() == false)
			{
				
				GetPeerGameView().viewComponent.m_btStart.visible=true;							
				SetGameTimer(GetMeChairID(), IDI_EXIT_GAME, 30);
			}
			//GetPeerGameView().ShowLandTitle(false); 

			return true;
		}
		//用户托管
		protected function OnSubUserTrustee(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			return true;
		}
		/*=====================内核事件====================*/
		override protected function OnEventTimer(wChairID:uint, nElapse:uint, nTimerID:uint):Boolean
		{
			//变量界面
			var wViewChairID:uint=this.SwitchViewChairID(wChairID);
			GetPeerGameView().SetUserTimer(wViewChairID, nElapse);
			switch (nTimerID)
			{	
				
				case IDI_OUT_CARD:
				{
					//超时判断
					
					if (nElapse == 0 || (m_bStustee == true) && (nElapse < (TIME_OUT_CARD)))
					{
						if ((IsLookonMode() == false) && (wChairID == GetMeChairID()))
						{
							if(++m_wTimeOutCount>=CMD_Land.CT_OUTCART_TIMEOUT&&!m_bStustee){
								m_wTimeOutCount = 0;
								//设置为托管
								GetPeerGameView().viewComponent.m_bTrustCard.selected = !GetPeerGameView().viewComponent.m_bTrustCard.selected;
								OnStusteeControl(0,0);

							}	
			
							AutomatismOutCard();
							
						}
						return false;
					}

					//播放声音
					if (m_bHandCardCount < m_bTurnCardCount)
					{
						return true;
					}
					if ((nElapse <= 10) && (wChairID == GetMeChairID()) && (IsLookonMode() == false))
					{
						PlayGameSound("GAME_WARN");
					}


					return true;
				}
				case IDI_EXIT_GAME:
				{ //离开游戏
					if (nElapse == 0)
					{
						if ((IsLookonMode() == false) && (wChairID == GetMeChairID()))
						{
							if(_isMathch){
								OnStart(0,0);
							}
							else{
								OnExit(0, 0);
							}
						}
						return false;
					}
					if ((nElapse <= 10) && (wChairID == GetMeChairID()) && (IsLookonMode() == false))
					{
						PlayGameSound("GAME_WARN");
					}

					return true;
					return true;
				}
				case IDI_LAND_SCORE:
				{ //叫分
					if (nElapse == 0 || m_bStustee == true)
					{
						if ((IsLookonMode() == false) && (wChairID == GetMeChairID()))
						{
							OnLandScore(255, 255);
						}
						return false;
					}
					if ((nElapse <= 10) && (wChairID == GetMeChairID()) && (IsLookonMode() == false))
					{
						 PlayGameSound("GAME_WARN");
					}
					return true;
				}

			}
			return false;
		}

		override protected function OnGameSceneMessage(cbGameStation:uint, pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			switch (cbGameStation)
			{
				//空闲状态
				case CMD_Land.GS_WK_FREE:
				{
					//效验数据
					if (wDataSize != CMD_S_StatusFree.sizeof_CMD_S_StatusFree)
					{
						return false;
					}
					var pStatusFree:CMD_S_StatusFree=CMD_S_StatusFree.readData(pBuffer);

					//设置界面
					GetPeerGameView().SetBaseScore(pStatusFree.fBaseScore);

					//设置控件
					if (IsLookonMode() == false)
					{
						//这里设置开始按钮
						if(!_isMathch){
							GetPeerGameView().viewComponent.m_btStart.visible=true;
						}
						else{
							OnStart(0,0);
						}
					}

					//设置扑克
					if (IsLookonMode() == false)
					{
						GetPeerGameView().m_HandCardControl.SetDisplayFlag(true);
					}
					
					//设置历史积分
					Memory.CopyArray(lTurnScore,pStatusFree.lTurnScore,pStatusFree.lTurnScore.length);
					Memory.CopyArray(lCollectScore,pStatusFree.lCollectScore,pStatusFree.lCollectScore.length);
					updateCollectScoreView();
					
					//PlayGameSound("SOUND_BG",true);
					return true;
				}
				case CMD_Land.GS_WK_SCORE:
				{
					//效验数据
					if (wDataSize != CMD_S_StatusScore.sizeof_CMD_S_StatusScore)
					{
						return false;
					}
					var pStatusScore:CMD_S_StatusScore=CMD_S_StatusScore.readData(pBuffer);
					//设置变量
					m_bHandCardCount=17;
					for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
					{
						m_bCardCount[i]=17;
					}
					Memory.CopyArray(m_bHandCardData, pStatusScore.bCardData, m_bHandCardCount);
					//设置界面
					for (i=0; i < CMD_Land.GAME_PLAYER; i++)
					{
						var wViewChairID:uint=SwitchViewChairID(i);
						GetPeerGameView().SetCardCount(wViewChairID, m_bCardCount[i]);
						GetPeerGameView().SetLandScore(wViewChairID, pStatusScore.bScoreInfo[i]);
					}
					GetPeerGameView().SetBaseScore(pStatusScore.fBaseScore);

					//按钮控制
					if ((IsLookonMode() == false) && (pStatusScore.wCurrentUser == GetMeChairID()))
					{
						GetPeerGameView().viewComponent.m_btGiveUpScore.visible=true;
						GetPeerGameView().viewComponent.m_btOneScore.visible=(pStatusScore.bLandScore <= 0 ? true : false);
						GetPeerGameView().viewComponent.m_btTwoScore.visible=(pStatusScore.bLandScore <= 1 ? true : false);
						GetPeerGameView().viewComponent.m_btThreeScore.visible=(pStatusScore.bLandScore <= 2 ? true : false);
					}
					var bCardData:Array=GenEmptyCardData(20);
					UpdateLeaveCardControl(bCardData);
					GetPeerGameView().m_BackCardControl.SetCardData(bCardData, 3);
					GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
					if (IsLookonMode() == false)
					{
						GetPeerGameView().m_HandCardControl.SetDisplayFlag(true);
					}
					//设置时间
					SetGameTimer(pStatusScore.wCurrentUser, IDI_LAND_SCORE, 30);
					return true;
				}
				case CMD_Land.GS_WK_PLAYING:
				{

					//效验数据
					if (wDataSize != CMD_S_StatusPlay.sizeof_CMD_S_StatusPlay)
					{
						return false;
					}
					var pStatusPlay:CMD_S_StatusPlay=CMD_S_StatusPlay.readData(pBuffer);

					//设置变量
					m_bTurnCardCount=pStatusPlay.bTurnCardCount;
					m_bHandCardCount=pStatusPlay.bCardCount[GetMeChairID()];
					m_bTurnOutType=m_GameLogic.GetCardType(pStatusPlay.bTurnCardData, m_bTurnCardCount);
					Memory.CopyArray(m_bHandCardData, pStatusPlay.bCardData, m_bHandCardCount);
					Memory.CopyArray(m_bTurnCardData, pStatusPlay.bTurnCardData, pStatusPlay.bTurnCardCount);


					//设置界面
					for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
					{
						var wViewChairID:uint=SwitchViewChairID(i);
						m_bCardCount[i]=pStatusPlay.bCardCount[i];
						GetPeerGameView().SetCardCount(wViewChairID, pStatusPlay.bCardCount[i]);
					}
					//GetPeerGameView().SetBombTime(pStatusPlay.wBombTime);
					GetPeerGameView().SetBaseScore(pStatusPlay.fBaseScore);
					GetPeerGameView().m_BackCardControl.SetCardData(pStatusPlay.bBackCard, 3);
					GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
					GetPeerGameView().SetLandUser(SwitchViewChairID(pStatusPlay.wLandUser), pStatusPlay.bLandScore);
					var bCardData:Array=GenEmptyCardData(20);
					UpdateLeaveCardControl(bCardData);

					//玩家设置
					if ((IsLookonMode() == false) && (pStatusPlay.wCurrentUser == GetMeChairID()))
					{
						GetPeerGameView().viewComponent.m_btOutCard.enabled = (false);
						GetPeerGameView().viewComponent.m_btOutCard.visible = (true);
						GetPeerGameView().viewComponent.m_btPassCard.visible = (true);
						GetPeerGameView().viewComponent.m_btAutoOutCard.visible =(true);
						GetPeerGameView().viewComponent.m_btPassCard.enabled =((m_bTurnCardCount != 0) ? true : false);
						GetPeerGameView().viewComponent.m_btAutoOutCard.enabled = ((m_bTurnCardCount != 0) ? true : false);
					}

					//桌面设置
					if (m_bTurnCardCount != 0)
					{
						var wViewChairID:uint=SwitchViewChairID(pStatusPlay.wLastOutUser);
						GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(m_bTurnCardData, m_bTurnCardCount);
					}

					//设置定时器
					SetGameTimer(pStatusPlay.wCurrentUser, IDI_OUT_CARD, TIME_OUT_CARD);

					//设置扑克
					if (IsLookonMode() == false)
					{
						GetPeerGameView().m_HandCardControl.SetPositively(true);
						GetPeerGameView().m_HandCardControl.SetDisplayFlag(true);
					}

					return true;
				}

			}
			return false;
		}

		override protected function OnGameMessage(wSubCmdID:uint, pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			switch (wSubCmdID)
			{
				case CMD_Land.SUB_S_SEND_CARD: //发送扑克
				{
					return OnSubSendCard(pBuffer, wDataSize);

				}

				case CMD_Land.SUB_S_LAND_SCORE: //用户叫分
				{
					return OnSubLandScore(pBuffer, wDataSize);

				}

				case CMD_Land.SUB_S_GAME_START: //游戏开始
				{
					return OnSubGameStart(pBuffer, wDataSize);

				}

				case CMD_Land.SUB_S_OUT_CARD: //用户出牌
				{
					return OnSubOutCard(pBuffer, wDataSize);

				}

				case CMD_Land.SUB_S_PASS_CARD: //放弃出牌
				{
					return OnSubPassCard(pBuffer, wDataSize);

				}

				case CMD_Land.SUB_S_GAME_END: //游戏结束
				{
					return OnSubGameEnd(pBuffer, wDataSize);

				}
				case CMD_Land.SUB_C_TRUSTEE:	//用户托管
				{
					return OnSubUserTrustee(pBuffer, wDataSize);
				}
				case 5:
				{
					return true;
				}
			}


			return false;

		}

		override protected function OnTimer(nIDEvent:int):Boolean
		{
			if ((nIDEvent == IDI_MOST_CARD) && (m_wMostUser != GlobalDef.INVALID_CHAIR))
			{
				//变量定义
				var wCurrentUser:uint=m_wMostUser;
				var m_wMostUser:uint=GlobalDef.INVALID_CHAIR;

				//删除定时器
				KillTimer(IDI_MOST_CARD);

				//设置界面
				GetPeerGameView().SetPassFlag(GlobalDef.INVALID_CHAIR, false);
				for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
				{
					GetPeerGameView().m_UserCardControl[i].SetCardData(null, 0);
					m_bPass[i][0]=false;
				}

				//玩家设置
				if ((IsLookonMode() == false) && (wCurrentUser == GetMeChairID()))
				{

					GetPeerGameView().viewComponent.m_btOutCard.visible=(true);
					GetPeerGameView().viewComponent.m_btPassCard.visible=(true);
					GetPeerGameView().viewComponent.m_btPassCard.enabled=(false);
					GetPeerGameView().viewComponent.m_btAutoOutCard.visible=(true);
					GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=(false);
					GetPeerGameView().viewComponent.m_btOutCard.enabled=((VerdictOutCard() == true) ? true : false);
				}

				//设置时间
				SetGameTimer(wCurrentUser, IDI_OUT_CARD, TIME_OUT_CARD);

				return true;
			}
			if (nIDEvent == IDI_LAST_TURN_CARD) //上轮扑克
			{
				//还原界面
				SwitchToCurrentCard();

				return true;
			}

			return false;
		}

		/*================公用方法========================*/

		/*================私有方法=============================*/
		private function GenEmptyCardData(nCardCount:int):Array
		{
			var result:Array=new Array(nCardCount);
			Memory.ZeroArray(result, 0x43);
			return result;
		}

		private function UpdateLeaveCardControl(bCardData:Array):void
		{
			for (var n:int=0; n < CMD_Land.GAME_PLAYER; n++)
			{
				var wViewChairID:uint=SwitchViewChairID(n);
				if (wViewChairID == 0)
				{
					GetPeerGameView().m_LeaveCardControl[0].SetCardData(bCardData, m_bCardCount[n]);
					GetPeerGameView().viewComponent.leftLeaveCard.text="还剩:"+m_bCardCount[n]+"张";
				}
				else if (wViewChairID == 2)
				{
					GetPeerGameView().m_LeaveCardControl[1].SetCardData(bCardData, m_bCardCount[n]);
					GetPeerGameView().viewComponent.rightLeaveCard.text = "还剩:"+m_bCardCount[n]+"张";
				}
			}
		}

		//当前扑克
		protected function SwitchToCurrentCard():Boolean
		{
			//处理判断
			if (m_bLastTurn == false)
				return false;

			//环境设置
			m_bLastTurn=false;
			KillTimer(IDI_LAST_TURN_CARD);
			GetPeerGameView().SetLastTurnCard(false);

			//设置扑克
			for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				var wViewChairID:uint=SwitchViewChairID(i);
				if (m_bPass[i][0] == true)
				{
					GetPeerGameView().SetPassFlag(wViewChairID, true);
					GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(null, 0);
				}
				else
				{
					GetPeerGameView().SetPassFlag(wViewChairID, false);
					GetPeerGameView().m_UserCardControl[wViewChairID].SetCardData(m_cbOutCardData[i][0], m_cbOutCardCount[i][0]);
				}
			}

			return true;
		}

		//出牌提示
		protected function OnAutoOutCard(wParam:uint, lParam:uint):void
		{
			if(!AutoOutCard(0))OnPassCard(0,0);
		}

		//辅助函数
		//出牌判断
		protected function VerdictOutCard():Boolean
		{
			//状态判断
			if (GetPeerGameView().viewComponent.m_btOutCard.visible == false)
			{
				return false;
			}

			//获取扑克
			var bCardData:Array=new Array(20);
			var bShootCount:uint=GetPeerGameView().m_HandCardControl.GetShootCard(bCardData, bCardData.length);
			
			//出牌判断
			if (bShootCount > 0)
			{
				//分析类型
				var bCardType:uint=m_GameLogic.GetCardType(bCardData, bShootCount);

				//类型判断
				if (bCardType == GameLogicDef.CT_INVALID)
				{
					return false;
				}

				//跟牌判断
				if (m_bTurnCardCount == 0)
				{
					return true;
				}
				return m_GameLogic.CompareCard(bCardData, m_bTurnCardData, bShootCount, m_bTurnCardCount);
			}

			return false;
		}

		/**
		 * 响应处理事件  处理各种事件
		 * @param evt
		 */
		private function OnGameViewEevent(e:GameViewEvent):void
		{
			switch (e.m_nMsg)
			{
				case GameViewEvent.nGVM_START:
				{
					OnStart(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_OUT_CARD:
				{
					OnOutCard(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_PASS_CARD:
				{
					OnPassCard(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_LAND_SCORE:
				{
					OnLandScore(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_AUTO_OUTCARD:
				{
					OnAutoOutCard(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_LEFT_HIT_CARD:
				{
					OnLeftHitCard(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_RIGHT_HIT_CARD:
				{
					OnRightHitCard(e.m_nWParam, e.m_nLParam);
					return;
				}
				case GameViewEvent.nGVM_TRUSTEE_CONTROL:
				{
 					OnStusteeControl(e.m_nWParam, e.m_nLParam);
					return;


				}
				case GameViewEvent.nGVM_LAST_TURN_CARD:
				{
					//OnLastTurnCard(e.m_nWParam, e.m_nLParam);
					return;


				}
				case GameViewEvent.nGVM_SORT_CARD:
				{
					onSortCard();
				}
			}

		}
		
		protected function OnGameViewPropEvent(evt:gameEvent):void
		{
			var obj:Object = evt.data;
			
			SendProperty(obj["userId"]);
		}
		/*================电脑托管===========================*/
		//拖管控制
		protected function OnStusteeControl(wParam:uint, lParam:uint):uint
		{
			//设置状态
			if (m_bStustee == true)
			{
				m_bStustee=false;
				
			}
			else
			{
				m_bStustee=true;

			}	
		
			var cmd_userTrustee:CMD_C_UserTrustee = new CMD_C_UserTrustee;
			cmd_userTrustee.wUserChairID = GetMeChairID();
			cmd_userTrustee.bTrustee = m_bStustee;
			
			var data:ByteArray = cmd_userTrustee.toByteArray();
			
			SendGameData(CMD_Land.SUB_C_TRUSTEE,data,CMD_C_UserTrustee.sizeof_CMD_C_UserTrustee);


			return 0;
		}
		private function onSortCard():void{
			_sortType = !_sortType;
			m_GameLogic.SortCardList(m_bHandCardData, m_bHandCardCount,_sortType);
			GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData,m_bHandCardCount);
		}
		/*==============自动出牌分析=========================*/
		//自动出牌
		protected function AutomatismOutCard():Boolean
		{
			//先出牌者
			if (m_bTurnCardCount == 0)
			{
				//控制界面
				KillGameTimer(IDI_OUT_CARD);
				GetPeerGameView().viewComponent.m_btOutCard.visible=(false);
				GetPeerGameView().viewComponent.m_btOutCard.enabled=(false);
				GetPeerGameView().viewComponent.m_btPassCard.visible=(false);
				GetPeerGameView().viewComponent.m_btPassCard.enabled=(false);
				GetPeerGameView().viewComponent.m_btAutoOutCard.visible=(false);
				GetPeerGameView().viewComponent.m_btAutoOutCard.enabled=(false);

				//发送数据
				var OutCard:CMD_C_OutCard=new CMD_C_OutCard;
				OutCard.bCardCount=1;
				OutCard.bCardData[0]=m_bHandCardData[m_bHandCardCount - 1];
				var sendData:ByteArray=OutCard.toByteArray();
				SendGameData(CMD_Land.SUB_C_OUT_CARD, sendData, 2);

				//预先处理
				PlayGameSound("OUT_CARD");
				GetPeerGameView().m_UserCardControl[1].SetCardData(OutCard.bCardData, OutCard.bCardCount);

				//预先删除
				var bSourceCount:uint=m_bHandCardCount;
				m_bHandCardCount-=OutCard.bCardCount;
				m_GameLogic.RemoveCard(OutCard.bCardData, OutCard.bCardCount, m_bHandCardData, bSourceCount);
				GetPeerGameView().m_HandCardControl.SetCardData(m_bHandCardData, m_bHandCardCount);
			}
			else
			{
				if(AutoOutCard(0)){
					OnOutCard(1,1);
				}else{
					OnPassCard(0, 0);
				}
		
				

			}
			return true;
		}

		//出牌提示 出牌分析
		protected function AutoOutCard(WhichOnsKindCard:uint):Boolean
		{
			var i:int=0;
			var j:int=0;
			var n:int=0;
			var s:int=0;
			var bWhichKindSel:uint=0;
			var m_bTempGetCardData:Array=new Array(20); //手上扑克
			var m_bTempGetCardCount:uint=0; //扑克数目
			var m_bTempGetCardIndex:Array=new Array(20); //手上扑克
			
			GetPeerGameView().m_HandCardControl.ShootAllCard(false);
			
			m_bTempGetCardCount = m_GameLogic.searchOutCard(WhichOnsKindCard,m_bTurnOutType,m_bTurnCardData,m_bTurnCardCount,m_bHandCardData,m_bHandCardCount,m_bTempGetCardData,bWhichKindSel);
			
			var m_GetIndex:uint=0;
			if (m_bTempGetCardCount == 0)
			{
				if (WhichOnsKindCard != 1)
					//OnPassCard(0, 0);
					return false;
			}
			else
			{
				for (j=0; j < m_bTempGetCardCount; j++)
				{
					for (i=0; i < m_bHandCardCount; i++)
					{
						if (m_bHandCardData[i] == m_bTempGetCardData[j])
						{
							m_bTempGetCardIndex[m_GetIndex++]=i;
						}
					}
				}

			}
			if (m_GameLogic.CompareCard(m_bTempGetCardData, m_bTurnCardData, m_bTempGetCardCount, m_bTurnCardCount))
			{
				if (WhichOnsKindCard == 1 && bWhichKindSel == 1 || WhichOnsKindCard != 1)
				{
					GetPeerGameView().m_HandCardControl.SetShootCard(m_bTempGetCardIndex, m_GetIndex);
					GetPeerGameView().viewComponent.m_btOutCard.enabled=(true);
					return true;
				}
			}
			else
			{
				if (WhichOnsKindCard != 1)
					//OnPassCard(0, 0);
					return false;
			}
			return false;
		}

	}
}