package B_Sparrow
{
	import Application.model.vo.protocol.room.tagUserData;
	import Application.utils.Memory;
	
	import B_Land.FaceView;
	import B_Land.common.MaterialLib;
	
	import B_Sparrow.common.CMD_Sparrow;
	import B_Sparrow.common.GameLogicDef;
	import B_Sparrow.common.tagOperateInfo;
	
	import common.data.GlobalDef;
	import common.data.gameEvent;
	import common.game.GameBaseClass;
	import common.game.GameBaseView;
	import common.game.SkinImage;
	import common.game.enDirection;
	import common.game.enXCollocateMode;
	import common.game.enYCollocateMode;
	import common.game.interfaces.IChairIDView;
	import common.game.interfaces.IFaceView;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.flash.UIMovieClip;
	
	import org.puremvc.as3.multicore.core.View;


	public class GameView extends GameBaseView
	{

		public var viewComponent:B_Sparrow_View;
		public var _assets:LoaderInfo;

		//标志变量
		protected var m_bOutCard:Boolean; //出牌标志
		protected var m_bWaitOther:Boolean; //等待标志
		protected var m_bHuangZhuang:Boolean; //荒庄标志

		//游戏属性
		protected var m_fCellScore:Number=0; //基础积分
		protected var m_wBankerUser:uint; //庄家用户

		//用户状态
		protected var m_cbCardData:uint; //出牌麻将
		protected var m_wOutSparrowUser:uint; //出牌用户
		protected var m_cbUserAction:Array=new Array(4); //用户动作

		//位置标量
		protected var m_UserFlagPos:Array=new Array(4); //标志位置

		//位图变量
		protected var m_ImageWait:SkinImage; //等待提示
		protected var m_ImageOutSparrow:SkinImage; //出牌提示
		protected var m_ImageUserFlag:SkinImage; //用户标志
		protected var m_ImageUserAction:SkinImage; //用户动作
		protected var m_ImageActionBack:SkinImage; //动作背景
		protected var m_ImageHuangZhuang:SkinImage; //荒庄标志
		protected var m_ImageTitle:SkinImage; //标题位图

		//麻将控件
		//	public var m_HeapSparrow:Array = new Array(2);//堆立麻将
		public var m_UserSparrow:Array=new Array(1); //用户麻将
		public var m_TableSparrow:Array=new Array(2); //桌面麻将
		public var m_WeaveSparrow:Array=new Array(2); //组合麻将
		public var m_DiscardSparrow:Array=new Array(2); //丢弃麻将
		public var m_HandCardControl:SparrowControl; //手上麻将

		//控件变量
		public var m_ControlMC:ControlMC; //控制窗口
		//public var m_ScoreView:ScoreView;//结束窗口

		private var m_SparrowResource:SparrowResource;
		protected var m_DrawBitmapData:BitmapData;

		private var ting_mc_0:UIMovieClip;
		private var ting_mc_1:UIMovieClip;



		private var _chiType:uint;
		private var _tingPaiData:Array=new Array();
		public var m_ScoreView:ScoreView;

		private var _currentGangPai:uint;	
		

		public function GameView(prarentClass:GameBaseClass)
		{
			super(prarentClass);
		}


		override public function InitGameView():Boolean
		{
			if (super.InitGameView() == false)
			{
				return false;
			}

			//这里与源码不同 这里注意
			_assets=m_GameClass.assets;
			MaterialLib.getInstance().push(_assets.applicationDomain);

			viewComponent=new B_Sparrow_View();
			addChild(viewComponent);




			//加载位图
			m_SparrowResource=new SparrowResource;
			m_SparrowResource.NewResource();

			//用户麻将			
			m_SparrowResource.m_ImageUserTop.Load(MaterialLib.getInstance().getClass("IMAGE_SPARROW_USER_TOP"), 26, 37);
			m_SparrowResource.m_ImageUserBottom.LoadResource(MaterialLib.getInstance().getClass("IMAGE_SPARROW_USER_BOTTOM"), 1806, 60, 42, 60);

			//桌子麻将
			m_SparrowResource.m_ImageTableTop.LoadResource(MaterialLib.getInstance().getClass("IMAGE_SPARROW_TABLE_TOP"), 1118, 36, 26, 36);
			m_SparrowResource.m_ImageTableBottom.LoadResource(MaterialLib.getInstance().getClass("IMAGE_SPARROW_TABLE_BOTTOM"), 1118, 36, 26, 36);



			for (i=0; i < m_UserSparrow.length; i++)
			{
				m_UserSparrow[i]=new UserSparrow(m_SparrowResource);
				viewComponent.userSparrow_Box.addChild(m_UserSparrow[i]);
			}

			for (i=0; i < m_TableSparrow.length; i++)
			{
				m_TableSparrow[i]=new TableSparrow(m_SparrowResource);
			}

			for (i=0; i < m_WeaveSparrow.length; i++)
			{
				m_WeaveSparrow[i]=new Array(4);
				for (var j:uint=0; j < m_WeaveSparrow[i].length; j++)
				{
					m_WeaveSparrow[i][j]=new WeaveSparrow(m_SparrowResource);

				}
			}

			for (i=0; i < m_DiscardSparrow.length; i++)
			{
				m_DiscardSparrow[i]=new DiscardSparrow(m_SparrowResource);
				switch (i)
				{
					case 0:
						viewComponent.disCardSparrow_top_box.addChild(m_DiscardSparrow[i])
						break;
					case 1:
						viewComponent.disCardSparrow_bottom_box.addChild(m_DiscardSparrow[i]);
						break;
				}
			}

			m_HandCardControl=new SparrowControl(m_SparrowResource);
			viewComponent.ownerSparrow_Box.addChild(m_HandCardControl);
			//m_ScoreView = new ScoreView(m_SparrowResource);
			//addChild(m_ScoreView);

			for (i=0; i < m_UserFlagPos.length; i++)
			{
				m_UserFlagPos[i]=new Point;
			}



			//标志变量
			m_bOutCard=false;
			m_bWaitOther=false;
			m_bHuangZhuang=false;

			//游戏属性
			m_fCellScore=0;
			m_wBankerUser=GlobalDef.INVALID_CHAIR;

			//用户状态
			m_cbCardData=0;
			m_wOutSparrowUser=GlobalDef.INVALID_CHAIR;
			Memory.ZeroArray(m_cbUserAction);

			//变量定义
			var Direction:Array=new Array(enDirection.Direction_North, enDirection.Direction_South);

			//设置控件
			for (var i:uint=0; i < 2; i++)
			{
				//m_TableSparrow[i].SetDirection(Direction[i]);
				m_DiscardSparrow[i].SetDirection(Direction[i]);
				//用户麻将
				//m_HeapSparrow[i].SetDirection(Direction[i]);

				for (var j:uint=0; j < 4; j++)
				{
					//组合麻将				
					m_WeaveSparrow[i][j].SetDisplayItem(true);
					m_WeaveSparrow[i][j].SetDirection(Direction[i]);
					if (i == 0)
					{
						m_WeaveSparrow[i][j].x=viewComponent.userSparrow_Box.x + viewComponent.userSparrow_Box.width - j * 104;
						m_WeaveSparrow[i][j].y=viewComponent.topHeadBox.y - 25;
					}
					else
					{
						m_WeaveSparrow[i][j].x=viewComponent.ownerHeadBox.x + viewComponent.ownerHeadBox.width + j * 104;
						m_WeaveSparrow[i][j].y=viewComponent.ownerHeadBox.y + 110;
					}
					viewComponent.addChild(m_WeaveSparrow[i][j]);

				}


			}


			//设置控件
			m_ScoreView=new ScoreView(new OverShowSparrow(m_SparrowResource));
			viewComponent.addChild(m_ScoreView);
			m_ScoreView.x=(viewComponent.width - m_ScoreView.width) / 2;
			m_ScoreView.y=(viewComponent.height - m_ScoreView.height) / 2;

			m_ScoreView.showWindow(false);
		 	//m_ScoreView.setFanType(["狗屎运", "特别狗屎运", "相当大的狗屎运","相当大的狗屎运","相当大的狗屎运","相当大的狗屎运"])
			/*m_ScoreView.setSparrowData([0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x01,0x12,0x13,0x14],13,0x22);
			m_ScoreView.setUserScore([{"userName":"luqiang","fan":100,"score":150},{"userName":"luqiang","fan":200,"score":150}]); */
			//界面设置
			//m_btStart.visible = false;


			/**------------------------初始化皮肤-----------------------**/
			setUIStyle(viewComponent, "backgroundImage", "B_Sparrow_bg");
			setUIStyle(viewComponent.topHeadBox, "backgroundImage", "B_Sparrow_Head_Bg");
			setUIStyle(viewComponent.ownerHeadBox, "backgroundImage", "B_Sparrow_Head_Bg");
			setUIStyle(viewComponent.start_Btn, "skin", "B_Sparrow_btn_start");

			setUIStyle(viewComponent.chi_btn, "skin", "B_Sparrow_btn_chi");
			setUIStyle(viewComponent.peng_btn, "skin", "B_Sparrow_btn_peng");
			setUIStyle(viewComponent.gang_btn, "skin", "B_Sparrow_btn_gang");
			setUIStyle(viewComponent.ting_btn, "skin", "B_Sparrow_btn_ting");
			setUIStyle(viewComponent.hu_btn, "skin", "B_Sparrow_btn_hu");
			setUIStyle(viewComponent.giveUp_btn, "skin", "B_Sparrow_btn_giveup");




			m_HandCardControl.SetBenchmarkPos(viewComponent.ownerSparrow_Box.width / 2, 0, enXCollocateMode.enXCenter, enYCollocateMode.enYTop);
			m_UserSparrow[0].SetControlPoint(0, 0);
			m_UserSparrow[0].SetDirection(enDirection.Direction_North);

			m_DiscardSparrow[0].SetControlPoint(234, 72);
			m_DiscardSparrow[1].SetControlPoint(0, 0);
			
			 ting_mc_0 = (MaterialLib.getInstance().getMaterial("Ting_Mc") as UIMovieClip);
			 ting_mc_1 = (MaterialLib.getInstance().getMaterial("Ting_Mc") as UIMovieClip);
			 
			viewComponent.addChild(ting_mc_0);
			viewComponent.addChild(ting_mc_1);
			
			ting_mc_0.x = (viewComponent.topHeadBox.x+ viewComponent.topHeadBox.width)+10;
			ting_mc_0.y = viewComponent.topHeadBox.y+ viewComponent.topHeadBox.width;
			
			ting_mc_1.x = viewComponent.ownerHeadBox.x+viewComponent.ownerHeadBox.width;
			ting_mc_1.y = viewComponent.ownerHeadBox.y - ting_mc_1.height-20;
			
			ting_mc_0.visible = false;
			ting_mc_1.visible = false;
			
			/**------------------------注册各个按钮的鼠标事件-----------------------**/
			addEvent();


			return true;
		}


		override public function DestroyGameView():void
		{
			super.DestroyGameView();
		}

		override protected function CreateClockView(wChairID:uint, wTimer:uint):*
		{

			switch (wChairID)
			{
				case 0:
					var clockClass:Class=MaterialLib.getInstance().getClass("ClockView1") as Class;
					var clock:UIMovieClip=(new clockClass()) as UIMovieClip;
					viewComponent.clockArea.addChild(clock);
					clock.x=0;
					clock.y=0;
					break;
				case 1:
					var clockClass1:Class=MaterialLib.getInstance().getClass("ClockView") as Class;
					var clock:UIMovieClip=(new clockClass1()) as UIMovieClip;
					viewComponent.clockArea.addChild(clock);
					clock.x=0;
					clock.y=0;

					break;
			}

			return clock;

		}


		/**
		 * @function 调整控件
		 */
		override public function RectifyGameView(nWidth:int, nHeight:int):void
		{
			//用户麻将
			//	m_UserSparrow[0].SetControlPoint(nWidth / 2 - 200, 50);
			//	m_HandCardControl.SetBenchmarkPos(nWidth / 2,nHeight - 15,enXCollocateMode.enXCenter,enYCollocateMode.enYBottom);
		}

		override protected function CreateDrawBitmapData():BitmapData
		{
			return null;
		}

		override protected function CreateUserFaceView(wChairID:uint, pUserItem:tagUserData):IFaceView
		{
			var face:FaceView=new FaceView(pUserItem.wFaceID, wChairID);
			face.name = "faceView";
			switch (wChairID)
			{
				case 0:
					viewComponent.topHeadBox.addChild(face);
					viewComponent.userName.text = pUserItem.szNickName;
					break;
				case 1:
					viewComponent.ownerHeadBox.addChild(face);
					viewComponent.ownerName.text = pUserItem.szNickName;
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
					viewComponent.topHeadBox.removeChild(face.getMovieClip());
					viewComponent.userName.text = "";
					break;
				case 1:
					viewComponent.ownerHeadBox.removeChild(face.getMovieClip());
					viewComponent.ownerName.text = "";
					break;
			}
		}

		override protected function removeUserReadyView(ready:*):void
		{
			var wChairID:int=ready.pos;
			switch (wChairID)
			{
				case 0:
					viewComponent.readyTop_Canvas.removeAllChildren();
					
					break;
				case 1:
					viewComponent.readyOwner_Canvas.removeAllChildren();
				
					break;
			}
		}

		override protected function CreateUserChairIDView(wChairID:uint, pUserItem:tagUserData):IChairIDView
		{
			return null;
		}

		override protected function CreateUserReadyView(wChairID:uint, pUserItem:tagUserData):*
		{
			var readyClass:Class=MaterialLib.getInstance().getClass("UserReadyView") as Class;
			var ready:*=new readyClass(wChairID);
			switch (wChairID)
			{
				case 0:
					viewComponent.readyTop_Canvas.addChild(ready);
				
					break;
				case 1:
					viewComponent.readyOwner_Canvas.addChild(ready);
					
					break;
			}
			return ready;
		}

		override public function UpdateGameView():void
		{
			super.UpdateGameView();
			//this.onRender();	
		}

		/**------------------------------------公有方法------------------------------------------**/

		/**
		 * @function 强制调用DrawGameView()方法，绘制麻将
		 */ /* public function CreateMahjong():void
		   {
		   this.onRender();
		 } */

		/**
		 * @function 添加控制按钮事件并转发出游戏事件(GameViewEvent)
		 */
		public function addEvent():void
		{
			viewComponent.start_Btn.addEventListener(MouseEvent.CLICK, onClickStartHandler);
			viewComponent.chi_btn.addEventListener(MouseEvent.CLICK, OnEventChi);
			viewComponent.hu_btn.addEventListener(MouseEvent.CLICK, OnEventChihu);
			viewComponent.giveUp_btn.addEventListener(MouseEvent.CLICK, OnEventGiveup);
			viewComponent.peng_btn.addEventListener(MouseEvent.CLICK, OnEventPeng);
			viewComponent.gang_btn.addEventListener(MouseEvent.CLICK, OnEventGang);
			viewComponent.ting_btn.addEventListener(MouseEvent.CLICK, onEventTing);
			
			viewComponent.topHeadBox.addEventListener(MouseEvent.CLICK,dispatchPros);
			viewComponent.ownerHeadBox.addEventListener(MouseEvent.CLICK,dispatchPros);
			
		}

		/**
		 * @function 移除控制按钮事件
		 */
		public function removeEvent():void
		{
			viewComponent.start_Btn.removeEventListener(MouseEvent.CLICK, onClickStartHandler);
			viewComponent.chi_btn.removeEventListener(MouseEvent.CLICK, OnEventChi);
			viewComponent.hu_btn.removeEventListener(MouseEvent.CLICK, OnEventChihu);
			viewComponent.giveUp_btn.removeEventListener(MouseEvent.CLICK, OnEventGiveup);
			viewComponent.peng_btn.removeEventListener(MouseEvent.CLICK, OnEventPeng);
			viewComponent.gang_btn.removeEventListener(MouseEvent.CLICK, OnEventGang);
			viewComponent.ting_btn.removeEventListener(MouseEvent.CLICK, onEventTing);
			
			viewComponent.topHeadBox.removeEventListener(MouseEvent.CLICK,dispatchPros);
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
		/**
		 * @function 庄家用户
		 */
		public function SetBankerUser(wBankerUser:uint):void
		{
			//设置用户
			if (wBankerUser != m_wBankerUser)
			{
				//设置变量
				m_wBankerUser=wBankerUser;

				//更新界面
				UpdateGameView();
			}
			return;
		}

		/**
		 * @function 状态标志
		 */
		public function SetStatusFlag(bOutSparrow:Boolean, bWaitOther:Boolean):void
		{
			//设置变量
			m_bOutCard=bOutSparrow;
			m_bWaitOther=bWaitOther;

			//更新界面
			UpdateGameView();

			return;
		}

		/**
		 * @function 海底麻将
		 */
		public function SetHuangZhuang(bHuangZhuang:Boolean):void
		{
			//设置麻将
			if (bHuangZhuang != m_bHuangZhuang)
			{
				//设置变量
				m_bHuangZhuang=bHuangZhuang;

				//更新界面
				UpdateGameView();
			}
		}

		/**
		 * @function 出牌信息
		 */
		public function SetOutSparrowInfo(wViewChairID:uint, cbSparrowData:uint):void
		{
			//设置变量
			m_cbCardData=cbSparrowData;
			m_wOutSparrowUser=wViewChairID;

			//更新界面
			UpdateGameView();

			return;
		}

		/**
		 * @function 动作信息
		 */
		public function SetUserAction(wViewChairID:uint, bUserAction:uint):void
		{
			//设置变量
			if (wViewChairID < CMD_Sparrow.GAME_PLAYER)
			{
				m_cbUserAction[wViewChairID]=bUserAction;
			}
			else
			{
				Memory.ZeroArray(m_cbUserAction);
			}

			//更新界面
			UpdateGameView();

			return;
		}



		/**------------------------------------私有方法------------------------------------------**/

		/**
		 * @function 控制组件鼠标游戏事件转发
		 */
		private function OnEventControlMC(event:GameViewEvent):void
		{
			dispatchEvent(event.cloneEvent());
		}


		/**
		 * @function 给控件设置样式
		 * @ui	将要应用样式(style)的控件
		 * @style 要应用在(ui)控件上的样式
		 * @styleName 要应用在(ui)控件上的样式的值
		 */

		private function setUIStyle(ui:UIComponent=null, style:String="", styleName:Object=null):void
		{
			if (ui == null && style == "" && styleName == null)
			{
				return;
			}

			ui.setStyle(style, MaterialLib.getInstance().getClass(styleName.toString()));
		}

		/*=====================控制按钮事件=======================================*
		   /**
		 * 控制事件处理
		 */
		private function onClickChiHandler(event:MouseEvent):void
		{
			//dispatchEvent(new GameViewEvent());	
		}

		//	庄家准备
		private function onClickStartHandler(event:MouseEvent):void
		{
			ting_mc_0.visible = false;
			ting_mc_1.visible = false;
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_START));

		}

		//	玩家准备
		private function onTopStart(event:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_START));
		}

		/**
		 *	 吃胡事件
		 * @param evt
		 *
		 */
		private function OnEventChihu(evt:MouseEvent = null):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, GameLogicDef.WIK_CHI_HU, 0));
			showControlMc(false);
		}

		/**
		 *  放弃事件
		 * @param evt
		 *
		 */
		private function OnEventGiveup(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, GameLogicDef.WIK_NULL, 0));
			m_HandCardControl.allShootFalse();
			showControlMc(false);
		}

		/**
		 *	碰牌事件
		 * @param evt
		 *
		 */
		private function OnEventPeng(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, GameLogicDef.WIK_PENG, m_cbCardData));
			showControlMc(false);
		}

		/**
		 *	杠牌事件
		 * @param evt
		 *
		 */
		private function OnEventGang(evt:MouseEvent):void
		{
			dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, GameLogicDef.WIK_GANG, _currentGangPai));
			showControlMc(false);
		}

		private function OnEventChi(evt:MouseEvent):void
		{
			analyseChiHu();
			showControlMc(false);
		}

		private function onEventTing(evt:MouseEvent):void
		{
			analyseTing();
			showControlMc(false);
		}

		/*==================================================================*/
		//============================控制面板接口============================//

		/**
		 *	控制面板控制接口
		 * @param type 传入的具体操作类型
		 *
		 */
		public function controlMc(type:uint, centerValue:Array, isTing:Boolean):void
		{
			if (!isTing)
			{


				for each (var i:tagOperateInfo in centerValue)
				{
					switch (i.cbOperateCode)
					{
						case GameLogicDef.WIK_CHI_HU:
							viewComponent.hu_btn.enabled=true;
							break;
						case GameLogicDef.WIK_DANCE:
							viewComponent.ting_btn.enabled=true;
							break;
						case GameLogicDef.WIK_GANG:
							viewComponent.gang_btn.enabled=true;
							_currentGangPai=i.cbOperateSparrow[0];
							break;
						case (type & (GameLogicDef.WIK_LEFT | GameLogicDef.WIK_CENTER | GameLogicDef.WIK_RIGHT)):
							viewComponent.chi_btn.enabled=true;
							_chiType=type;
							break;
						case GameLogicDef.WIK_PENG:
							viewComponent.peng_btn.enabled=true;
							break;
						case GameLogicDef.WIK_LISTEN:
							viewComponent.ting_btn.enabled=true;
							//有数据
							_tingPaiData=i.cbOperateSparrow;
							break;
					}
					if (type > 0)
					{
						showControlMc();
					}
				}
			}else
			{
				if((type&GameLogicDef.WIK_CHI_HU)==GameLogicDef.WIK_CHI_HU)
				{
							viewComponent.hu_btn.enabled=true;
							showControlMc();

				}
				
			}

		}

		private function analyseTing():void
		{
			m_HandCardControl.setTingSparrow(_tingPaiData);
		}


		/**
		 * 显示控制区
		 * 最后可能会加上动画效果
		 * @param vis 是否显示参数
		 *
		 */
		public function showControlMc(vis:Boolean=true):void
		{
			viewComponent.controlPane.visible=vis;
			
			if (!vis)
			{
				
				viewComponent.chi_btn.enabled=false;
				viewComponent.peng_btn.enabled=false;
				viewComponent.gang_btn.enabled=false;
				viewComponent.hu_btn.enabled=false;
				viewComponent.ting_btn.enabled=false;
				
			}

		}

		/**
		 *	分系吃胡判断是否是左吃 中吃 右吃
		 *
		 *
		 */
		private function analyseChiHu():void
		{
			var weavArr:Array=new Array(0, 0, 0, 0, 0);

			if (_chiType & GameLogicDef.WIK_LEFT)
			{
				weavArr[3]=m_cbCardData + 1;
				weavArr[4]=m_cbCardData + 2;
			}
			if (_chiType & GameLogicDef.WIK_CENTER)
			{
				weavArr[1]=m_cbCardData - 1;
				weavArr[3]=m_cbCardData + 1;
			}
			if (_chiType & GameLogicDef.WIK_RIGHT)
			{
				weavArr[1]=m_cbCardData - 1;
				weavArr[0]=m_cbCardData - 2;
			}
			m_HandCardControl.setChiSparrowData(weavArr, _chiType, m_cbCardData);
		}

		private function overMotion(evt:Event):void
		{
			(evt.target as UIMovieClip).removeEventListener("B_Sparrow_Over", overMotion);
			 viewComponent.removeChild((evt.target) as UIMovieClip);
		}

		/**
		 * 吃牌动画
		 *
		 */
		public function showChiMonition():void
		{
			var bomb:*=(MaterialLib.getInstance().getMaterial("B_Sparrow_chi_moition"));
			bomb.x=viewComponent.clockArea.x;
			bomb.y=viewComponent.clockArea.y;
			viewComponent.addChild(bomb);
			bomb.addEventListener("B_Sparrow_Over", overMotion, false, 0, true);
		}

		/**
		 *	点炮动画
		 *
		 */
		public function showDianPaoMonition():void
		{
			var bomb:*=(MaterialLib.getInstance().getMaterial("B_Sparrow_dianpao"));
			bomb.x=viewComponent.clockArea.x;
			bomb.y=viewComponent.clockArea.y;
			viewComponent.addChild(bomb);
			bomb.addEventListener("B_Sparrow_Over", overMotion, false, 0, true);
		}

		/**
		 *	碰牌动画
		 *
		 */
		public function showPengMonition():void
		{
			var bomb:*=(MaterialLib.getInstance().getMaterial("B_Sparrow_peng_moition"));
			bomb.x=viewComponent.clockArea.x;
			bomb.y=viewComponent.clockArea.y;
			viewComponent.addChild(bomb);
			bomb.addEventListener("B_Sparrow_Over", overMotion, false, 0, true);
		}

		/**
		 *	自摸动画
		 *
		 */
		public function showZiMoMonition():void
		{
			var bomb:*=(MaterialLib.getInstance().getMaterial("B_Sparrow_zimo"));
			bomb.x=viewComponent.clockArea.x;
			bomb.y=viewComponent.clockArea.y;
			viewComponent.addChild(bomb);
			bomb.addEventListener("B_Sparrow_Over", overMotion, false, 0, true);
		}
		/**
		 *	流局动画 
		 * 
		 */
		public function drawMonition():void{
			var bomb:* = (MaterialLib.getInstance().getMaterial("draw_moition"));
			bomb.x=viewComponent.clockArea.x;
			bomb.y=viewComponent.clockArea.y;
			viewComponent.addChild(bomb);
			bomb.addEventListener("B_Sparrow_Over", overMotion, false, 0, true);
		}
		public function setTing(chairId:int,isTing:Boolean):void
		{
		   if(isTing){
		   	  if(chairId==0&&ting_mc_0.visible==false){
				ting_mc_0.visible= true;
			  }else if(chairId==1&&ting_mc_1.visible==false)
			  {
				ting_mc_1.visible = true;
			  }	
		   }	

		}
	}
}