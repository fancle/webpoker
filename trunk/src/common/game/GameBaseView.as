package common.game
{
	import Application.model.interfaces.IGameView;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	import common.game.interfaces.IChairIDView;
	import common.game.interfaces.IClockView;
	import common.game.interfaces.IFaceView;
	import common.game.vo.TagServerAttribute;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.flash.UIMovieClip;

	/**
	 *
	 * @author Administrator
	 */
	public class GameBaseView extends UIComponent implements IGameView
	{


		/**
		 *
		 * @default
		 */
		public static var nGameUIWidth:uint=758;
		/**
		 *
		 * @default
		 */
		public static var nGameUIHeight:uint=595;

		/**
		 *
		 * @default
		 */
		protected var m_bInitGameView:Boolean; //界面是否初始化
		/**
		 *
		 * @default
		 */
		protected var m_bFreeChildClassViewData:Boolean;

		/**
		 *
		 * @default
		 */
		protected var m_nXFace:int; //头像高度
		/**
		 *
		 * @default
		 */
		protected var m_nYFace:int; //头像宽度
		/**
		 *
		 * @default
		 */
		protected var m_nXReady:int; //准备宽
		/**
		 *
		 * @default
		 */
		protected var m_nYReady:int; //准备高
		/**
		 *
		 * @default
		 */
		protected var m_nXTimer:int; //定时器宽
		/**
		 *
		 * @default
		 */
		protected var m_nYTimer:int; //定时器高
		/**
		 *
		 * @default
		 */
		protected var m_nXBorder:int; //框架宽度
		/**
		 *
		 * @default
		 */
		protected var m_nYBorder:int; //框架高度

		/**
		 *
		 * @default
		 */
		protected var m_GameClass:GameBaseClass;
		//用户变量
		/**
		 *
		 * @default
		 */
		protected var m_wTimer:Array=new Array(GlobalDef.MAX_CHAIR); //用户时间
		/**
		 *
		 * @default
		 */
		protected var m_pUserItem:Array=new Array(GlobalDef.MAX_CHAIR); //用户信息

		/**
		 *
		 * @default
		 */
		protected var m_pUserFace:Array=new Array(GlobalDef.MAX_CHAIR); //用户头像
		/**
		 *
		 * @default
		 */
		protected var m_ptFace:Array=new Array(GlobalDef.MAX_CHAIR); //头像位置

		/**
		 *
		 * @default
		 */
		protected var m_pUserChairIDView:Array=new Array(GlobalDef.MAX_CHAIR); //名字
		/**
		 *
		 * @default
		 */
		protected var m_ptName:Array=new Array(GlobalDef.MAX_CHAIR); //名字位置

		/**
		 *
		 * @default
		 */
		protected var m_pClockView:Array=new Array(GlobalDef.MAX_CHAIR);
		/**
		 *
		 * @default
		 */
		protected var m_ptTimer:Array=new Array(GlobalDef.MAX_CHAIR); //时间位置

		/**
		 *
		 * @default
		 */
		protected var m_pUserReadyView:Array=new Array(GlobalDef.MAX_CHAIR);
		/**
		 *
		 * @default
		 */
		protected var m_ptReady:Array=new Array(GlobalDef.MAX_CHAIR); //准备位置


		
		/**
		 *
		 * @param prarentClass
		 */
		public function GameBaseView(prarentClass:GameBaseClass)
		{
			super();
			m_GameClass=prarentClass;
			m_bInitGameView=false;
			m_bFreeChildClassViewData=false;
			this.addEventListener(FlexEvent.INITIALIZE, init);			
		}

		/**
		 *
		 * @param evt
		 */
		public function init(evt:FlexEvent=null):void
		{

		}

		//================== 实现IGameView接口===============//

		/**
		 *
		 * @return 游戏初始化接口
		 */

		public function InitGameView():Boolean
		{
			if (m_bInitGameView)
			{
				return true;
			}
			for (var i:int=0; i < GlobalDef.MAX_CHAIR; i++)
			{
				m_ptName[i]=new Point;
				m_ptFace[i]=new Point;
				m_ptTimer[i]=new Point;
				m_ptReady[i]=new Point;
			}
	

			return true;
		}
		


		/**
		 * 退出游戏销毁视图
		 */
		public function DestroyGameView():void
		{
			if (m_bInitGameView == false)
			{
				return;
			}
			Memory.ZeroArray(m_pUserFace, null, removeUserFace);
			m_pUserFace=null;
			Memory.ZeroArray(m_pUserChairIDView, null, removeUserChairIDView);
			m_pUserChairIDView=null;
			Memory.ZeroArray(m_pUserReadyView, null, removeUserReadyView);
			m_pUserReadyView=null;
			Memory.ZeroArray(m_pClockView, null, removeClockView);
			m_pClockView=null;
			Memory.ZeroArray(m_wTimer);
			m_wTimer=null;

			Memory.ZeroArray(m_ptName, null);
			m_ptName=null;
			Memory.ZeroArray(m_ptFace, null);
			m_ptFace=null;
			Memory.ZeroArray(m_ptTimer, null);
			m_ptTimer=null;
			Memory.ZeroArray(m_ptReady, null);
			m_ptReady=null;
			Memory.ZeroArray(m_pUserItem, null);
			m_pUserItem=null;

			m_GameClass=null;
		}

		/**
		 *
		 * @return 获取游戏视图
		 */
		public function GetGameViewMC():UIComponent
		{
			return this;
		}

		//=====================================================//
		/**
		 *
		 * @param nWidth
		 * @param nHeight
		 */
		public function RectifyGameView(nWidth:int, nHeight:int):void
		{

		}

		//=================待定的借口 子类去实现的===============//
		protected function CreateUserFaceView(wChairID:uint, pUserItem:tagUserData):IFaceView
		{
			return null;
		}

		protected function CreateUserChairIDView(wChairID:uint, pUserItem:tagUserData):IChairIDView
		{
			return null;
		}

		protected function CreateUserReadyView(wChairID:uint, pUserItem:tagUserData):*
		{
			return null;
		}

		protected function CreateClockView(wChairID:uint, wTimer:uint):*
		{
			return null;
		}

		protected function CreateBG():UIComponent
		{
			return null;
		}
		
		protected function CreateDrawBitmapData():BitmapData
		{
			return null;
		}

		protected function GetUserFaceMCIndex(wChairID:uint):int
		{
			return -1;
		}
		public function GetUserFaceCoordinate(userID:uint):Point
		{
			var chairID:int = -1;
			
			for(var i:int = 0; i<m_pUserItem.length; i++){
				if(!m_pUserItem[i]) continue;
				if((m_pUserItem[i] as tagUserData).dwUserID == userID){
					chairID = i;
					break;
				}					
			}
			
			if(chairID==-1)return null;
			
			var face:DisplayObject = m_pUserFace[chairID] as DisplayObject;
			return face.localToGlobal(new Point(face.x,face.y));
		}
		protected function DrawGameView(g:Graphics = null, pDC:BitmapData = null):void
		{

		}

		//====================================================//


		//=============private 实现的方法=======================//
		/**
		 *
		 * @param face  玩家头像 删除头像
		 */
		protected function removeUserFace(face:IFaceView):void
		{
			if (face)
			{
				var faceMc:UIComponent=face.getMovieClip();
				if (faceMc)
				{
					removeChild(faceMc);
					faceMc=null;
				}
				face.destroy();
				face=null;
			}
		}

		/**
		 *
		 * @param view 删除用户座椅？？？有疑问
		 */
		private function removeUserChairIDView(view:IChairIDView):void
		{
			if (view)
			{
				var viewMC:UIComponent=view.getMovieClip();
				if (viewMC)
				{
					removeChild(viewMC);
					viewMC=null;
				}
				view.destroy();
				view=null;
			}

		}

		/**
		 *
		 * @param view  删除用户椅子状态
		 */
		protected function removeUserReadyView(view:*):void
		{
			if (view)
			{
				var viewMC:UIMovieClip=view.getMovieClip();
				if (viewMC)
				{
					removeChild(viewMC);
					viewMC=null;
				}
				view.destroy();
				view=null;
			}
		}

		/**
		 *
		 * @param view  删除用户时间显示
		 */
		private function removeClockView(view:IClockView):void
		{
			if (view)
			{
				var viewMC:UIMovieClip=view.getMovieClip();
				if (viewMC)
				{
					removeChild(viewMC);
					viewMC=null;
				}
				view.destroy();
				view=null;
			}
		}

		/**
		 * 更新出牌时间
		 * @param wChairID  椅子号
		 * @param wTimer    时间
		 */
		private function UpdateClockView(wChairID:uint, wTimer:uint):void
		{
			if (m_pClockView[wChairID])
			{
				m_pClockView[wChairID].setSecond(wTimer);
			}
		}

		/**
		 * 比较两个玩家信息是否是一个用户
		 * @param pUserItem0 传入用户信息
		 * @param pUserItem1 传入用户信息
		 * @return  相同返回true 不同返回false
		 */
		private function equalUserItem(pUserItem0:tagUserData, pUserItem1:tagUserData):Boolean
		{
			if (pUserItem0 == pUserItem1)
			{
				return true;
			}
			if (pUserItem0 == null && pUserItem1 != null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 == null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 != null)
			{
				if (pUserItem0.dwUserID != pUserItem1.dwUserID)
				{
					return false;
				}
			}

			return true;
		}

		/**
		 * 更新玩家头像
		 * @param wChairID  传入椅子号
		 * @param pUserItem 传入玩家信息
		 */
		private function UpdateUserFaceView(wChairID:uint, pUserItem:tagUserData):void
		{
			if (equalUserItem(m_pUserItem[wChairID], pUserItem) == false)
			{
				
				if (m_pUserFace[wChairID])
				{					
					removeUserFace(m_pUserFace[wChairID]);
					m_pUserFace[wChairID]=null;
				}
			}
			if (pUserItem != null && m_pUserFace[wChairID] == null)
			{
				m_pUserFace[wChairID]=CreateUserFaceView(wChairID, pUserItem);
/*   				if (m_pUserFace[wChairID])
				{
					var mc:UIComponent=m_pUserFace[wChairID].getMovieClip();
					if (mc)
					{
						var nMCIndex:int=GetUserFaceMCIndex(wChairID);
						if (nMCIndex == -1)
							addChild(mc);
						else
							addChildAt(mc, nMCIndex);
						m_pUserFace[wChairID].moveMovieClip(m_ptFace[wChairID].x, m_ptFace[wChairID].y);
					}
				} */  

			}
/*   			if (pUserItem && m_pUserFace[wChairID])
			{
				m_pUserFace[wChairID].setOffLine(pUserItem.cbUserStatus == GlobalDef.US_OFFLINE);
			}  */ 
		}

		/**
		 * 判断椅子 是否相同
		 * @param pUserItem0
		 * @param pUserItem1
		 * @return 
		 */
		private function equalUserChairIDView(pUserItem0:tagUserData, pUserItem1:tagUserData):Boolean
		{
			if (pUserItem0 == pUserItem1)
			{
				return true;
			}
			if (pUserItem0 == null && pUserItem1 != null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 == null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 != null)
			{
				if (pUserItem0.dwUserID != pUserItem1.dwUserID)
				{
					return false;
				}
			}

			return true;
		}

		/**
		 * 更新 椅子视图？？？
		 * @param wChairID
		 * @param pUserItem
		 */
		private function UpdateChairIDView(wChairID:uint, pUserItem:tagUserData):void
		{
			if (equalUserChairIDView(m_pUserItem[wChairID], pUserItem) == false)
			{
				if (m_pUserChairIDView[wChairID])
				{
					removeUserChairIDView(m_pUserChairIDView[wChairID]);
					m_pUserChairIDView[wChairID]=null;
				}
			}

			if (pUserItem != null && m_pUserChairIDView[wChairID] == null)
			{
				m_pUserChairIDView[wChairID]=CreateUserChairIDView(wChairID, pUserItem);
				if (m_pUserChairIDView[wChairID])
				{
					var mc:UIComponent=m_pUserChairIDView[wChairID].getMovieClip();
					if (mc)
					{
						addChild(mc);
						m_pUserChairIDView[wChairID].moveMovieClip(m_ptName[wChairID].x, m_ptName[wChairID].y);
					}
				}
			}
			if (pUserItem && m_pUserChairIDView[wChairID])
			{
				m_pUserChairIDView[wChairID].setOffLine(pUserItem.cbUserStatus == GlobalDef.US_OFFLINE);
			}
		}

		/**
		 * 判断是否准备状态是否是一个人
		 * @param pUserItem0
		 * @param pUserItem1
		 * @return 
		 */
		private function equalUserReadyView(pUserItem0:tagUserData, pUserItem1:tagUserData):Boolean
		{
			if (pUserItem0 == pUserItem1)
			{
				return true;
			}
			if (pUserItem0 == null && pUserItem1 != null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 == null)
			{
				return false;
			}
			if (pUserItem0 != null && pUserItem1 != null)
			{
				if (pUserItem0.dwUserID != pUserItem1.dwUserID)
				{
					return false;
				}
				if (pUserItem0.cbUserStatus != pUserItem1.cbUserStatus)
				{
					return false;
				}
			}

			return true;
		}

		/**
		 * 更行准备视图
		 * @param wChairID
		 * @param pUserItem
		 */
		private function UpdateUserReadyView(wChairID:uint, pUserItem:tagUserData):void
		{
			if (equalUserReadyView(m_pUserItem[wChairID], pUserItem) == false || (pUserItem != null && pUserItem.cbUserStatus != GlobalDef.US_READY))
			{
				if (m_pUserReadyView[wChairID])
				{
					removeUserReadyView(m_pUserReadyView[wChairID]);
					m_pUserReadyView[wChairID]=null;
				}
			}
			if (pUserItem != null && pUserItem.cbUserStatus == GlobalDef.US_READY)
			{
				if (m_pUserReadyView[wChairID] == null)
				{				
					
					m_pUserReadyView[wChairID]=CreateUserReadyView(wChairID, pUserItem);				
/*  				if (m_pUserReadyView[wChairID])
					{
						var mc:UIMovieClip=m_pUserReadyView[wChairID].getMovieClip();
						if (mc)
						{
							addChild(mc);
							m_pUserReadyView[wChairID].moveMovieClip(m_ptReady[wChairID].x, m_ptReady[wChairID].y);
						}
					}  */
				}
			}
		}

		//====================================================//

		///////////////////////
		//功能函数
		//获取时间
		/**
		 *
		 * @param wChairID 座椅编号
		 * @return 用户时间
		 */
		public function GetUserTimer(wChairID:uint):uint
		{
			if (wChairID >= GlobalDef.MAX_CHAIR)
			{
				return 0;
			}
			return m_wTimer[wChairID];
		}

		/**
		 * 设置用户出牌时间
		 * @param wChairID  椅子号
		 * @param wTimer    时间
		 * @return
		 */
		public function SetUserTimer(wChairID:uint, wTimer:uint):Boolean
		{
			if (wChairID >= GlobalDef.MAX_CHAIR)
			{
				return false;
			}
			m_wTimer[wChairID]=wTimer;
			if (m_pClockView[wChairID] == null)
			{
				m_pClockView[wChairID]=CreateClockView(wChairID, wTimer);
				/*if (m_pClockView[wChairID])
				{
					var mc:UIComponent=m_pClockView[wChairID].getMovieClip();
					if (mc)
					{
						addChild(mc);
						m_pClockView[wChairID].moveMovieClip(m_ptTimer[wChairID].x, m_ptTimer[wChairID].y);
					}
				}*/
			}
			UpdateClockView(wChairID, wTimer);
			return true;
		}

		//设置用户
		/**
		 * 设置用户信息
		 * @param wChairID
		 * @param pUserItem
		 * @return 
		 */
		public function SetUserInfo(wChairID:uint, pUserItem:tagUserData):Boolean
		{
			if (wChairID >= GlobalDef.MAX_CHAIR)
			{
				return false;
			}

			UpdateUserFaceView(wChairID, pUserItem);
			UpdateChairIDView(wChairID, pUserItem);
			UpdateUserReadyView(wChairID, pUserItem);

			m_pUserItem[wChairID]=pUserItem;

			UpdateGameView();//
			return true;
		}
	   //更新游戏视图
		public function UpdateGameView():void
		{
            this.validateNow();
		}
				//更新界面
		public function  SetUserStatus(wChairID:uint,pUserData:tagUserData):void
		{
			UpdateUserReadyView(wChairID,pUserData);
			UpdateUserFaceView(wChairID,pUserData);
			UpdateChairIDView(wChairID,pUserData);
		}
		//更新游戏属性
		public function UpdateServerAttribute(attr:TagServerAttribute):void
		{
		}
	}
}