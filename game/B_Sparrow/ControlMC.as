package B_Sparrow
{
	import Application.utils.Memory;
	
	import B_Land.common.MaterialLib;
	
	import B_Sparrow.common.GameLogicDef;
	import B_Sparrow.common.tagGangCardResult;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	
	import org.aswing.ASColor;
	import org.aswing.graphics.Graphics2D;
	import org.aswing.graphics.Pen;
	
	public class ControlMC extends UIComponent
	{
		//位置标识
		public static const ITEM_WIDTH:Number = 90;	//子项宽度
		public static const ITEM_HEIGHT:Number = 46;//子项高度
		public static const CONTROL_WIDTH:Number = 173;	//控制宽度
		public static const CONTROL_HEIGHT:Number = 41;	//控制高度
		
		private static const BUTTON_HEIGHT:Number = 35;
		private static const BUTTON_WIDTH:Number = 35;
		private static const BUTTON_HSPACE:Number = 15;
		
		
		//配置变量
		protected var m_cbActionMask:uint;//类型掩码
		protected var m_cbCenterSparrow:uint;//中心麻将
		protected var m_cbGangSparrow:Array = new Array(5);//杠牌数据
		protected var m_cbPengSparrow:Array = new Array(3);
		protected var m_PointBenchmark:Point = new Point;//基准位置
		
		//状态变量
		protected var m_cbItemCount:uint;//子项数目
		protected var m_cbCurrentItem:uint;//当前子项
		
		//控件变量
		protected var m_btChi:Button;//吃牌按钮
		protected var m_btPeng:Button;//碰牌按钮
		protected var m_btGang:Button;//杠牌按钮
		protected var m_btTing:Button;//听牌按钮
		protected var m_btHu:Button;//胡牌按钮
		
		protected var m_btGiveUp:Button;//放弃按钮
		
		protected var m_nWidth:Number = 0;
		protected var m_nHeight:Number = 0;
		
		protected var m_SparrowResource:SparrowResource;
		
		public function ControlMC(res:SparrowResource)
		{
			initView();
			
			m_SparrowResource = res;
		}
		
		private function initView():void
		{
			m_btChi = new Button();
			m_btChi.width = BUTTON_WIDTH;
			m_btChi.height = BUTTON_HEIGHT;
			m_btChi.x =0;
			m_btChi.setStyle("skin",MaterialLib.getInstance().getClass("Button_Chi"));
			addChild(m_btChi);
			m_btChi.visible  = false;
			
			m_btPeng = new Button();
			m_btPeng.width = BUTTON_WIDTH;
			m_btPeng.height = BUTTON_HEIGHT;
			m_btPeng.x = BUTTON_WIDTH + BUTTON_HSPACE;
			m_btPeng.setStyle("skin",MaterialLib.getInstance().getClass("Button_Peng"));
			addChild(m_btPeng);
			m_btPeng.visible = false;
			
			m_btGang = new Button();
			m_btGang.width = BUTTON_WIDTH;
			m_btGang.height = BUTTON_HEIGHT;
			m_btGang.x = 2*(BUTTON_WIDTH + BUTTON_HSPACE);
			m_btGang.setStyle("skin",MaterialLib.getInstance().getClass("Button_Gang"));
			addChild(m_btGang);
			m_btGang.visible = false;
			
			m_btTing = new Button();
			m_btTing.width = BUTTON_WIDTH;
			m_btTing.height = BUTTON_HEIGHT;
			m_btTing.x = 3*(BUTTON_WIDTH + BUTTON_HSPACE);
			m_btTing.setStyle("skin",MaterialLib.getInstance().getClass("Button_Ting"));
			addChild(m_btTing);
			m_btTing.visible = false;
			
			m_btHu = new Button();
			m_btHu.width = BUTTON_WIDTH;
			m_btHu.height = BUTTON_HEIGHT;
			m_btHu.x = 4*(BUTTON_WIDTH + BUTTON_HSPACE);
			m_btHu.setStyle("skin",MaterialLib.getInstance().getClass("Button_Hu"));
			addChild(m_btHu);
			m_btHu.visible = false;
			
			m_btGiveUp = new Button();
			m_btGiveUp.width = 50;
			m_btGiveUp.height = 27;
			m_btGiveUp.x = m_btGang.x;
			m_btGiveUp.y = m_btGang.y + 50;
			m_btGiveUp.setStyle("skin",MaterialLib.getInstance().getClass("Button_GiveUp"));
			addChild(m_btGiveUp);
			m_btGiveUp.visible = false;
		}
		
		//设置麻将
		public function SetControlInfo(cbCenterSparrow:uint,
										cbActionMask:uint,
										GangSparrowResult:tagGangCardResult):void
		{
			//设置变量
			m_cbItemCount=0;
			m_cbCurrentItem=0xFF;
			m_cbActionMask=cbActionMask;
			m_cbCenterSparrow=cbCenterSparrow;
			
			//杠牌信息
			Memory.ZeroArray(m_cbGangSparrow);
			for(var i:uint = 0; i < GangSparrowResult.cbCardCount;i++)
			{
				m_cbItemCount++;
				m_cbGangSparrow[i]=GangSparrowResult.cbCardData[i];
			}
			
			//计算数目
			var cbItemKind:Array = new Array(GameLogicDef.WIK_LEFT,GameLogicDef.WIK_CENTER,GameLogicDef.WIK_RIGHT,GameLogicDef.WIK_PENG);
			for(var i:uint =0; i < Memory.CountArray(cbItemKind); i++)
			{
				if((m_cbActionMask&cbItemKind[i])!= 0)
				{
					 m_cbItemCount++;
				}
			}
			
			m_btChi.visible = (((cbActionMask&GameLogicDef.WIK_LEFT)||(cbActionMask&GameLogicDef.WIK_CENTER)||(cbActionMask&GameLogicDef.WIK_RIGHT)) ? true : false);
			m_btPeng.visible = ((cbActionMask&GameLogicDef.WIK_PENG) ? true : false);
			m_btGang.visible = ((cbActionMask&GameLogicDef.WIK_GANG) ? true : false);
			//m_btTing.visible = ((cbActionMask&GameLogicDe) ? true : false);
			//控制按钮
			m_btHu.visible = ((cbActionMask&GameLogicDef.WIK_CHI_HU) ? true : false);
			
			return;							
		}
		
		//重画函数
		public function OnPaint(dc:BitmapData, rcClient:Rectangle):void
		{
			//绘画背景
			/* m_ImageControlTop.DrawBitmapData(dc,0,0);
			for (var nImageYPos:Number=m_ImageControlTop.GetHeight();
				nImageYPos<rcClient.height;
				nImageYPos+=m_ImageControlMid.GetHeight())
			{
				m_ImageControlMid.DrawBitmapData(dc,0,nImageYPos);
			}
			m_ImageControlButtom.DrawBitmapData(dc,
				0,rcClient.height-m_ImageControlButtom.GetHeight()); */
		
			//变量定义
			var nYPos:Number=5;
			var cbCurrentItem:uint=0;
			var cbExcursion:Array=new Array(0,1,2);
			var cbItemKind:Array=new Array(GameLogicDef.WIK_LEFT,GameLogicDef.WIK_CENTER,GameLogicDef.WIK_RIGHT,GameLogicDef.WIK_PENG);
		
			//绘画麻将
			for (var i:uint=0;i<Memory.CountArray(cbItemKind);i++)
			{
				if ((m_cbActionMask&cbItemKind[i])!=0)
				{
					//绘画麻将
					for (var j:uint=0;j<3;j++)
					{
						var cbSparrowData:uint=m_cbCenterSparrow;
						if (i<Memory.CountArray(cbExcursion))
						{
							cbSparrowData=m_cbCenterSparrow+j-cbExcursion[i];
						}
						m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(dc,
								cbSparrowData,j*26+12,nYPos+5);
					}
		
					//计算位置
					/* var nXImagePos:uint=0;
					var nItemWidth:Number=m_ImageActionExplain.GetWidth()/7;
					if ((m_cbActionMask&cbItemKind[i])&GameLogicDef.WIK_PENG)
						nXImagePos=nItemWidth; */
		
					//绘画标志
					/* var nItemHeight:Number=m_ImageActionExplain.GetHeight();
					m_ImageActionExplain.DrawBitmapData(dc,
														126,
														nYPos+5,
														nXImagePos,
														0,
														nItemWidth,
														nItemHeight); */
		
					//绘画边框
					if (cbCurrentItem==m_cbCurrentItem)
					{
						var s:Shape = new Shape;
						var g:Graphics2D = new Graphics2D(s.graphics);
						var pen:Pen = new Pen(new ASColor(0xffff00ff), 2);
						g.drawRectangle(pen,
										7, nYPos, rcClient.width-14,
									  	ITEM_HEIGHT);
						dc.draw(s);
						g = null;
						pen=null;
						s = null;
					}
		
					//设置变量
					++cbCurrentItem;
					nYPos+=ITEM_HEIGHT;
				}
			}
		
			//杠牌麻将
			for (var i:uint=0;i<Memory.CountArray(m_cbGangSparrow);i++)
			{
				if (m_cbGangSparrow[i]!=0)
				{
					//绘画麻将
					for (var j:uint=0;j<4;j++)
					{
						m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(dc,m_cbGangSparrow[i],j*26+12,nYPos+5);
						//m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(dc,m_cbGangSparrow[i],j*26+12,nYPos+ITEM_HEIGHT+5);
					}
		
					//绘画边框
					if (cbCurrentItem==m_cbCurrentItem)
					{
						var s:Shape = new Shape;
						var g:Graphics2D = new Graphics2D(s.graphics);
						var pen:Pen = new Pen(new ASColor(0xffff00ff), 2);
						g.drawRectangle(pen,
										7,nYPos,
									  	rcClient.width-14,
									  	ITEM_HEIGHT);
						dc.draw(s);
						g = null;
						pen=null;
						s = null;
						
					}
		
					//绘画标志
					/* var nItemWidth:Number=m_ImageActionExplain.GetWidth()/7;
					var nItemHeight:Number=m_ImageActionExplain.GetHeight();
					m_ImageActionExplain.DrawBitmapData(dc,
														126,
														nYPos+5,
														nItemWidth*3,
														0,
														nItemWidth,
														nItemHeight); */
		
					//设置变量
					cbCurrentItem++;
					nYPos+=ITEM_HEIGHT;
				}
				else break;
			}
		
		}

	}
}