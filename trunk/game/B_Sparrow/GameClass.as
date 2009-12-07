package B_Sparrow
{
	import Application.model.interfaces.IGameClass;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.utils.GameUtil;
	import Application.utils.Memory;
	
	import B_Land.common.MaterialLib;
	
	import B_Sparrow.common.CMD_C_OperateCard;
	import B_Sparrow.common.CMD_C_OutCard;
	import B_Sparrow.common.CMD_S_GameEnd;
	import B_Sparrow.common.CMD_S_GameStart;
	import B_Sparrow.common.CMD_S_ListenCard;
	import B_Sparrow.common.CMD_S_OperateResult;
	import B_Sparrow.common.CMD_S_OutCard;
	import B_Sparrow.common.CMD_S_SendCard;
	import B_Sparrow.common.CMD_S_SendHuCard;
	import B_Sparrow.common.CMD_Sparrow;
	import B_Sparrow.common.GameLogic;
	import B_Sparrow.common.GameLogicDef;
	import B_Sparrow.common.tagGangCardResult;
	import B_Sparrow.common.tagOperateInfo;
	import B_Sparrow.common.tagWeaveItem;
	
	import common.data.GlobalDef;
	import common.data.StringDef;
	import common.data.gameEvent;
	import common.game.GameBaseClass;
	import common.game.GameBaseView;
	import common.game.vo.TagServerAttribute;
	
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class GameClass extends GameBaseClass
	{
		//	游戏定时器
		protected static const IDI_EXIT_GAME:uint = 200;// 离开游戏定时器
		protected static const IDI_OPERATE_SPARROW:uint =202;//操作定时器
		
		//	游戏定时器
		protected static  const TIME_START_GAME:uint=30;//开始定时器
		protected static  const TIME_HEAR_STATUS:uint=1;//出牌定时器
		protected static  const TIME_OPERATE_SPARROW:uint=15;//操作定时器
		
		//
		protected static const HU_ZIMO:uint = 0x100000;//自摸
		protected static const HU_DIANPAO:uint = 0x100001;//点炮
		
		//	用户变量
		protected var m_wBankerUser:uint;//庄家用户
		protected var m_wCurrentUser:uint;//当前用户
		protected var m_wHuUser:int = -1;	//胡牌者
		
		//	状态变量
		protected var m_bHearStatus:Boolean;//听牌状态
		
		//	堆立变量
		protected var m_wHeapHand:uint;//堆立头部
		protected var m_wHeapTail:uint;//堆立尾部
		protected var m_cbHeapSparrowInfo:Array=new Array(2);//堆牌信息
		
		//麻将变量
		protected var m_cbLeftSparrowCount:int;//剩余数目
		protected var m_cbSparrowIndex:Array=new Array(GameLogicDef.MAX_INDEX);//手中麻将
		
		//组合麻将
		protected var m_cbWeaveCount:Array=new Array(CMD_Sparrow.GAME_PLAYER);//组合数目
		protected var m_WeaveItemArray:Array=new Array(CMD_Sparrow.GAME_PLAYER);//组合麻将
		
		//出牌信息
		protected var m_wOutSparrowUser:uint;//出牌用户
		protected var m_cbOutSparrowData:uint;//出牌麻将
		protected var m_cbDiscardCount:Array=new Array(CMD_Sparrow.GAME_PLAYER);//丢弃数目
		protected var m_cbDiscardSparrow:Array=new Array(CMD_Sparrow.GAME_PLAYER);//丢弃记录
		
		//游戏结束信息
		protected var Cmd_GameEnd:CMD_S_GameEnd;
		
		//控件变量
		protected var m_GameLogic:GameLogic;//游戏逻辑
		
		private var _isMathch:Boolean = false;
		public function GameClass()
		{
			super();
		}
		
		public function QueryIGameClass():IGameClass
		{
			return this  as  GameBaseClass  as  IGameClass;
		}
		
		protected function GetPeerGameView():GameView
		{
			if (m_GameClientView == null)
			{
				throw Error("GetPeerGameView GetPeerGameView() == null");
				return null;
			}
			return m_GameClientView  as  GameView;
		}
		
		override protected  function CreateGameView():GameBaseView
		{
			return new GameView(this);
		}
		
		override public function InitGameClass():Boolean
		{
			if(super.InitGameClass() == false)
			{
				return false;
			}
			
			for(var i:uint = 0; i < m_cbHeapSparrowInfo.length;i++)
			{
				m_cbHeapSparrowInfo[i] = new Array(2);
			}
			
			//tagWeaveItemArray 组合子项
			for(i=0; i < m_WeaveItemArray.length; i++)
			{
				m_WeaveItemArray[i]=new Array(4);
				for(var k:uint = 0; k < m_WeaveItemArray[i].length; k ++)
				{
					m_WeaveItemArray[i][k] = new tagWeaveItem;
				}
			}
			
			for(i = 0; i < m_cbDiscardSparrow.length; i++)
			{
				m_cbDiscardSparrow[i] = new Array(60);
			}
			
			m_GameLogic=new GameLogic();
			
			//游戏变量
			m_wBankerUser=GlobalDef.INVALID_CHAIR;
			m_wCurrentUser=GlobalDef.INVALID_CHAIR;

			//状态变量
			m_bHearStatus=false;

			//堆立变量
			m_wHeapHand=0;
			m_wHeapTail=0;
			Memory.ZeroTwoDimensionArray(m_cbHeapSparrowInfo);

			//出牌信息
			m_cbOutSparrowData=0;
			m_wOutSparrowUser=GlobalDef.INVALID_CHAIR;
			Memory.ZeroTwoDimensionArray(m_cbDiscardSparrow);
			Memory.ZeroArray(m_cbDiscardCount);

			//组合麻将
			Memory.ZeroArray(m_cbWeaveCount);
			Memory.EachTwoDimensionArray(m_WeaveItemArray,tagWeaveItem.ZeroMemory);

			//麻将变量
			m_cbLeftSparrowCount=0;
			Memory.ZeroArray(m_cbSparrowIndex);
			
			GetPeerGameView().addEventListener(GameViewEvent.strGameViewEvent, 
											   OnGameViewEevent);
			GetPeerGameView().addEventListener(gameEvent.USE_PROP,OnGameViewPropEvent);
			addSound();//添加声音			

			return true;
		}
		/**
		 *	添加声音 
		 * 
		 */
		private function addSound():void
		{
			AddGameSound("W_9",MaterialLib.getInstance().getClass("SOUND_W_9"));
			AddGameSound("W_8",MaterialLib.getInstance().getClass("SOUND_W_8"));
			AddGameSound("W_7",MaterialLib.getInstance().getClass("SOUND_W_7"));
			AddGameSound("W_6",MaterialLib.getInstance().getClass("SOUND_W_6"));
			AddGameSound("W_5",MaterialLib.getInstance().getClass("SOUND_W_5"));
			AddGameSound("W_4",MaterialLib.getInstance().getClass("SOUND_W_4"));
			AddGameSound("W_3",MaterialLib.getInstance().getClass("SOUND_W_3"));
			AddGameSound("W_2",MaterialLib.getInstance().getClass("SOUND_W_2"));
			AddGameSound("W_1",MaterialLib.getInstance().getClass("SOUND_W_1"));
			AddGameSound("T_9",MaterialLib.getInstance().getClass("SOUND_T_9"));
			AddGameSound("T_8",MaterialLib.getInstance().getClass("SOUND_T_8"));
			AddGameSound("T_7",MaterialLib.getInstance().getClass("SOUND_T_7"));
			AddGameSound("T_6",MaterialLib.getInstance().getClass("SOUND_T_6"));
			AddGameSound("T_5",MaterialLib.getInstance().getClass("SOUND_T_5"));
			AddGameSound("T_4",MaterialLib.getInstance().getClass("SOUND_T_4"));
			AddGameSound("T_3",MaterialLib.getInstance().getClass("SOUND_T_3"));
			AddGameSound("T_2",MaterialLib.getInstance().getClass("SOUND_T_2"));
			AddGameSound("T_1",MaterialLib.getInstance().getClass("SOUND_T_1"));
			AddGameSound("S_9",MaterialLib.getInstance().getClass("SOUND_S_9"));
			AddGameSound("S_8",MaterialLib.getInstance().getClass("SOUND_S_8"));
			AddGameSound("S_7",MaterialLib.getInstance().getClass("SOUND_S_7"));
			AddGameSound("S_6",MaterialLib.getInstance().getClass("SOUND_S_6"));
			AddGameSound("S_5",MaterialLib.getInstance().getClass("SOUND_S_5"));
			AddGameSound("S_4",MaterialLib.getInstance().getClass("SOUND_S_4"));
			AddGameSound("S_3",MaterialLib.getInstance().getClass("SOUND_S_3"));
			AddGameSound("S_2",MaterialLib.getInstance().getClass("SOUND_S_2"));
			AddGameSound("S_1",MaterialLib.getInstance().getClass("SOUND_S_1"));
			
			AddGameSound("F_7",MaterialLib.getInstance().getClass("SOUND_F_7"));
			AddGameSound("F_6",MaterialLib.getInstance().getClass("SOUND_F_6"));
			AddGameSound("F_5",MaterialLib.getInstance().getClass("SOUND_F_5"));
			AddGameSound("F_4",MaterialLib.getInstance().getClass("SOUND_F_4"));
			AddGameSound("F_3",MaterialLib.getInstance().getClass("SOUND_F_3"));
			AddGameSound("F_2",MaterialLib.getInstance().getClass("SOUND_F_2"));
			AddGameSound("F_1",MaterialLib.getInstance().getClass("SOUND_F_1"));
			
			AddGameSound("A_CHI",MaterialLib.getInstance().getClass("SOUND_CHI"));
			AddGameSound("OUT_SPARROW",MaterialLib.getInstance().getClass("SOUND_OUT_CARD"));
			AddGameSound("A_PENG",MaterialLib.getInstance().getClass("SOUND_PENG"));
			AddGameSound("A_GANG",MaterialLib.getInstance().getClass("SOUND_GANG"));
			AddGameSound("A_ZIMO",MaterialLib.getInstance().getClass("SOUND_ZIMO"));
			AddGameSound("A_DIANPAO",MaterialLib.getInstance().getClass("SOUND_DIANPAO"));
			
			AddGameSound("W_9_W",MaterialLib.getInstance().getClass("SOUND_W_9_W"));
			AddGameSound("W_8_W",MaterialLib.getInstance().getClass("SOUND_W_8_W"));
			AddGameSound("W_7_W",MaterialLib.getInstance().getClass("SOUND_W_7_W"));
			AddGameSound("W_6_W",MaterialLib.getInstance().getClass("SOUND_W_6_W"));
			AddGameSound("W_5_W",MaterialLib.getInstance().getClass("SOUND_W_5_W"));
			AddGameSound("W_4_W",MaterialLib.getInstance().getClass("SOUND_W_4_W"));
			AddGameSound("W_3_W",MaterialLib.getInstance().getClass("SOUND_W_3_W"));
			AddGameSound("W_2_W",MaterialLib.getInstance().getClass("SOUND_W_2_W"));
			AddGameSound("W_1_W",MaterialLib.getInstance().getClass("SOUND_W_1_W"));
			AddGameSound("T_9_W",MaterialLib.getInstance().getClass("SOUND_T_9_W"));
			AddGameSound("T_8_W",MaterialLib.getInstance().getClass("SOUND_T_8_W"));
			AddGameSound("T_7_W",MaterialLib.getInstance().getClass("SOUND_T_7_W"));
			AddGameSound("T_6_W",MaterialLib.getInstance().getClass("SOUND_T_6_W"));
			AddGameSound("T_5_W",MaterialLib.getInstance().getClass("SOUND_T_5_W"));
			AddGameSound("T_4_W",MaterialLib.getInstance().getClass("SOUND_T_4_W"));
			AddGameSound("T_3_W",MaterialLib.getInstance().getClass("SOUND_T_3_W"));
			AddGameSound("T_2_W",MaterialLib.getInstance().getClass("SOUND_T_2_W"));
			AddGameSound("T_1_W",MaterialLib.getInstance().getClass("SOUND_T_1_W"));
			AddGameSound("S_9_W",MaterialLib.getInstance().getClass("SOUND_S_9_W"));
			AddGameSound("S_8_W",MaterialLib.getInstance().getClass("SOUND_S_8_W"));
			AddGameSound("S_7_W",MaterialLib.getInstance().getClass("SOUND_S_7_W"));
			AddGameSound("S_6_W",MaterialLib.getInstance().getClass("SOUND_S_6_W"));
			AddGameSound("S_5_W",MaterialLib.getInstance().getClass("SOUND_S_5_W"));
			AddGameSound("S_4_W",MaterialLib.getInstance().getClass("SOUND_S_4_W"));
			AddGameSound("S_3_W",MaterialLib.getInstance().getClass("SOUND_S_3_W"));
			AddGameSound("S_2_W",MaterialLib.getInstance().getClass("SOUND_S_2_W"));
			AddGameSound("S_1_W",MaterialLib.getInstance().getClass("SOUND_S_1_W"));
			
			AddGameSound("F_7_W",MaterialLib.getInstance().getClass("SOUND_F_7_W"));
			AddGameSound("F_6_W",MaterialLib.getInstance().getClass("SOUND_F_6_W"));
			AddGameSound("F_5_W",MaterialLib.getInstance().getClass("SOUND_F_5_W"));
			AddGameSound("F_4_W",MaterialLib.getInstance().getClass("SOUND_F_4_W"));
			AddGameSound("F_3_W",MaterialLib.getInstance().getClass("SOUND_F_3_W"));
			AddGameSound("F_2_W",MaterialLib.getInstance().getClass("SOUND_F_2_W"));
			AddGameSound("F_1_W",MaterialLib.getInstance().getClass("SOUND_F_1_W"));
			
			AddGameSound("A_CHI_W",MaterialLib.getInstance().getClass("SOUND_CHI_W"));
			AddGameSound("OUT_SPARROW_W",MaterialLib.getInstance().getClass("SOUND_OUT_CARD_W"));
			AddGameSound("A_PENG_W",MaterialLib.getInstance().getClass("SOUND_PENG_W"));
			AddGameSound("A_GANG_W",MaterialLib.getInstance().getClass("SOUND_GANG_W"));
			AddGameSound("A_ZIMO_W",MaterialLib.getInstance().getClass("SOUND_ZIMO_W"));
			AddGameSound("A_DIANPAO_W",MaterialLib.getInstance().getClass("SOUND_DIANPAO_W"));
			
			AddGameSound("A_PAO_LOST",MaterialLib.getInstance().getClass("SOUND_PAO_LOST"));
			AddGameSound("A_PAO_WIN",MaterialLib.getInstance().getClass("SOUND_PAO_WIN"));
			AddGameSound("A_ZIMO_WIN",MaterialLib.getInstance().getClass("SOUND_ZIMO_WIN"));
			AddGameSound("A_ZIMO_LOST",MaterialLib.getInstance().getClass("SOUND_ZIMO_LOST"));
			AddGameSound("A_LIUJU",MaterialLib.getInstance().getClass("SOUND_LIUJU"));
			
			AddGameSound("TIME",MaterialLib.getInstance().getClass("SOUND_TIME"));
			
		}
		protected function PlaySparrowSound(cbSparrowData:uint,isMan:Boolean = true):void
		{
			//变量定义
			
			var szKind:Array=new Array("W","T","S","F");
		
			//构造名字
			var cbValue:uint=(cbSparrowData&GameLogicDef.MASK_VALUE);
			var cbColor:uint=(cbSparrowData&GameLogicDef.MASK_COLOR)>>4;
		
			var szSoundName:String = szKind[cbColor] + "_" + cbValue;
			
			if(!isMan) szSoundName += "_W";
			
			//播放声音
			PlayGameSound(szSoundName);
		
			return;
		}
		//播放声音
		protected function PlayActionSound( cbAction:uint,isMan:Boolean = true):void
		{
			var woman:String = "";
			if(!isMan)var woman:String = "_W";
			
			switch (cbAction)
			{
				case GameLogicDef.WIK_NULL:		//取消
					{
						PlayGameSound("OUT_SPARROW" + woman);
						break;
					}
				case GameLogicDef.WIK_LEFT:
				case GameLogicDef.WIK_CENTER:
				case GameLogicDef.WIK_RIGHT:		//上牌
					{
						PlayGameSound("A_CHI" + woman);
						GetPeerGameView().showChiMonition();
						break;
					}
				case GameLogicDef.WIK_PENG:		//碰牌
					{
						PlayGameSound("A_PENG" + woman);
						GetPeerGameView().showPengMonition();
						break;
					}
				case GameLogicDef.WIK_FILL:		//补牌
					{
						PlayGameSound("A_FILL" + woman);
						break;
					}
				case GameLogicDef.WIK_GANG:		//杠牌
					{
						PlayGameSound("A_GANG" + woman);
						break;
					}
				case GameLogicDef.WIK_CHI_HU:	//吃胡
					{
						PlayGameSound("A_CHI_HU" + woman);
						break;
					}
				case HU_ZIMO:					//自摸
				{
					PlayGameSound("A_ZIMO" + woman);
					break;
				}
				case HU_DIANPAO:					//点炮
				{
					PlayGameSound("A_DIANPAO" + woman);
					break;
				}
			}
		
			return;
		}
		/**
		 * 响应游戏处理事件
		 * @param event
		 */
		protected function OnGameViewEevent(event:GameViewEvent):void
		{
			//trace("GameViewEvent------------------------------------>>::"+event.m_nMsg);
			switch (event.m_nMsg)
			{
				case GameViewEvent.nGVM_START:
				{
					OnStart(event.m_nWParam, event.m_nLParam);
					break;
				}
				case GameViewEvent.nGVM_OUT_SPARROW:
				{
					onOutSparrow(event.m_nWParam, event.m_nLParam);
					break;
				}
				case GameViewEvent.nGVM_SPARROW_OPERATE:
				{
					onSparrowOperate(event.m_nWParam,event.m_nLParam);
					return;	
				}
			}
		}
		protected function OnGameViewPropEvent(evt:gameEvent):void
		{
			var obj:Object = evt.data;
			
			SendProperty(obj["userId"]);
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
			//设置历史积分
			
			//设置界面
			if(_isMathch){
				GetPeerGameView().viewComponent.userExpBar.visible = true;
				GetPeerGameView().viewComponent.ownerExpBar.visible = true;
			}else{
				GetPeerGameView().viewComponent.userExpBar.visible = false;
				GetPeerGameView().viewComponent.ownerExpBar.visible = false;
			}
			if(GetMeChairID()==pUserData.wChairID){
				//设置准备按钮可见
				//GetPeerGameView().viewComponent.m_btStart.visible=true;
				SetGameTimer(GetMeChairID(), IDI_EXIT_GAME, TIME_START_GAME);	
				//如果是比赛场直接开始
				//if(_isMathch) OnStart(0,0);
			}
			var viewId:int = this.SwitchViewChairID(wChairID)
			switch(viewId){
				case 0:
					GetPeerGameView().viewComponent.userExpBar.percent = GameUtil.socreToexp(pUserData.lScore);
					GetPeerGameView().viewComponent.userExpBar.toolTip = GameUtil.replaceText(StringDef.SCORE,{num:pUserData.lScore});
					break;
				case 1:
					GetPeerGameView().viewComponent.ownerExpBar.percent = GameUtil.socreToexp(pUserData.lScore);
					GetPeerGameView().viewComponent.ownerExpBar.toolTip = GameUtil.replaceText(StringDef.SCORE,{num:pUserData.lScore});
					break
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
			//设置历史积分
			
			//
			var wViewChairID:uint=this.SwitchViewChairID(wChairID);
			 switch(wViewChairID){
				case 0:
					GetPeerGameView().viewComponent.userExpBar.visible = false;
					break;
			}
		}
		/* =============================================================================== */
		override protected function OnStart(wParam:uint, lParam:uint):uint
		{
			//初始化数据
			
			//游戏变量
			m_wBankerUser=GlobalDef.INVALID_CHAIR;
			m_wCurrentUser=GlobalDef.INVALID_CHAIR;

			//状态变量
			m_bHearStatus=false;

			//堆立变量
			m_wHeapHand=0;
			m_wHeapTail=0;
			Memory.ZeroTwoDimensionArray(m_cbHeapSparrowInfo);

			//出牌信息
			m_cbOutSparrowData=0;
			m_wOutSparrowUser=GlobalDef.INVALID_CHAIR;
			Memory.ZeroTwoDimensionArray(m_cbDiscardSparrow);
			Memory.ZeroArray(m_cbDiscardCount);

			//组合麻将
			Memory.ZeroArray(m_cbWeaveCount);
			Memory.EachTwoDimensionArray(m_WeaveItemArray,tagWeaveItem.ZeroMemory);

			//麻将变量
			m_cbLeftSparrowCount=0;
			Memory.ZeroArray(m_cbSparrowIndex);
			//////////////////////////////////////////////////////////////
			//界面设置
			GetPeerGameView().m_ScoreView.showWindow(false);
			GetPeerGameView().viewComponent.start_Btn.visible = false;
			GetPeerGameView().showControlMc(false);
			////////////////////////////////////////////////////////////////
			//环境设置
			KillGameTimer(IDI_EXIT_GAME);
		
			//设置界面
			/* GetPeerGameView().SetHuangZhuang(false);
			GetPeerGameView().SetStatusFlag(false,false);
			GetPeerGameView().SetBankerUser(INVALID_CHAIR);
			GetPeerGameView().SetUserAction(INVALID_CHAIR,0);
			GetPeerGameView().SetOutSparrowInfo(INVALID_CHAIR,0); */
		
			//麻将设置
			for(var i:int = 0 ; i<CMD_Sparrow.GAME_PLAYER-1; i++){
				GetPeerGameView().m_UserSparrow[i].SetSparrowData(0,false);
			}
			GetPeerGameView().m_HandCardControl.SetSparrowData(null,0,0);
		
			//麻将设置
			for (i=0;i<CMD_Sparrow.GAME_PLAYER;i++)
			{
				GetPeerGameView().m_TableSparrow[i].SetSparrowData(null,0);
				GetPeerGameView().m_DiscardSparrow[i].SetSparrowData(null,0);
				GetPeerGameView().m_WeaveSparrow[i][0].SetSparrowData(null,0);
				GetPeerGameView().m_WeaveSparrow[i][1].SetSparrowData(null,0);
				GetPeerGameView().m_WeaveSparrow[i][2].SetSparrowData(null,0);
				GetPeerGameView().m_WeaveSparrow[i][3].SetSparrowData(null,0);
			}
		
			//堆立麻将
			/* for (i=0;i<CMD_Sparrow.GAME_PLAYER;i++)
			{
				m_cbHeapSparrowInfo[i][0]=0;
				var v:uint = 26;
				if(i==m_wBankerUser)
					v = 28;
				else if((i+2)%4==m_wBankerUser)
					v = 28;
				m_cbHeapSparrowInfo[i][1]=HEAP_FULL_COUNT-v;
				GetPeerGameView().m_HeapSparrow[SwitchViewChairID(i)].SetSparrowData(m_cbHeapSparrowInfo[i][0],m_cbHeapSparrowInfo[i][1],HEAP_FULL_COUNT);
			} */
			////////////////////////////////////////////////////////////////
			GetPeerGameView().UpdateGameView();
			//发送消息
			SendUserReady(null,0);
			return 0;
		}
		//出牌操作
		protected function onOutSparrow(wParam:uint, lParam:uint):uint
		{
			//出牌判断
			if ((IsLookonMode()==true)||(m_wCurrentUser!=GetMeChairID())) return 0;
			
			//听牌判断
			if ((m_bHearStatus==true)&&(GetPeerGameView().m_HandCardControl.GetCurrentSparrow()!=wParam)) return 0;
			
			if(lParam == 0x40) m_bHearStatus = true;
			
			//设置变量
			m_wCurrentUser=GlobalDef.INVALID_CHAIR;
			var cbOutSparrowData:uint=wParam;
			//m_GameLogic.RemoveSparrow2(m_cbSparrowIndex,cbOutSparrowData);
			
			//设置麻将
			//var cbSparrowData:Array = new Array(GameLogicDef.MAX_COUNT);
			//var cbSparrowCount:uint=m_GameLogic.SwitchToSparrowData2(m_cbSparrowIndex,cbSparrowData);
			//GetPeerGameView().m_HandCardControl.SetSparrowData(cbSparrowData,cbSparrowCount,0);
			
			//设置界面
			KillGameTimer(IDI_OPERATE_SPARROW);
			GetPeerGameView().UpdateGameView();
			GetPeerGameView().SetStatusFlag(false,false);
			//GetPeerGameView().SetUserAction(GlobalDef.INVALID_CHAIR,0);
			//GetPeerGameView().SetOutSparrowInfo(2,cbOutSparrowData);
			GetPeerGameView().showControlMc(false);
			
			//发送数据
			var OutSparrow:CMD_C_OutCard = new CMD_C_OutCard;
			OutSparrow.cbCardData=cbOutSparrowData;
			OutSparrow.bIsTing = m_bHearStatus;
			var sendData:ByteArray =  OutSparrow.toByteArray();
			SendGameData(CMD_Sparrow.SUB_C_OUT_CARD,sendData,CMD_C_OutCard.sizeof_CMD_C_OutCard);
			
			return 0;
		}
		//麻将操作
		protected function onSparrowOperate(wParam:uint, lParam:uint):uint
		{
			//变量定义
			var cbOperateCode:uint=Memory.LOBYTE(wParam);
			var cbOperateSparrow:uint=Memory.LOBYTE(lParam);
			
			//状态判断
			if ((m_wCurrentUser==GetMeChairID())&&(cbOperateCode==GameLogicDef.WIK_NULL))
			{
				//GetPeerGameView().m_ControlMC.ShowWindow(false);
				/* var cardOperate:CMD_C_OperateCard = new CMD_C_OperateCard;
				cardOperate.cbOperateCode = GameLogicDef.WIK_NULL;
				var sendData:ByteArray =  cardOperate.toByteArray();
				SendGameData(CMD_Sparrow.SUB_C_OPERATE_SPARROW,sendData,CMD_C_OperateCard.sizeof_CMD_C_OperateCard);
				return 0; */
			};
			if(cbOperateCode&GameLogicDef.WIK_LISTEN){
				onOutSparrow(cbOperateSparrow,0x40);
				return 0;
			}
			//发送命令
			var OperateSparrow:CMD_C_OperateCard = new CMD_C_OperateCard;
			OperateSparrow.cbOperateCode=cbOperateCode;
			OperateSparrow.cbOperateCard=cbOperateSparrow;
			var sendData:ByteArray =  OperateSparrow.toByteArray();
			SendGameData(CMD_Sparrow.SUB_C_OPERATE_SPARROW,sendData,CMD_C_OperateCard.sizeof_CMD_C_OperateCard);
			
			//环境设置
			var cbTSparrowData:Array = new Array(GameLogicDef.MAX_COUNT);
			var cbTSparrowCount:uint=m_GameLogic.SwitchToSparrowData2(m_cbSparrowIndex,cbTSparrowData);
			GetPeerGameView().m_HandCardControl.SetSparrowData(cbTSparrowData,cbTSparrowCount,0);
			GetPeerGameView().SetStatusFlag(false,true);
			GetPeerGameView().showControlMc(false);
			
			if(cbOperateCode == GameLogicDef.WIK_NULL){
				SetGameTimer(GetMeChairID(),IDI_OPERATE_SPARROW,TIME_OPERATE_SPARROW);
				return 0;
			}
			
			KillGameTimer(IDI_OPERATE_SPARROW);
			
			return 0;
				
		}
		
		// 重置状态
		override public function DestroyGameClass():void
		{
			if (GetPeerGameView()){
				GetPeerGameView().viewComponent.userExpBar.visible =false;
				GetPeerGameView().viewComponent.ownerExpBar.visible = false;
				GetPeerGameView().removeEventListener(GameViewEvent.strGameViewEvent, OnGameViewEevent);
				GetPeerGameView().removeEventListener(gameEvent.USE_PROP,OnGameViewPropEvent);
				if(GetPeerGameView().hasEventListener("B_Sparrow_Over"))
					GetPeerGameView().removeEventListener("B_Sparrow_Over",gameEndHandle);
			}				
			m_GameLogic=null;
			
			_isMathch = false;
			
			super.DestroyGameClass();
		}
		
		//网络消息
		override protected function OnGameMessage(wSubCmdID:uint, pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			switch(wSubCmdID)
			{
				case CMD_Sparrow.SUB_S_GAME_START:		//游戏开始
				{
					return OnSubGameStart(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_OUT_CARD:		//出牌命令
				{
					return OnSubOutSparrow(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_OPERATE_RESULT:	//操作命令
				{
					return OnSubOperateResult(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_SEND_CARD:		//发送扑克
				{
					return OnSubSendSparrow(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_LISTEN_CARD:		//听牌命令
				{
					return OnSubListenSparrow(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_SEND_DANCE:		//跳舞命令
				{
					return true;
				}
				case CMD_Sparrow.SUB_S_SEND_HU:			//胡牌命令
				{
					return OnSubHu(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_GAME_END:		//游戏结束
				{
					return OnSubGameEnd(pBuffer,wDataSize);
				}
				case CMD_Sparrow.SUB_S_FALSE_GANG:		//假杠命令
				{
					return true;
				}
				case CMD_Sparrow.SUB_S_OPERATE:			//预操作命令
				{
					return true;
				}
				case CMD_Sparrow.SUB_S_OUT_CARD_QIANG:
				{
					return true;
				}
			}
			return true;
		}
				/**
		 * 
		 * 重载配置完成
		 */
		override protected function configComplete():void{
			//判断是否是比赛房间是否显示积分		
			if((GetServerAttribute() as TagServerAttribute).wGameGenre==GlobalDef.GAME_GENRE_MATCH){				
				
				_isMathch = true;
			}else{
				_isMathch = false;
			}

		}
		
		
		override protected function OnGameSceneMessage(cbGameStation:uint, pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			switch (cbGameStation)
			{
				case CMD_Sparrow.GS_MJ_FREE:		//空闲状态
				{
					//trace("空闲======================》》");
					
					//效验数据
					//if (wDataSize!=CMD_S_StatusFree.sizeof_CMD_S_StatusFree) return false;
					//var pStatusFree:CMD_S_StatusFree=CMD_S_StatusFree.readData(pBuffer);
					
					GetPeerGameView().m_HandCardControl.SetDisplayItem(true);
					break;
				}
				case CMD_Sparrow.GS_MJ_PLAY:		//游戏状态
				{
					//trace("游戏======================》》");
					break;
				}
			}
			return true;
		}
		
		//内核事件---------------------------->>:://时间消息
		override protected function OnEventTimer(wChairID:uint,nElapse:uint,nTimerID:uint):Boolean
		{
			//变量界面
			var wViewChairID:uint = this.SwitchViewChairID(wChairID);
			GetPeerGameView().SetUserTimer(wViewChairID,nElapse);
			
			switch(nTimerID)
			{
				case IDI_EXIT_GAME:			//离开游戏
				{
					if(nElapse == 0)
					{
						OnExit(0,0);
						return false;
					}
					if (nElapse <= 5)
					{
						//PlayGameSound("GAME_WARN");	
					}
					return true;
				}
				case IDI_OPERATE_SPARROW:	//操作定时器
				{
					//超时判断
					if(nElapse == 0 && IsLookonMode() == false)
					{
						//获取位置
						var wMeChairID:uint=GetMeChairID();
						
						//动作处理
						if (wChairID == wMeChairID)
						{
							if(m_wCurrentUser == wMeChairID)
							{
								var cbSparrowData:uint=GetPeerGameView().m_HandCardControl.GetCurrentSparrow();
								onOutSparrow(cbSparrowData,cbSparrowData);
								GetPeerGameView().m_HandCardControl.setOutSparrowStatus();
							}
							else
							{
								onSparrowOperate(GameLogicDef.WIK_NULL,0);								
							}
							return false;
						}
						
						//播放声音
						if(nElapse <= 3 && wChairID == GetMeChairID() && IsLookonMode() == false)
						{
							//PlayGameSound("GAME_WARN");
						}
						
					}
					return true;
				}
			};
			return false;
		}
		
		
		/*-------------------------------------游戏事件处理--------------------------------------*/
		/**
		 * 游戏开始，判断庄家，画各个牌控区界面，并进行逻辑判断看是否可以听、胡！
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnSubGameStart(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
 			//效验数据
			Memory.ASSERT(wDataSize == CMD_S_GameStart.sizeof_CMD_S_GameStart);
			if(wDataSize != CMD_S_GameStart.sizeof_CMD_S_GameStart) return false;
			
			//变量定义
			var pGameStart:CMD_S_GameStart = CMD_S_GameStart.readData(pBuffer);
			if(GlobalDef.DEBUG) trace("in GameClass onSubGameStart: pGameStart.cbCardData = " + pGameStart.cbCardData);
/* 			var _data:String = "";
			for(var i:uint = 0; i < pGameStart.cbCardData.length; i++)
			{
				_data += pGameStart.cbCardData[i]+",";
			} */
			/////////////////////////////////////////////////////////
			//假数据
			//pGameStart.cbCardData = new Array(0x01,0x01,0x01,0x02,0x03,0x04,0x05,0x06,0x11,0x11,0x11,0x11);
			//pGameStart.wBankerUser = GetMeChairID();
			//pGameStart.wCurrentUser = GetMeChairID(); 
			/////////////////////////////////////////////////////////
			//设置状态
			SetGameStatus (CMD_Sparrow.GS_MJ_PLAY);
			
			//设置变量
			m_bHearStatus = false;
			
			m_wBankerUser =	pGameStart.wBankerUser;
			
			m_wCurrentUser = pGameStart.wCurrentUser;
			m_cbLeftSparrowCount=GameLogicDef.MAX_REPERTORY-CMD_Sparrow.GAME_PLAYER*(GameLogicDef.MAX_COUNT-1)-1;
			
			//出牌信息
			m_cbOutSparrowData = 0;
			m_wOutSparrowUser =GlobalDef.INVALID_CHAIR;
			Memory.ZeroTwoDimensionArray(m_cbDiscardSparrow);
			Memory.ZeroArray(m_cbDiscardCount);
			
			//组合麻将
			Memory.ZeroArray(m_cbWeaveCount);
			Memory.EachTwoDimensionArray(m_WeaveItemArray,tagWeaveItem.ZeroMemory);
			
			//设置麻将
			var cbSparrowCount:uint=(GetMeChairID()==m_wBankerUser)?GameLogicDef.MAX_COUNT:(GameLogicDef.MAX_COUNT-1);
			m_GameLogic.SwitchToSparrowIndex3(pGameStart.cbCardData,cbSparrowCount,m_cbSparrowIndex);
			
			//设置界面
			var bPlayerMode:Boolean = (IsLookonMode()==false);
			GetPeerGameView().m_HandCardControl.SetPositively(bPlayerMode);
			
			//设置庄家可能牵扯庄家标志
			GetPeerGameView().SetBankerUser(SwitchViewChairID(m_wBankerUser));
			
			/*---------------------------------------------麻将设置----------------------------------------------*/
			
			//用户麻将
			for(var i:uint = 0; i< CMD_Sparrow.GAME_PLAYER; i++)
			{
				//变量定义
				
				//根据真实座椅号，将当前玩家的麻将用SprrowControl 的实例m_HandCardControl初始化，以可见显示在屏幕下方。
				if(i != GetMeChairID())
				{
					//判断是否庄家，初始化麻将
					(GetPeerGameView().m_UserSparrow[0] as UserSparrow).SetSparrowData(GameLogicDef.MAX_COUNT-1,(i==m_wBankerUser));
				}
				else
				{
					//判断是否庄家，初始化麻将
					var cbBankerSparrow:uint=(i==m_wBankerUser)?pGameStart.cbCardData[GameLogicDef.MAX_COUNT-1]:0;
					GetPeerGameView().m_HandCardControl.SetSparrowData(pGameStart.cbCardData,GameLogicDef.MAX_COUNT-1,cbBankerSparrow);
				}
			}
			
			//动作处理
			/* if ((bPlayerMode==true)&&(pGameStart.cbUserAction!=GameLogicDef.WIK_NULL))
			{
				ShowOperateControl(pGameStart.cbUserAction,0);
				SetGameTimer(GetMeChairID(),IDI_OPERATE_SPARROW,TIME_OPERATE_SPARROW);
			} */
			if(pGameStart.wBankerUser == GetMeChairID()){
				var operateCode:uint = GameLogicDef.WIK_NULL;
				var arrListenResult:Array = new Array;
				var arrOperateList:Array = new Array;
				
				var gangItem:tagGangCardResult = new tagGangCardResult;
				m_GameLogic.AnalyseGangSparrow(m_cbSparrowIndex,m_WeaveItemArray[GetMeChairID()],m_cbWeaveCount[GetMeChairID()],gangItem);
				if(gangItem.cbCardCount>0){
					operateCode |= GameLogicDef.WIK_GANG;
					
				}
				operateCode |= m_GameLogic.EstimateChiHu(m_cbSparrowIndex);
				operateCode |= m_GameLogic.EstimateListenSparrow(m_cbSparrowIndex,0,arrListenResult);
				
				if(operateCode&GameLogicDef.WIK_CHI_HU){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_CHI_HU;
					arrOperateList.push(operateInfo);
				}
				if(operateCode&GameLogicDef.WIK_GANG){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_GANG;
					operateInfo.cbOperateSparrow = gangItem.cbCardData[0];
					arrOperateList.push(operateInfo);
					
				}
				if(operateCode&GameLogicDef.WIK_LISTEN){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_LISTEN;
					operateInfo.cbOperateSparrow = arrListenResult;
					arrOperateList.push(operateInfo);
				}
				
				if((operateCode&(GameLogicDef.WIK_GANG|GameLogicDef.WIK_CHI_HU))!=0){
					GetPeerGameView().controlMc(operateCode,arrOperateList,m_bHearStatus);
				}
			}
			
			//出牌提示
			if((bPlayerMode==true)&&(m_wCurrentUser!=GlobalDef.INVALID_CHAIR))
			{
				var wMeChairID:uint=GetMeChairID();
				if (m_wCurrentUser==wMeChairID) GetPeerGameView().SetStatusFlag(true,false);
			}
			
			//设置倒计时
			SetGameTimer(pGameStart.wBankerUser,IDI_OPERATE_SPARROW,TIME_OPERATE_SPARROW);
			
			return true;
		}
			
		/**
		 * 用户出牌，各牌区控件显示，逻辑判断是否可以吃碰杠听胡
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnSubOutSparrow(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			//效验消息
			Memory.ASSERT(wDataSize==CMD_S_OutCard.sizeof_CMD_S_OutCard);
			if (wDataSize!=CMD_S_OutCard.sizeof_CMD_S_OutCard) return false;
			
			//消息处理
			var pOutSparrow:CMD_S_OutCard=CMD_S_OutCard.readData(pBuffer);
		
			//变量定义
			var wMeChairID:uint=GetMeChairID();
			var wOutViewChairID:uint=SwitchViewChairID(pOutSparrow.wOutCardUser);
			var operateCode:uint = GameLogicDef.WIK_NULL;
			
			//设置变量
			m_wCurrentUser=GlobalDef.INVALID_CHAIR;
			m_wOutSparrowUser=pOutSparrow.wOutCardUser;
			m_cbOutSparrowData=pOutSparrow.cbOutSparrowData;
			
			//其他用户
			if ((IsLookonMode()==true)||(pOutSparrow.wOutCardUser!=wMeChairID))
			{
				//环境设置
				KillGameTimer(IDI_OPERATE_SPARROW); 
				//PlaySparrowSound(pOutSparrow.cbOutSparrowData);
				
				//出牌界面
				GetPeerGameView().SetUserAction(GlobalDef.INVALID_CHAIR,0);
				GetPeerGameView().SetOutSparrowInfo(wOutViewChairID,pOutSparrow.cbOutSparrowData);
				
				var wUserIndex:uint=(wOutViewChairID>1)?1:wOutViewChairID;
				GetPeerGameView().m_UserSparrow[wUserIndex].SetCurrentSparrow(false);
				
				operateCode = m_GameLogic.EstimateOperate(m_cbSparrowIndex,pOutSparrow.cbOutSparrowData);
				
				var arrOperateList:Array = new Array;
				
				if(operateCode&GameLogicDef.WIK_CHI_HU){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_CHI_HU;
					arrOperateList.push(operateInfo);
				}
				if(operateCode&GameLogicDef.WIK_GANG){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_GANG;
					operateInfo.cbOperateSparrow = [m_cbOutSparrowData];
					arrOperateList.push(operateInfo);
				}
				if(operateCode&GameLogicDef.WIK_PENG){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = GameLogicDef.WIK_PENG;
					operateInfo.cbOperateSparrow = [m_cbOutSparrowData];
					arrOperateList.push(operateInfo);
				}
				if(operateCode&(GameLogicDef.WIK_CENTER|GameLogicDef.WIK_LEFT|GameLogicDef.WIK_RIGHT)){
					var operateInfo:tagOperateInfo = new tagOperateInfo;
					operateInfo.cbOperateCode = operateCode&(GameLogicDef.WIK_CENTER|GameLogicDef.WIK_LEFT|GameLogicDef.WIK_RIGHT);
					operateInfo.cbOperateSparrow = [m_cbOutSparrowData];
					arrOperateList.push(operateInfo);
				}
				////////////////////////////////////////////////////
				if(operateCode == GameLogicDef.WIK_NULL){
					onSparrowOperate(GameLogicDef.WIK_NULL,0);
				}
				else{
					GetPeerGameView().controlMc(operateCode,arrOperateList,m_bHearStatus);
				}				 
				////////////////////////////////////////////////////
		
			}
			//设置麻将
			if (wOutViewChairID==1)
			{
				//删除麻将
				m_GameLogic.RemoveSparrow2(m_cbSparrowIndex,pOutSparrow.cbOutSparrowData);
	
				//设置麻将
				var cbSparrowData:Array = new Array(GameLogicDef.MAX_COUNT);
				var cbSparrowCount:uint=m_GameLogic.SwitchToSparrowData2(m_cbSparrowIndex,cbSparrowData);
				GetPeerGameView().m_HandCardControl.SetSparrowData(cbSparrowData,cbSparrowCount,0);
			}				
			
			//设置丢弃麻将界面
			if ((m_wOutSparrowUser!=GlobalDef.INVALID_CHAIR)&&(m_cbOutSparrowData!=0))
			{
				m_cbDiscardSparrow[pOutSparrow.wOutCardUser][m_cbDiscardCount[pOutSparrow.wOutCardUser]++] = m_cbOutSparrowData;
				//丢弃麻将
				var wOutViewChairID:uint=SwitchViewChairID(m_wOutSparrowUser);
				GetPeerGameView().m_DiscardSparrow[wOutViewChairID].AddSparrowItem(m_cbOutSparrowData);
			}
			
			//设置听牌状态
			GetPeerGameView().setTing(SwitchViewChairID(pOutSparrow.wOutCardUser),pOutSparrow.bIsTing);			
			
			//播放声音
			PlayGameSound("OUT_SPARROW");
			var isMan:Boolean = GetUserInfo(pOutSparrow.wOutCardUser).cbGender == GlobalDef.GENDER_BOY?true:false;
			PlaySparrowSound(pOutSparrow.cbOutSparrowData,isMan);
			
			//
			if(pOutSparrow.wCurrentUser!=0xffff){
				var sendCard:CMD_S_SendCard = new CMD_S_SendCard;
				sendCard.cbCardData = pOutSparrow.cbCurrentCard;
				sendCard.wCurrentUser = pOutSparrow.wCurrentUser;
				
				var bytes:ByteArray = sendCard.toByteArray();
				
				OnSubSendSparrow(bytes,CMD_S_SendCard.sizeof_CMD_S_SendCard);
				return true;
			}
			
			//设置倒计时
			var nextChairID:int = (pOutSparrow.wOutCardUser+1)%CMD_Sparrow.GAME_PLAYER;
			var wTimeCount:uint=TIME_OPERATE_SPARROW;
			if ((m_bHearStatus==true)&&(nextChairID==wMeChairID)&&((operateCode&GameLogicDef.WIK_CHI_HU)==0)){
				wTimeCount=TIME_HEAR_STATUS;
			} 	
			SetGameTimer(nextChairID,IDI_OPERATE_SPARROW,wTimeCount);
			
			return true;
		}
		/**
		 * 发送扑克，如果是自己的牌逻辑判断是否可以杠听胡
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnSubSendSparrow(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			//效验数据
			Memory.ASSERT(wDataSize==CMD_S_SendCard.sizeof_CMD_S_SendCard);
			if (wDataSize!=CMD_S_SendCard.sizeof_CMD_S_SendCard) return false;
		
			//变量定义
			var pSendSparrow:CMD_S_SendCard=CMD_S_SendCard.readData(pBuffer);
			var operateCode:uint = GameLogicDef.WIK_NULL;
			
			//设置变量
			var wMeChairID:uint=GetMeChairID();
			m_wCurrentUser=pSendSparrow.wCurrentUser;
		
			//丢弃麻将
			if ((m_wOutSparrowUser!=GlobalDef.INVALID_CHAIR)&&(m_cbOutSparrowData!=0))
			{
				//设置变量
				m_cbOutSparrowData=0;
				m_wOutSparrowUser=GlobalDef.INVALID_CHAIR;
			}
		
			//发牌处理
			if (pSendSparrow.cbCardData!=0)
			{
				//取牌界面
				var  wViewChairID:uint=SwitchViewChairID(m_wCurrentUser);
				
				if (wViewChairID!=1)
				{
					var wUserIndex:uint=(wViewChairID>1)?1:wViewChairID;
					GetPeerGameView().m_UserSparrow[wUserIndex].SetCurrentSparrow(true);
				}
				//当前用户
				if ((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID))
				{
					var arrListenResult:Array = new Array;
					var arrOperateList:Array = new Array;
					var gangItem:tagGangCardResult = new tagGangCardResult;
					
					//逻辑判断是否可以杠、胡
					operateCode |= m_GameLogic.EstimateChiHu(m_cbSparrowIndex,pSendSparrow.cbCardData);
					m_GameLogic.AnalyseGangSparrow(m_cbSparrowIndex,m_WeaveItemArray[GetMeChairID()],m_cbWeaveCount[GetMeChairID()],gangItem);
					if(gangItem.cbCardCount>0){
						//operateCode |= GameLogicDef.WIK_GANG;
						
					}
					operateCode |= m_GameLogic.EstimateGangSparrow(m_cbSparrowIndex,pSendSparrow.cbCardData);
					operateCode |= m_GameLogic.EstimateGangSparrow2(m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],pSendSparrow.cbCardData);
					operateCode |= m_GameLogic.EstimateListenSparrow(m_cbSparrowIndex,pSendSparrow.cbCardData,arrListenResult);
					
					if(operateCode&GameLogicDef.WIK_CHI_HU){
						var operateInfo:tagOperateInfo = new tagOperateInfo;
						operateInfo.cbOperateCode = GameLogicDef.WIK_CHI_HU;
						arrOperateList.push(operateInfo);
					}
					if(operateCode&GameLogicDef.WIK_GANG){
						var operateInfo:tagOperateInfo = new tagOperateInfo;
						operateInfo.cbOperateCode = GameLogicDef.WIK_GANG;
						operateInfo.cbOperateSparrow = [pSendSparrow.cbCardData];
						arrOperateList.push(operateInfo);
						
					}
					if(gangItem.cbCardCount>0){
						var operateInfo:tagOperateInfo = new tagOperateInfo;
						operateInfo.cbOperateCode = GameLogicDef.WIK_GANG;
						operateInfo.cbOperateSparrow = gangItem.cbCardData;
						arrOperateList.push(operateInfo);
						
						operateCode |=GameLogicDef.WIK_GANG;
					}
					if(operateCode&GameLogicDef.WIK_LISTEN){
						var operateInfo:tagOperateInfo = new tagOperateInfo;
						operateInfo.cbOperateCode = GameLogicDef.WIK_LISTEN;
						operateInfo.cbOperateSparrow = arrListenResult;
						arrOperateList.push(operateInfo);
					}
					
					if(operateCode == GameLogicDef.WIK_NULL){
						onSparrowOperate(GameLogicDef.WIK_NULL,0);
					}else{
						GetPeerGameView().controlMc(operateCode,arrOperateList,m_bHearStatus);
					}
					//设置麻将
					++m_cbSparrowIndex[m_GameLogic.SwitchToSparrowIndex1(pSendSparrow.cbCardData)];
					GetPeerGameView().m_HandCardControl.SetCurrentSparrowData(pSendSparrow.cbCardData);		 
				}
				//扣除麻将
				DeductionTableSparrow(true);
			}
			//出牌提示
			GetPeerGameView().SetStatusFlag((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID)&&(!m_bHearStatus),false);
		
			//更新界面
			GetPeerGameView().UpdateGameView();
			
			trace("in GameClass OnSubSendSparrow:operateCode&GameLogicDef.WIK_CHI_HU = " + String(operateCode&GameLogicDef.WIK_CHI_HU) + "   operateCode = " + operateCode);
			
			//计算时间
			var wTimeCount:uint=TIME_OPERATE_SPARROW;
			if ((m_bHearStatus==true)&&(pSendSparrow.wCurrentUser==wMeChairID)&&((operateCode&GameLogicDef.WIK_CHI_HU)==0)){
				wTimeCount=TIME_HEAR_STATUS;
			} 		
			//设置时间
			SetGameTimer(m_wCurrentUser,IDI_OPERATE_SPARROW,wTimeCount);
			
			return true;
		}
		
		//	听牌命令
		protected function OnSubListenSparrow(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			if(wDataSize!=CMD_S_ListenCard.sizeof_CMD_S_ListenCard) return false;
			
			var pListenData:CMD_S_ListenCard = CMD_S_ListenCard.readData(pBuffer);
			
			//设置状态
			m_bHearStatus = true;
			
			return true;	
		}
		
		//	操作提示
		/* protected function OnSubOperateNotify(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			//效验数据
			Memory.ASSERT(wDataSize==CMD_S_OperateNotify.sizeof_CMD_S_OperateNotify);
			if (wDataSize!=CMD_S_OperateNotify.sizeof_CMD_S_OperateNotify) return false;
			
			//变量定义
			var pOperateNotify:CMD_S_OperateNotify=CMD_S_OperateNotify.readData(pBuffer);
			
			//用户界面
			if ((IsLookonMode()==false)&&(pOperateNotify.cbActionMask!=GameLogicDef.WIK_NULL))
			{
				//获取变量
				var cbActionMask:uint=pOperateNotify.cbActionMask;
				var cbActionSparrow:uint=pOperateNotify.cbActionCard;
		
				//变量定义
				var GangSparrowResult:tagGangCardResult = new tagGangCardResult;
				
				//杠牌判断
				if ((cbActionMask&(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL))!=0)
				{
					//桌面杆牌
					if ((m_wCurrentUser==GlobalDef.INVALID_CHAIR)&&(cbActionSparrow!=0))
					{
						GangSparrowResult.cbCardCount=1;
						GangSparrowResult.cbCardData[0]=cbActionSparrow;
					}
		
					//自己杆牌
					if ((m_wCurrentUser==GetMeChairID())||(cbActionSparrow==0))
					{
						var wMeChairID:uint=GetMeChairID();
						m_GameLogic.AnalyseGangSparrow(m_cbSparrowIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangSparrowResult);
					}
				}
		
				//设置界面
				//ActiveGameFrame();
				SetGameTimer(GetMeChairID(),IDI_OPERATE_SPARROW,TIME_OPERATE_SPARROW);
				GetPeerGameView().m_ControlMC.SetControlInfo(cbActionSparrow,cbActionMask,GangSparrowResult);
			}
		
			return true;
		} */
		/**
		 * 操作结果命令，
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnSubOperateResult(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			//效验消息
			Memory.ASSERT(wDataSize==CMD_S_OperateResult.sizeof_CMD_S_OperateResult);
			if (wDataSize!=CMD_S_OperateResult.sizeof_CMD_S_OperateResult) return false;
			
			//消息处理
			var pOperateResult:CMD_S_OperateResult=CMD_S_OperateResult.readData(pBuffer);
			
			//变量定义
			var cbPublicSparrow:Boolean = true;
			var wOperateUser:uint = pOperateResult.wOperateUser;
			var cbOperateSparrow:uint=pOperateResult.cbOperateCard;
			var wOperateViewID:uint=SwitchViewChairID(wOperateUser);
			
			//设置组合
			if ((pOperateResult.cbOperateCode&(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL))!=0)
			{
				//设置变量
				var t:GameLogicDef;
				var f:GlobalDef;
				m_wCurrentUser=GlobalDef.INVALID_CHAIR;
		
				//组合麻将
				var cbWeaveIndex:uint=0xFF;
				for (var i:uint=0;i<m_cbWeaveCount[wOperateUser];i++)
				{
					var cbWeaveKind:uint=m_WeaveItemArray[wOperateUser][i].cbWeaveKind;
					var cbCenterSparrow:uint=m_WeaveItemArray[wOperateUser][i].cbCenterSparrow;
					if ((cbCenterSparrow==cbOperateSparrow)&&(cbWeaveKind==GameLogicDef.WIK_PENG))
					{
						cbWeaveIndex=i;
						m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicSparrow=true;
						m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult.cbOperateCode;
						m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult.wProvideUser;
						break;
					}
				}
		
				//组合麻将
				if (cbWeaveIndex==0xFF)
				{
					//暗杠判断
					cbPublicSparrow=(pOperateResult.wProvideUser==wOperateUser)?false:true;
		
					//设置麻将
					cbWeaveIndex=m_cbWeaveCount[wOperateUser]++;
					m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicSparrow=cbPublicSparrow;
					m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterSparrow=cbOperateSparrow;
					m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult.cbOperateCode;
					m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult.wProvideUser;
				}
		
				//组合界面
				var cbWeaveSparrow:Array = new Array(0,0,0,0);
				var cbWeaveKind:uint=pOperateResult.cbOperateCode;
				var cbWeaveSparrowCount:uint=m_GameLogic.GetWeaveSparrow(cbWeaveKind,cbOperateSparrow,cbWeaveSparrow);
				GetPeerGameView().m_WeaveSparrow[wOperateViewID][cbWeaveIndex].SetSparrowData(cbWeaveSparrow,cbWeaveSparrowCount);
				GetPeerGameView().m_WeaveSparrow[wOperateViewID][cbWeaveIndex].SetDisplayItem((cbPublicSparrow==true)?true:false);
		
				//麻将设置
				if (GetMeChairID()==wOperateUser)
				{
					m_cbSparrowIndex[m_GameLogic.SwitchToSparrowIndex1(pOperateResult.cbOperateCard)]=0;
				}
		
				//设置麻将
				if (GetMeChairID()==wOperateUser)
				{
					var cbSparrowData:Array = new Array(GameLogicDef.MAX_COUNT);
					var cbSparrowCount:uint=m_GameLogic.SwitchToSparrowData2(m_cbSparrowIndex,cbSparrowData);
					GetPeerGameView().m_HandCardControl.SetSparrowData(cbSparrowData,cbSparrowCount,0);
				}
				else
				{
					var wUserIndex:uint=(wOperateViewID>=3)?2:wOperateViewID;
					var cbSparrowCount:uint=GameLogicDef.MAX_COUNT-m_cbWeaveCount[wOperateUser]*3;
					GetPeerGameView().m_UserSparrow[wUserIndex].SetSparrowData(cbSparrowCount-1,false);
				}
				
			}
			else if (pOperateResult.cbOperateCode!=GameLogicDef.WIK_NULL)
			{
				//设置变量
				m_wCurrentUser=pOperateResult.wOperateUser;
		
				//设置组合
				var cbWeaveIndex:uint=m_cbWeaveCount[wOperateUser]++;
								
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicSparrow=true;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterSparrow=pOperateResult.cbOperateCard;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult.cbOperateCode;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult.wProvideUser;
		
				//组合界面
				var cbWeaveSparrow:Array=new Array(0,0,0,0);
				var cbWeaveKind:uint=pOperateResult.cbOperateCode;
				var cbWeaveSparrowCount:uint=m_GameLogic.GetWeaveSparrow(cbWeaveKind,cbOperateSparrow,cbWeaveSparrow);
				GetPeerGameView().m_WeaveSparrow[wOperateViewID][cbWeaveIndex].SetSparrowData(cbWeaveSparrow,cbWeaveSparrowCount);
		
				//删除麻将
				if (GetMeChairID()==wOperateUser)
				{
					var a:Array = new Array(1);
					a[0] = cbOperateSparrow;
					m_GameLogic.RemoveSparrow4(cbWeaveSparrow,cbWeaveSparrowCount,a,1);
					m_GameLogic.RemoveSparrow3(m_cbSparrowIndex,cbWeaveSparrow,cbWeaveSparrowCount-1);
					var cbSparrowData:Array = new Array(GameLogicDef.MAX_COUNT);
					var cbSparrowCount:uint=m_GameLogic.SwitchToSparrowData2(m_cbSparrowIndex,cbSparrowData);
					GetPeerGameView().m_HandCardControl.SetSparrowData(cbSparrowData,cbSparrowCount-1,cbSparrowData[cbSparrowCount-1]);
					
					//判断听牌
					var arrListenResult:Array = new Array;
					var arrOperateList:Array = new Array;
					var operateCode:uint = GameLogicDef.WIK_NULL;
					operateCode |= m_GameLogic.EstimateListenSparrow(m_cbSparrowIndex,0,arrListenResult);
					if(operateCode&GameLogicDef.WIK_LISTEN){
						var operateInfo:tagOperateInfo = new tagOperateInfo;
						operateInfo.cbOperateCode = GameLogicDef.WIK_LISTEN;
						operateInfo.cbOperateSparrow = arrListenResult;
						arrOperateList.push(operateInfo);
					}
					
					if(operateCode != GameLogicDef.WIK_NULL){
						GetPeerGameView().controlMc(operateCode,arrOperateList,m_bHearStatus);
					}
				}
				else
				{
					var wUserIndex:uint=(wOperateViewID>=3)?2:wOperateViewID;
					var cbSparrowCount:uint=GameLogicDef.MAX_COUNT-m_cbWeaveCount[wOperateUser]*3;
					GetPeerGameView().m_UserSparrow[wUserIndex].SetSparrowData(cbSparrowCount-1,true);
				}
			}
			//丢弃麻将
			if(pOperateResult.wProvideUser!=pOperateResult.wOperateUser){
				m_cbDiscardSparrow[pOperateResult.wProvideUser][--m_cbDiscardCount[pOperateResult.wProvideUser]] = 0;
				
			}
			//
			if ((m_wOutSparrowUser!=GlobalDef.INVALID_CHAIR)&&(m_cbOutSparrowData!=0))
			{
				//丢弃麻将
				var wOutViewChairID:uint=SwitchViewChairID(m_wOutSparrowUser);
				GetPeerGameView().m_DiscardSparrow[wOutViewChairID].RemoveSparrowItem(m_cbOutSparrowData); 
		
				//设置变量
				m_cbOutSparrowData=0;
				m_wOutSparrowUser=GlobalDef.INVALID_CHAIR;
			}
			
			//设置界面
			GetPeerGameView().SetOutSparrowInfo(GlobalDef.INVALID_CHAIR,0);
			//GetPeerGameView().m_ControlMC.ShowWindow(false);
			GetPeerGameView().SetUserAction(wOperateViewID,pOperateResult.cbOperateCode);
			GetPeerGameView().SetStatusFlag((IsLookonMode()==false)&&(m_wCurrentUser==GetMeChairID()&&(!m_bHearStatus)),false);
		
			//更新界面
			GetPeerGameView().UpdateGameView();
		
			//环境设置
			var isMan:Boolean = GetUserInfo(pOperateResult.wOperateUser).cbGender == GlobalDef.GENDER_BOY?true:false;
			PlayActionSound(pOperateResult.cbOperateCode,isMan);
			
			//发牌
			if(pOperateResult.cbCurrentCard>0){
				var sendCard:CMD_S_SendCard = new CMD_S_SendCard;
				sendCard.cbCardData = pOperateResult.cbCurrentCard;
				sendCard.wCurrentUser = pOperateResult.wCurrentUser;
				
				var bytes:ByteArray = sendCard.toByteArray();
				
				OnSubSendSparrow(bytes,CMD_S_SendCard.sizeof_CMD_S_SendCard);
				
				return true;
			}
			//设置时间
			if (m_wCurrentUser!=GlobalDef.INVALID_CHAIR)
			{
				//计算时间
				var wTimeCount:uint=TIME_OPERATE_SPARROW;
				/* if ((m_bHearStatus==true)&&(m_wCurrentUser==GetMeChairID())){
					wTimeCount=TIME_HEAR_STATUS;
				}  */
		
				//设置时间
				SetGameTimer(m_wCurrentUser,IDI_OPERATE_SPARROW,wTimeCount);
			} 
			
			return true;	
		}
		/**
		 * 接收到胡牌命令
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnSubHu(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			if(wDataSize!=CMD_S_SendHuCard.sizeof_CMD_S_SendHuCard) return false;
			
			var pHuCard:CMD_S_SendHuCard = CMD_S_SendHuCard.readData(pBuffer);
			
			m_wHuUser = pHuCard.wHuUser;
			var huerLeftSparrowCount:int = 0;//胡牌者手里牌数
			var huerLeftSparrowList:Array = new Array;//胡牌者手里的牌
			var zimo:Boolean = (pHuCard.wProvideUser == pHuCard.wHuUser)?true:false;
			
			for(var i:int = 0; i<pHuCard.cbHuCardList.length; i++){
				if(pHuCard.cbHuCardList[i]==0){
					break;
				}
				huerLeftSparrowList[i] = pHuCard.cbHuCardList[i];
				++huerLeftSparrowCount;
			}
			//胡牌者亮牌
			if(m_wHuUser==GetMeChairID()){
				GetPeerGameView().m_HandCardControl.setShowSparrowData(huerLeftSparrowList,huerLeftSparrowCount,pHuCard.cbHuCard);
			}			
			else{
				(GetPeerGameView().m_UserSparrow[0] as UserSparrow).setShowSparrowData(huerLeftSparrowList,huerLeftSparrowCount,pHuCard.cbHuCard);
			}			
			
			//侦听动画完成
			GetPeerGameView().addEventListener("B_Sparrow_Over",gameEndHandle,false,0,true);
			
			//播放声音
			var isMan:Boolean = GetUserInfo(pHuCard.wHuUser).cbGender == GlobalDef.GENDER_BOY?true:false;
			if(zimo){
				PlayActionSound(HU_ZIMO,isMan);
				GetPeerGameView().showZiMoMonition();
			}
			else{
				PlayActionSound(HU_DIANPAO,isMan);
				GetPeerGameView().showDianPaoMonition();
			}
			
			return true;
		}
		//	游戏结束
		protected function OnSubGameEnd(pBuffer:ByteArray,wDataSize:uint):Boolean
		{
			//if(wDataSize!=CMD_S_GameEnd.sizeof_CMD_S_GameEnd) return false;
			
			Cmd_GameEnd = CMD_S_GameEnd.readData(pBuffer);
			
			if(!GetPeerGameView().hasEventListener("B_Sparrow_Over"))
				gameEndHandle();
			
			return true;	
		}
		/**
		 * 游戏结束
		 * 
		 */
		private function gameEndHandle(evt:Event=null):void
		{
			if(!Cmd_GameEnd) return ;
			
			//设置界面
			GetPeerGameView().m_ScoreView.showWindow(true);
			GetPeerGameView().viewComponent.start_Btn.visible = true;
			if(m_wHuUser>-1){
				//胡牌的牌
				GetPeerGameView().m_ScoreView.setSparrowData(Cmd_GameEnd.cbCardData[m_wHuUser],13,Cmd_GameEnd.cbHuData[m_wHuUser]);
				//番种
				var arrHuType:Array = new Array;
				for(var i:int = 0; i<(Cmd_GameEnd.cbHuType[m_wHuUser] as Array).length; i++){
					if(Cmd_GameEnd.cbHuType[m_wHuUser][i] == 1){
						arrHuType.push(GameLogicDef.HUTYPE[i]);
					}
				}
				GetPeerGameView().m_ScoreView.setFanType(arrHuType);
				
				//积分
				var scoreList:Array = new Array;
				for(i = 0; i<Cmd_GameEnd.lGameScore.length; i++){
					var obj:Object = new Object;
					obj["userName"] = GetUserInfo(i).szName;
					obj["fan"] = i== m_wHuUser? m_GameLogic.GetHuCardScore(Cmd_GameEnd.cbHuType[i]):0;
					obj["score"] = Cmd_GameEnd.lGameScore[i];
					scoreList.push(obj);
				}
				GetPeerGameView().m_ScoreView.setUserScore(scoreList);
			}				
			
			//播放音效
			switch(Cmd_GameEnd.cbFinalState[GetMeChairID()])
			{
				case GameLogicDef.FINAL_STATE_HU_ZIMO:	//自摸赢
				{
					PlayGameSound("A_ZIMO_WIN");
					break;
				}
				case GameLogicDef.FINAL_STATE_HU:		//平胡赢
				{
					PlayGameSound("A_PAO_WIN");
					break;
				}
				default:
				{
					switch(Cmd_GameEnd.cbFinalState[(GetMeChairID()+1)%CMD_Sparrow.GAME_PLAYER])
					{
						case GameLogicDef.FINAL_STATE_HU_ZIMO:	//对方自摸
						{
							PlayGameSound("A_ZIMO_LOST");
							break;
						}
						case GameLogicDef.FINAL_STATE_HU:		//对方平胡
						{
							PlayGameSound("A_PAO_LOST");
							break;
						}
						default:	//流局
						{
							PlayGameSound("A_LIUJU");
							GetPeerGameView().drawMonition();
							break;
						}
					}
					break;
				}
				
			}
			//设置倒计时
			KillGameTimer(IDI_OPERATE_SPARROW);
			SetGameTimer(GetMeChairID(),IDI_EXIT_GAME,TIME_START_GAME);
			
			//
			GetPeerGameView().removeEventListener("B_Sparrow_Over",gameEndHandle,false);
			m_wHuUser=-1;
			Cmd_GameEnd = null;
		}
		
		//
		protected function DeductionTableSparrow( bHeadSparrow:Boolean):void
		{
			if (bHeadSparrow==true)
			{
				//切换索引
				var cbHeapCount:uint=m_cbHeapSparrowInfo[m_wHeapHand][0]+m_cbHeapSparrowInfo[m_wHeapHand][1];
				if (cbHeapCount==SparrowDef.HEAP_FULL_COUNT) m_wHeapHand=(m_wHeapHand+1)%Memory.CountArray(m_cbHeapSparrowInfo);
				
				//减少麻将
				m_cbLeftSparrowCount--;
				m_cbHeapSparrowInfo[m_wHeapHand][0]++;
				
				//堆立麻将
				var wHeapViewID:uint=SwitchViewChairID(m_wHeapHand);
				var wMinusHeadCount:uint=m_cbHeapSparrowInfo[m_wHeapHand][0];
				var wMinusLastCount:uint=m_cbHeapSparrowInfo[m_wHeapHand][1];
			//	GetPeerGameView().m_HeapSparrow[wHeapViewID].SetSparrowData(wMinusHeadCount,wMinusLastCount,SparrowDef.HEAP_FULL_COUNT);
			}
			else
			{
				//切换索引
				var cbHeapCount:uint=m_cbHeapSparrowInfo[m_wHeapTail][0]+m_cbHeapSparrowInfo[m_wHeapTail][1];
				if (cbHeapCount==SparrowDef.HEAP_FULL_COUNT) m_wHeapTail=(m_wHeapTail+3)%Memory.CountArray(m_cbHeapSparrowInfo);
		
				//减少麻将
				m_cbLeftSparrowCount--;
				m_cbHeapSparrowInfo[m_wHeapTail][1]++;
		
				//堆立麻将
				var wHeapViewID:uint=SwitchViewChairID(m_wHeapTail);
				var wMinusHeadCount:uint=m_cbHeapSparrowInfo[m_wHeapTail][0];
				var wMinusLastCount:uint=m_cbHeapSparrowInfo[m_wHeapTail][1];
			//	GetPeerGameView().m_HeapSparrow[wHeapViewID].SetSparrowData(wMinusHeadCount,wMinusLastCount,SparrowDef.HEAP_FULL_COUNT);
			}
		
			return;
		}
		//显示控制
		protected function ShowOperateControl(cbUserAction:uint, cbActionSparrow:uint):Boolean
		{
			//变量定义
			//变量定义
			var GangSparrowResult:tagGangCardResult= new tagGangCardResult();
		
			//杠牌判断
			if ((cbUserAction&(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL))!=0)
			{
				//桌面杆牌
				if (cbActionSparrow!=0)
				{
					GangSparrowResult.cbCardCount=1;
					GangSparrowResult.cbCardData[0]=cbActionSparrow;
				}
		
				//自己杆牌
				if (cbActionSparrow==0)
				{
					var wMeChairID:uint=GetMeChairID();
					m_GameLogic.AnalyseGangSparrow(m_cbSparrowIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangSparrowResult);
				}
			}
			
			//显示界面
			//GetPeerGameView().m_ControlMC.SetControlInfo(cbActionSparrow,cbUserAction,GangSparrowResult);
			
			return true;
		}		
		
	}
}