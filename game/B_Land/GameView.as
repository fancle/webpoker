package B_Land
{
	import Application.model.vo.protocol.room.tagUserData;
	import Application.utils.Memory;
	
	import B_Land.common.CMD_Land;
	import B_Land.common.MaterialLib;
	
	import common.data.GlobalDef;
	import common.data.gameEvent;
	import common.game.GameBaseView;
	import common.game.enXCollocateMode;
	import common.game.enYCollocateMode;
	import common.game.interfaces.IFaceView;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.flash.UIMovieClip;

	/**
	 * 
	 * @author Administrator
	 */
	public class GameView extends GameBaseView
	{
		//游戏变量
		/**
		 * 
		 * @default 
		 */
		protected var m_wLandUser:uint; //地主用户
		/**
		 * 
		 * @default 
		 */
		protected var m_wBombTime:uint; //炸弹倍数
		/**
		 * 
		 * @default 
		 */
		protected var m_fBaseScore:Number=Number(0); //基础分数
		/**
		 * 
		 * @default 
		 */
		protected var m_cbLandScore:uint; //地主分数

		//配置变量
		/**
		 * 
		 * @default 
		 */
		protected var m_bDeasilOrder:Boolean; //出牌顺序

		//状态变量
		/**
		 * 
		 * @default 
		 */
		public var m_bLandTitle:Boolean; //地主标志
		/**
		 * 
		 * @default 
		 */
		public var m_pPassOutCardView:Array=new Array(CMD_Land.GAME_PLAYER);
		/**
		 * 
		 * @default 
		 */
		public var m_bPass:Array=new Array(CMD_Land.GAME_PLAYER); //放弃数组
		/**
		 * 
		 * @default 
		 */
		public var m_pScoreView:Array=new Array(CMD_Land.GAME_PLAYER);
		/**
		 * 
		 * @default 
		 */
		public var m_bScore:Array=new Array(CMD_Land.GAME_PLAYER); //用户叫分
		/**
		 * 
		 * @default 
		 */
		public var m_bCardCount:Array=new Array(CMD_Land.GAME_PLAYER); //扑克数目
		/**
		 * 
		 * @default 
		 */
		public var m_bLastTurnCard:Boolean; //上轮扑克

		//位置信息
		/**
		 * 
		 * @default 
		 */
		public var m_ptScore:Array=new Array(CMD_Land.GAME_PLAYER); //叫分位置

		/**
		 * 
		 * @default 
		 */
		public var m_btStart:Button; //开始按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btOutCard:Button; //出牌按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btPassCard:Button; //放弃按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btOneScore:Button; //一分按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btTwoScore:Button; //二分按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btThreeScore:Button; //3分按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btGiveUpScore:Button; //放弃按钮
		/**
		 * 
		 * @default 
		 */
		public var m_btAutoOutCard:Button; //提示按钮

		/**
		 * 
		 * @default 
		 */
		public var m_HandCardControl:CardControl; //手上扑克
		/**
		 * 
		 * @default 
		 */
		public var m_BackCardControl:CardControl; //底牌扑克
		/**
		 * 
		 * @default 
		 */
		public var m_UserCardControl:Array=new Array(3); //扑克视图
		/**
		 * 
		 * @default 
		 */
		public var m_LeaveCardControl:Array=new Array(2); //结束扑克
		/**
		 * 
		 * @default 
		 */
		public var _poke:Class;
		/**
		 * 
		 * @default 
		 */
		public var _assets:LoaderInfo;

		/**
		 * 
		 * @default 
		 */
		public var viewComponent:B_Land_View;

		public var m_ScoreView:ScoreView;//积分视图
		public var m_ScoreViewHistory:ScoreViewHistory//积分历史记录

			
		/**
		 * 
		 * @param value
		 */
		public function GameView(value:GameClass)
		{
			super(value);


		}

		/**
		 * 游戏初始化
		 * 
		 * @return 
		 */
		override public function InitGameView():Boolean
		{
			if (super.InitGameView() == false)
			{
				return false;
			}
			//这里与源码不同 这里注意
	
			_assets=m_GameClass.assets;
			MaterialLib.getInstance().push(_assets.applicationDomain);
			_poke=MaterialLib.getInstance().getClass("poke");

			viewComponent=new B_Land_View();
			addChild(viewComponent);
			//



			Memory.ZeroArray(m_bPass, false);
			for (var i:uint=0; i < m_ptScore.length; i++)
			{
				m_ptScore[i]=new Point();

			}

			m_HandCardControl=new CardControl(_poke);
			viewComponent.ownerCardBox.addChild(m_HandCardControl);



			m_BackCardControl=new CardControl(_poke);
			m_BackCardControl.SetCardSpace(75, 0, 0);
			m_BackCardControl.SetDisplayFlag(true);
			m_BackCardControl.SetBenchmarkPos(viewComponent.backCardBox.width / 2, 10, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);
			viewComponent.backCardBox.addChild(m_BackCardControl);


			for (i=0; i < m_UserCardControl.length; i++)
			{
				m_UserCardControl[i]=new CardControl(_poke);
				m_UserCardControl[i].SetDirection(true);
				m_UserCardControl[i].SetDisplayFlag(true);
				
				switch (i)
				{
					case 0:
						viewComponent.leftUserCard.addChild(m_UserCardControl[i]);
						m_UserCardControl[i].SetBenchmarkPos(viewComponent.leftUserCard.width/2, 0, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);
						break;
					case 1:
						viewComponent.ownerUserCard.addChild(m_UserCardControl[i]);
						m_UserCardControl[i].SetBenchmarkPos(viewComponent.ownerUserCard.width/2, 0, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);
						break;
					case 2:
						viewComponent.rightUserCard.addChild(m_UserCardControl[i]);
						m_UserCardControl[i].SetBenchmarkPos(viewComponent.rightUserCard.width/2, 0, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);
						break;
				}
			}
			for (i=0; i < m_LeaveCardControl.length; i++)
			{
				m_LeaveCardControl[i]=new CardControl(_poke);
				m_LeaveCardControl[i].SetDirection(false);
				m_LeaveCardControl[i].SetDisplayFlag(true);
				m_LeaveCardControl[i].SetCardSpace(0, 15, 0);
				switch (i)
				{
					case 0:
						viewComponent.pokeLeft.addChild(m_LeaveCardControl[i]);
						break;
					case 1:
						viewComponent.pokeRight.addChild(m_LeaveCardControl[i]);
						break;
				}
			}
			
			m_ScoreView = new ScoreView();
			
			viewComponent.addChild(m_ScoreView);
			m_ScoreView.ShowWindow(false);
			m_ScoreView.x = (viewComponent.width-m_ScoreView.width)/2;
			m_ScoreView.y = (viewComponent.height-m_ScoreView.height)/2;
			//配置变量
			m_bDeasilOrder=false;
			//状态变量
			m_bLandTitle=false;
			m_bLastTurnCard=false;

			setLookBg(viewComponent, "B_Land_bg");
			setLookBg(viewComponent.backCardBox, "B_Land_BackCardBg");
			setLookBg(viewComponent.leftHeadBox, "headBg");
			setLookBg(viewComponent.rightHeadBox, "headBg");
			setLookBg(viewComponent.ownerHeadBox, "headBg");
			setLookSkin(viewComponent.m_btStart, "readyBtn");
			setLookSkin(viewComponent.m_btOutCard, "outCard");
			setLookSkin(viewComponent.m_btPassCard, "passCard");
			setLookSkin(viewComponent.m_btOneScore, "oneScore");
			setLookSkin(viewComponent.m_btTwoScore, "twoScore");
			setLookSkin(viewComponent.m_btThreeScore, "threeScore");
			setLookSkin(viewComponent.m_btGiveUpScore, "giveUp");
			setLookSkin(viewComponent.m_btAutoOutCard, "autoCard");
			setLookSkin(viewComponent.m_sortCard, "sortCard");
			setLookSkin(viewComponent.m_bTrustCard, "trusteeship");
			
			//m_ScoreView.visible = false;
			
			


			addEvent(); //注册各个按钮的鼠标事件

			//游戏变量
			m_fBaseScore=0;
			m_wBombTime=0;
			m_cbLandScore=1;
			m_wLandUser=GlobalDef.INVALID_CHAIR;


			//扑克控件
			m_BackCardControl.SetCardData(null, 0);
			m_HandCardControl.SetCardData(null, 0);
			m_HandCardControl.SetPositively(false);
			m_HandCardControl.SetDisplayFlag(false);
			m_HandCardControl.SetBenchmarkPos(viewComponent.ownerCardBox.width / 2, 0, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);

			m_LeaveCardControl[0].SetCardData(null, 0);
			m_LeaveCardControl[1].SetCardData(null, 0);

			for (i=0; i < CMD_Land.GAME_PLAYER; i++)
			{
				m_UserCardControl[i].SetCardData(null, 0);
			}
			
			//
			m_ScoreViewHistory = new ScoreViewHistory();
			viewComponent.socreHistory.addChild(m_ScoreViewHistory);
			


			//各种按钮的现实与使用的控制
			viewComponent.m_btOutCard.visible=false;
			viewComponent.m_btPassCard.visible=false;
			viewComponent.m_btAutoOutCard.visible=false;

			viewComponent.m_btGiveUpScore.visible=false;
			viewComponent.m_btOneScore.visible=false;
			viewComponent.m_btTwoScore.visible=false;
			viewComponent.m_btThreeScore.visible=false;
		
			viewComponent.m_btStart.visible = false;
			viewComponent.m_bTrustCard.enabled=false;
			viewComponent.m_sortCard.enabled = false;
			viewComponent.leftHeadBox.visible = false;
			viewComponent.rightHeadBox.visible = false;
			viewComponent.backCardBox.visible = false;
			
			
			
			return true;
		}

		//扑克数目
		/**
		 * 
		 * @param wChairID
		 * @param bCardCount
		 */
		public function SetCardCount(wChairID:uint, bCardCount:uint):void
		{
			//设置变量
			if (wChairID == GlobalDef.INVALID_CHAIR)
			{
				for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
				{
					m_bCardCount[i]=bCardCount;
				}
			}
			else
			{
				m_bCardCount[wChairID]=bCardCount;

			}
		}
		public function showRocketMotion():void{
			var rocket:* = MaterialLib.getInstance().getMaterial("B_Land_Rocket");
		    rocket.x = viewComponent.leftUserCard.width+viewComponent.leftUserCard.x;
		    rocket.y = viewComponent.leftUserCard.y+20;
		    viewComponent.addChild(rocket);
		    rocket.addEventListener("B_Land_Over",overMotion,false,0,true);
		}
		public function showPlaneMotion():void{
			var plane:* = MaterialLib.getInstance().getMaterial("B_Land_Plane");
		    plane.x = viewComponent.leftUserCard.width+viewComponent.leftUserCard.x;
		    plane.y = viewComponent.leftUserCard.y+20;
		    viewComponent.addChild(plane);
		    plane.addEventListener("B_Land_Over",overMotion,false,0,true);
		}
		public function ShowBombMotion():void{
		    var bomb:* = (MaterialLib.getInstance().getMaterial("B_Land_bomb"));
		    bomb.x = viewComponent.leftUserCard.width+viewComponent.leftUserCard.x;
		    bomb.y = viewComponent.leftUserCard.y+20;
		    viewComponent.addChild(bomb);
		    bomb.addEventListener("B_Land_Over",overMotion,false,0,true);
		}
		public function SetBombTime(wBombTime:uint):void{
			m_wBombTime=wBombTime;
			if(m_wBombTime>=2){
				viewComponent.m_landView.bombScore.text = m_wBombTime.toString();
			}else{
				viewComponent.m_landView.bombScore.text = "";
			}
			
		}
		private function overMotion(evt:Event):void{
			 (evt.target as UIMovieClip).removeEventListener("B_Land_Over",overMotion);		
			 viewComponent.removeChild((evt.target) as UIMovieClip);
			 	 
			 
		}
		/**
		 * 设置叫牌分数
		 * @param wChairID 椅子号
		 * @param bLandScore 分数
		 */
		public function SetLandScore(wChairID:uint, bLandScore:uint):void
		{
			//设置变量
			if (wChairID != GlobalDef.INVALID_CHAIR)
			{
				m_bScore[wChairID]=bLandScore;
				UpdateScopeView(wChairID);
			}
			else
			{
				for (var i:uint=0; i < m_bScore.length; i++)
				{
					m_bScore[i]=0;
					UpdateScopeView(i);
				}
			}
			UpdateGameView();
		}

		/**
		 * 
		 * @param wChairID
		 * @param bLandScore
		 */
		public function SetLandUser(wChairID:uint, bLandScore:uint):void
		{
			//设置变量
			m_wLandUser=wChairID;
			m_cbLandScore=bLandScore;
			for (var i:int=0; i < GlobalDef.MAX_CHAIR; i++)
			{
				if (m_pUserFace[i] && m_pUserItem[i])
				{
					if (i == wChairID)
					{
						if(viewComponent.getChildByName("landerHead")==null){
								var lander:UIMovieClip = MaterialLib.getInstance().getMaterial("lander") as UIMovieClip;
								lander.name = "landerHead";
								
						}
						viewComponent.addChild(lander);
						switch(i){
							case 0:
								lander.x = viewComponent.leftHeadBox.x+viewComponent.leftHeadBox.width/2-lander.width/2+12;
								lander.y = viewComponent.leftHeadBox.y - lander.height-10;
								viewComponent.m_landView.landName.text= viewComponent.leftName.text;
								break;
							case 1:
								lander.x = viewComponent.ownerHeadBox.x+viewComponent.ownerHeadBox.width/2-lander.width/2+12;
								lander.y = viewComponent.ownerHeadBox.y - lander.height-10;
								viewComponent.m_landView.landName.text= viewComponent.ownerName.text;
								break;
							case 2:
								lander.x = viewComponent.rightHeadBox.x+viewComponent.rightHeadBox.width/2-lander.width/2+12;
								lander.y = viewComponent.rightHeadBox.y - lander.height-10;
								viewComponent.m_landView.landName.text= viewComponent.rightName.text;
								break;
						}
						viewComponent.m_landView.landScore.text = m_cbLandScore.toString();
						//var nIndex:int = m_pUserItem[i].wFaceID%2 ? FaceView.nIndex_LandGirl : FaceView.nIndex_LandBoy;
						//m_pUserFace[i].switchFaceIndex(nIndex);
					}
					else
					{
						//	var nIndex:int = m_pUserItem[i].wFaceID%2 ? FaceView.nIndex_FarmerGirl : FaceView.nIndex_FarmerBoy;
						//m_pUserFace[i].switchFaceIndex(nIndex);
					}
				}
			}
			//更新界面
			UpdateGameView();
		}

		//设置上轮
		/**
		 * 
		 * @param bLastTurnCard
		 */
		public function SetLastTurnCard(bLastTurnCard:Boolean):void
		{
			//设置变量
			if (bLastTurnCard != m_bLastTurnCard)
			{
				//设置变量
				m_bLastTurnCard=bLastTurnCard;

				//更新界面
				UpdateGameView();
			}

			return;
		}

		/**
		 * 
		 * @param bDeasilOrder
		 */
		public function SetUserOrder(bDeasilOrder:Boolean):void
		{

		}

		/**
		 * 
		 * @param wChairID
		 * @param bPass
		 */
		public function SetPassFlag(wChairID:uint, bPass:Boolean):void
		{
			if (wChairID == GlobalDef.INVALID_CHAIR)
			{
				for (var i:uint=0; i < CMD_Land.GAME_PLAYER; i++)
				{
					m_bPass[i]=bPass;
					UpdatePassOutCardView(i);
				}
			}
			else
			{
				m_bPass[wChairID]=bPass;
				UpdatePassOutCardView(wChairID);

			} //更新界面
			UpdateGameView();

			return;
		}

		//基础分数
		/**
		 * 
		 * @param fBaseScore
		 */
		public function SetBaseScore(fBaseScore:Number):void
		{
			//设置变量
			m_fBaseScore=new Number(fBaseScore);

			//刷新界面
			UpdateGameView();
		}

		private function addEvent():void
		{
			viewComponent.m_btStart.addEventListener(MouseEvent.CLICK, btnStart);
			viewComponent.m_btOutCard.addEventListener(MouseEvent.CLICK, btnOutCard);
			viewComponent.m_btPassCard.addEventListener(MouseEvent.CLICK, btnPassCard);
			viewComponent.m_btOneScore.addEventListener(MouseEvent.CLICK, btnOneScore);
			viewComponent.m_btTwoScore.addEventListener(MouseEvent.CLICK, btnTwoScore);
			viewComponent.m_btThreeScore.addEventListener(MouseEvent.CLICK, btnThreeScore);
			viewComponent.m_btGiveUpScore.addEventListener(MouseEvent.CLICK, btnGiveUpScore);
			viewComponent.m_btAutoOutCard.addEventListener(MouseEvent.CLICK, btnAutoOutCard);
			viewComponent.m_sortCard.addEventListener(MouseEvent.CLICK, btnSortCard);
			viewComponent.m_bTrustCard.addEventListener(MouseEvent.CLICK, OnEventConcealCard);
			
			viewComponent.leftHeadBox.addEventListener(MouseEvent.CLICK,dispatchPros);
			viewComponent.rightHeadBox.addEventListener(MouseEvent.CLICK,dispatchPros);
			viewComponent.ownerHeadBox.addEventListener(MouseEvent.CLICK,dispatchPros);
		}

		private function removeEvent():void
		{
			viewComponent.m_btStart.removeEventListener(MouseEvent.CLICK, btnStart);
			viewComponent.m_btOutCard.removeEventListener(MouseEvent.CLICK, btnOutCard);
			viewComponent.m_btPassCard.removeEventListener(MouseEvent.CLICK, btnPassCard);
			viewComponent.m_btOneScore.removeEventListener(MouseEvent.CLICK, btnOneScore);
			viewComponent.m_btTwoScore.removeEventListener(MouseEvent.CLICK, btnTwoScore);
			viewComponent.m_btThreeScore.removeEventListener(MouseEvent.CLICK, btnThreeScore);
			viewComponent.m_btGiveUpScore.removeEventListener(MouseEvent.CLICK, btnGiveUpScore);
			viewComponent.m_btAutoOutCard.removeEventListener(MouseEvent.CLICK, btnAutoOutCard);
			viewComponent.m_sortCard.removeEventListener(MouseEvent.CLICK, btnSortCard);
			viewComponent.m_bTrustCard.removeEventListener(MouseEvent.CLICK, OnEventConcealCard);
			
			viewComponent.leftHeadBox.removeEventListener(MouseEvent.CLICK,dispatchPros);
			viewComponent.rightHeadBox.removeEventListener(MouseEvent.CLICK,dispatchPros);
			viewComponent.ownerHeadBox.removeEventListener(MouseEvent.CLICK,dispatchPros);
		}
		
		private function dispatchPros(evt:MouseEvent):void{			
			var obj:Object = new Object();
			obj["x"] = evt.stageX;
			obj["y"] = evt.stageY;
			
			var faceView:FaceView =(((evt.currentTarget) as DisplayObjectContainer).getChildByName("faceView") as FaceView)
			if(faceView){
				obj["userId"] =  (m_pUserItem[faceView.pos] as tagUserData).dwUserID;						
				dispatchEvent(new gameEvent(gameEvent.USE_PROP,obj));
			} 			

		}
		
		private function UpdatePassOutCardView(wChairID:uint):void
		{
			if (m_bPass[wChairID])
			{
				if (m_pPassOutCardView[wChairID] == null)
				{
					m_pPassOutCardView[wChairID]=MaterialLib.getInstance().getMaterial("PassOutCardView");
					var view:UIMovieClip=m_pPassOutCardView[wChairID];
					switch (wChairID)
					{
						case 0:
							viewComponent.readyLeftBox.addChild(view);
							break;
						case 1:
							viewComponent.readyOwnerBox.addChild(view);
							break;
						case 2:
							viewComponent.readyRightBox.addChild(view);
							break;
					}
				}
			}
			else
			{
				if (m_pPassOutCardView[wChairID])
				{
					switch (wChairID)
					{
						case 0:
							viewComponent.readyLeftBox.removeAllChildren();
							break;
						case 1:
							viewComponent.readyOwnerBox.removeAllChildren();
							break;
						case 2:
							viewComponent.readyRightBox.removeAllChildren();
							break;
					}

					m_pPassOutCardView[wChairID]=null;
				}
			}
		}

		/*=========================鼠标相应事件=======================================*/
		private function btnStart(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_START));
		}

		private function btnOutCard(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_OUT_CARD, 1, 1));
		}

		private function btnPassCard(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_PASS_CARD, 1, 1));
		}

		private function btnOneScore(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_LAND_SCORE, 1, 1));
		}

		private function btnTwoScore(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_LAND_SCORE, 2, 2));
		}

		private function btnThreeScore(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_LAND_SCORE, 3, 3));
		}

		private function btnGiveUpScore(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_LAND_SCORE, 255, 255));
		}

		private function btnAutoOutCard(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_AUTO_OUTCARD, 0, 0));
		}

		private function btnSortCard(evt:MouseEvent):void
		{
			//扑克排序方法
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SORT_CARD));

		}
		
		/**
		 * 显示上轮扑克
		 * @param evt
		 */
		private function OnLastTurnCard(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_LAST_TURN_CARD, 0, 0));
		}
		/**
		 * 电脑托管
		 * @param e
		 */
		private function OnEventConcealCard(e:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_TRUSTEE_CONTROL,0,0));
		}

		/*========================================================================*/ 
		/*=====================私有方法 工具方法===================================*/
		private function setLookSkin(ui:UIComponent, styleName:String):void
		{
			ui.setStyle("skin", MaterialLib.getInstance().getClass(styleName));
		}

		private function setLookBg(ui:UIComponent, styleName:String):void
		{
			ui.setStyle("backgroundImage", MaterialLib.getInstance().getClass(styleName));
		}

		private function UpdateScopeView(wChairID:uint):void
		{
			if (m_bScore[wChairID] != 0)
			{
				if (m_pScoreView[wChairID] == null)
				{
					switch (m_bScore[wChairID])
					{
						case 1:
							m_pScoreView[wChairID]=MaterialLib.getInstance().getMaterial("oneScoreView")
							break;
						case 2:
							m_pScoreView[wChairID]=MaterialLib.getInstance().getMaterial("twoScoreView")
							break;
						case 3:
							m_pScoreView[wChairID]=MaterialLib.getInstance().getMaterial("threeScoreView")
							break;
						default:
							m_pScoreView[wChairID]=MaterialLib.getInstance().getMaterial("giveUpView")
							break;
					}
					if (m_pScoreView[wChairID] != null)
					{
						var socreView:UIMovieClip=(m_pScoreView[wChairID]) as UIMovieClip;
						switch (wChairID)
						{
							case 1:
								viewComponent.readyOwnerBox.addChild(socreView);
								break;
							case 0:
								viewComponent.readyLeftBox.addChild(socreView);
								break;
							case 2:
								viewComponent.readyRightBox.addChild(socreView);
								break;
							default:
								break;
						}


					}
				}
			}
			else
			{
				if (m_pScoreView[wChairID])
				{
					if (viewComponent.readyOwnerBox.numChildren > 0)
					{
						viewComponent.readyOwnerBox.removeAllChildren();
					}
					if (viewComponent.readyLeftBox.numChildren > 0)
					{
						viewComponent.readyLeftBox.removeAllChildren();
					}
					if (viewComponent.readyRightBox.numChildren > 0)
					{
						viewComponent.readyRightBox.removeAllChildren();
					}
					m_pScoreView[wChairID]=null;
				}
			}
		}

		/*======================================================================*/ /*======================实现父类的各种方法=================================*/
		override protected function CreateBG():UIComponent
		{
			return MaterialLib.getInstance().getMaterial("bg") as UIComponent;
		}

		override protected function CreateClockView(wChairID:uint, wTimer:uint):*
		{	
			var clock:* = MaterialLib.getInstance().getMaterial("ClockView");
			switch(wChairID){
				 case 0:
				 	viewComponent.addChild(clock);
				 	clock.x= (viewComponent.leftUserCard.x)+40;
				 	clock.y = (viewComponent.leftUserCard.height)/2+viewComponent.leftUserCard.y;
				 	break;
				 case 1:
				 	viewComponent.addChild(clock);
				 	clock.x= (viewComponent.ownerUserCard.width)/2+viewComponent.ownerUserCard.x-clock.width/2;
				 	clock.y = (viewComponent.ownerUserCard.y);
				 	break;
				 case 2:
				 	viewComponent.addChild(clock);
				 	clock.x= (viewComponent.rightUserCard.x);
				 	clock.y = (viewComponent.rightUserCard.height)/2+viewComponent.rightUserCard.y;
				 	break;
			}
			return clock;
		}

		override protected function CreateUserReadyView(wChairID:uint, pUserItem:tagUserData):*
		{
			var readyClass:Class=MaterialLib.getInstance().getClass("UserReadyView") as Class;
			var ready:*=new readyClass(wChairID);
			switch (wChairID)
			{
				case 0:
					viewComponent.readyLeftBox.addChild(ready);
					break;
				case 1:
					viewComponent.readyOwnerBox.addChild(ready);
					break;
				case 2:
					viewComponent.readyRightBox.addChild(ready);
					break;
			}
			return ready;

		}

		override protected function removeUserReadyView(ready:*):void
		{
			var wChairID:int=ready.pos;
			switch (wChairID)
			{
				case 0:
					viewComponent.readyLeftBox.removeAllChildren();
					break;
				case 1:
					viewComponent.readyOwnerBox.removeAllChildren();
					break;
				case 2:
					viewComponent.readyRightBox.removeAllChildren();
					break;
			}

		}

		override protected function CreateUserFaceView(wChairID:uint, pUserItem:tagUserData):IFaceView
		{
			var face:FaceView=new FaceView(pUserItem.wFaceID, wChairID);
			face.name = "faceView";
			switch (wChairID)
			{
				case 0:
					viewComponent.leftHeadBox.visible = true;
					viewComponent.leftHeadBox.addChild(face);
					viewComponent.leftName.text = pUserItem.szNickName;					
					break;
				case 1:
					viewComponent.ownerHeadBox.addChild(face);
					viewComponent.ownerName.text = pUserItem.szNickName;
					break;
				case 2:
					viewComponent.rightHeadBox.visible = true;
					viewComponent.rightHeadBox.addChild(face);
					viewComponent.rightName.text = pUserItem.szNickName;					
					break;
			}
			return face;
		}

		override protected function removeUserFace(face:IFaceView):void
		{

			var wChairID:int=face.pos;
			switch (wChairID)
			{
				case 0:
					viewComponent.leftHeadBox.removeChild(face.getMovieClip());
					viewComponent.leftName.text = "";
					viewComponent.leftHeadBox.visible = false;
					break;
				case 1:
					viewComponent.ownerHeadBox.removeChild(face.getMovieClip());
					viewComponent.ownerName.text = "";
					
					break;
				case 2:
					viewComponent.rightHeadBox.removeChild(face.getMovieClip());
					viewComponent.rightName.text = "";
					viewComponent.rightHeadBox.visible = false;
					break;
			}
		}

		override public function DestroyGameView():void
		{
			if (m_bFreeChildClassViewData == false)
			{
				removeEvent();
					//m_bFreeChildClassViewData = true;
				viewComponent.removeAllChildren();

			}
			
			super.DestroyGameView();
		}

	}
}