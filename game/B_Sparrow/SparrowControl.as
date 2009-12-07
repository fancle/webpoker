package B_Sparrow
{
	import Application.utils.Memory;

	import B_Sparrow.common.GameLogicDef;

	import common.game.enXCollocateMode;
	import common.game.enYCollocateMode;

	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import mx.core.UIComponent;

	import org.aswing.graphics.BitmapBrush;
	import org.aswing.graphics.Graphics2D;

	//麻将控件
	public class SparrowControl extends UIComponent
	{
		//麻将大小
		public static var SPARROW_WIDTH:uint=42; //麻将宽度
		public static var SPARROW_HEIGHT:uint=65; //麻将高度



		//公共定义
		public static var POS_SHOOT:uint=5; //弹起象素
		public static var POS_SPACE:uint=8; //分隔间隔
		public static var ITEM_COUNT:uint=43; //子项数目
		public static var INVALID_ITEM:uint=0xFFFF; //无效索引

		//状态变量
		protected var m_bPositively:Boolean; //响应标志
		protected var m_bDisplayItem:Boolean; //显示标志

		//位置变量
		protected var m_BenchmarkPos:Point=new Point(); //基准位置
		protected var m_XCollocateMode:uint; //显示模式
		protected var m_YCollocateMode:uint; //显示模式

		//麻将数据
		protected var m_wSparrowCount:uint; //麻将数目
		protected var m_wHoverItem:uint; //盘旋子项
		protected var m_CurrentSparrow:tagSparrowItem=new tagSparrowItem; //当前麻将
		protected var m_SparrowItemArray:Array=new Array(13); //麻将数据

		//资源变量
		protected var m_ControlSize:Point=new Point; //控件大小
		protected var m_ControlPoint:Point=new Point; //控件位置

		protected var m_SparrowResource:SparrowResource;

		private var cTransform:ColorTransform=new ColorTransform(0.5, 0.5, 0.5, 1, 0, 0, 0, 0);
		private var chi_Arry:Array=new Array();

		private var _status:uint; //0 就是一般状态 1为吃牌转台 2为听牌状态
		private var _chiType:uint;
		private var _sendChiType:uint; //发送的吃牌类型
		private var _centerSparrow:uint //要被吃的牌
		private var isShow:Boolean=false;
		private var showData:Array=new Array();
		private var m_center:uint;
		private var _tingCenter:uint;
		private var _tingArrayData:Array=new Array();

		public function SparrowControl(res:SparrowResource)
		{
			m_SparrowResource=res;

			for (var i:uint=0; i < m_SparrowItemArray.length; i++)
			{
				m_SparrowItemArray[i]=new tagSparrowItem();
			}

			//状态变量
			m_bPositively=false;
			m_bDisplayItem=false;

			//位置变量
			m_XCollocateMode=enXCollocateMode.enXCenter;
			m_YCollocateMode=enYCollocateMode.enYCenter;

			//麻将数据
			m_wSparrowCount=0;
			m_wHoverItem=INVALID_ITEM;

			//加载设置
			m_ControlSize.y=SPARROW_HEIGHT + POS_SHOOT;
			m_ControlSize.x=(Memory.CountArray(m_SparrowItemArray) + 1) * SPARROW_WIDTH + POS_SPACE;
			addEventListener(MouseEvent.MOUSE_MOVE, OnEventMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onEventMouseOut);
			addEventListener(MouseEvent.CLICK, OnEventClick);
		}

		public function Destroy(data:SparrowControl):void
		{
			if (data)
			{
				data.m_SparrowResource=null;
				data.m_BenchmarkPos=null;
				data.m_CurrentSparrow=null;
				Memory.ZeroArray(data.m_SparrowItemArray, null);

			}
			removeEventListener(MouseEvent.MOUSE_MOVE, OnEventMouseMove);
			removeEventListener(MouseEvent.MOUSE_OUT, onEventMouseOut);
			removeEventListener(MouseEvent.CLICK, OnEventClick);

		}

		//设置响应
		public function SetPositively(bPositively:Boolean):void
		{
			m_bPositively=bPositively;
		}

		//设置显示
		public function SetDisplayItem(bDisplayItem:Boolean):void
		{
			if (m_bDisplayItem == bDisplayItem)
			{
				return;
			}
			m_bDisplayItem=bDisplayItem;
			Invalidate();
		}

		//基准位置
		public function SetBenchmarkPos(nXPos:int, nYPos:int, XCollocateMode:uint, YCollocateMode:int):void
		{
			//设置变量
			m_BenchmarkPos.x=nXPos;
			m_BenchmarkPos.y=nYPos;

			m_XCollocateMode=XCollocateMode;
			m_YCollocateMode=YCollocateMode;

			RectifyControl();

			return;
		}

		//获取麻将
		public function GetHoverSparrow():uint
		{
			//获取麻将
			if (m_wHoverItem != INVALID_ITEM)
			{
				if (m_wHoverItem == Memory.CountArray(m_SparrowItemArray)&&m_CurrentSparrow.isEnable==true)
				{
					return m_CurrentSparrow.cbSparrowData;
				}
				if(m_wHoverItem == Memory.CountArray(m_SparrowItemArray)&&m_CurrentSparrow.isEnable==false)
				{
					return 0;	
				}
				if ((m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).isEnable == false)
				{
					return 0;
				}
				return (m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).cbSparrowData;
			}
			return 0;
		}

		//获取麻将
		public function GetCurrentSparrow():uint
		{
			return m_CurrentSparrow.cbSparrowData;
		}

		//设置麻将
		public function SetCurrentSparrowData(cbSparrowData:uint):Boolean
		{
			//设置变量
			m_CurrentSparrow.bShoot=false;
			m_CurrentSparrow.cbSparrowData=cbSparrowData;


			RectifyControl();
			return true;
		}

		//设置麻将
		public function SetSparrowData(cbSparrowData:Array, wSparrowCount:uint, cbCurrentSparrow:uint):Boolean
		{
			isShow=false;
			//效验大小
			Memory.ASSERT(wSparrowCount <= Memory.CountArray(m_SparrowItemArray));
			if (wSparrowCount > Memory.CountArray(m_SparrowItemArray))
			{
				return false;
			}

			//当前麻将
			m_CurrentSparrow.bShoot=false;
			m_CurrentSparrow.cbSparrowData=cbCurrentSparrow;
			m_CurrentSparrow.isEnable=true;

			//设置麻将
			m_wSparrowCount=wSparrowCount;
			for (var i:uint=0; i < m_wSparrowCount; i++)
			{
				m_SparrowItemArray[i].bShoot=false;
				m_SparrowItemArray[i].cbSparrowData=cbSparrowData[i];
				m_SparrowItemArray[i].isEnable=true;
			}
//			trace("cbSparrowData:"+cbSparrowData);
//			trace("wSparrowCount:"+wSparrowCount);
			RectifyControl();
			return true;
		}

		public function setShowSparrowData(cbSparrowData:Array, wSparrowCount:uint, centerValue:uint):void
		{
			isShow=true;
			m_wSparrowCount=wSparrowCount;
			showData=cbSparrowData;
			m_center=centerValue;
			RectifyControl();
		}

		//设置麻将
		public function SetSparrowItem(SparrowItemArray:Array, wSparrowCount:uint):Boolean
		{
			//效验大小
			Memory.ASSERT(wSparrowCount <= Memory.CountArray(m_SparrowItemArray));
			if (wSparrowCount > Memory.CountArray(m_SparrowItemArray))
			{
				return 0;
			}

			//设置麻将
			m_wSparrowCount=wSparrowCount;
			for (var i:uint=0; i < m_wSparrowCount; i++)
			{
				m_SparrowItemArray[i].bShoot=SparrowItemArray[i].bShoot;
				m_SparrowItemArray[i].cbSparrowData=SparrowItemArray[i].cbSparrowData;
			}

			return true;
		}

		/**
		 * 吃牌重绘
		 *
		 * @param sparrowData 传入的5维数组的参数
		 *
		 */
		public function setChiSparrowData(sparrowData:Array, type:uint, centerSparrow:uint):void
		{
			chi_Arry=sparrowData;
			_status=1;
			_chiType=type;
			_centerSparrow=centerSparrow;
			for each (var k:tagSparrowItem in m_SparrowItemArray)
			{
				(k).isEnable=false;
			}
			for (var i:int=0; i < 5; i++)
			{
				if (sparrowData[i] != 0)
				{
					for (var j:int=0; j < m_SparrowItemArray.length; j++)
					{

						if (sparrowData[i] == (m_SparrowItemArray[j] as tagSparrowItem).cbSparrowData)
						{	
							(m_SparrowItemArray[j] as tagSparrowItem).isEnable=true;
							break;
/* 							if (j != 0)
							{
								if (m_SparrowItemArray[j].cbSparrowData == m_SparrowItemArray[j - 1].cbSparrowData)
								{
									(m_SparrowItemArray[j - 1] as tagSparrowItem).isEnable=false;
								}
							} */
							
						//	(m_SparrowItemArray[j] as tagSparrowItem).isEnable=true;
							//trace("data:"+(m_SparrowItemArray[j] as tagSparrowItem).cbSparrowData);

						}
					}
				}
			}
			RectifyControl();
		}
		public function setOutSparrowStatus():void{
			_status = 0;
		}
		/**
		 *	设置听牌麻将
		 * @param data
		 *
		 */
		public function setTingSparrow(data:Array):void
		{

			_status=2;
			m_CurrentSparrow.isEnable=false;
			_tingArrayData=data;
			for each (var k:tagSparrowItem in m_SparrowItemArray)
			{
				(k).isEnable=false;
			}
			for (var i:int=0; i < data.length; i++)
			{
				if (data[i] == m_CurrentSparrow.cbSparrowData)
				{
					m_CurrentSparrow.isEnable=true;
					continue;
				}
				for (var j:int=0; j < m_SparrowItemArray.length; j++)
				{

					if (data[i] == (m_SparrowItemArray[j] as tagSparrowItem).cbSparrowData)
					{

						if (j != 0)
						{
							if (m_SparrowItemArray[j].cbSparrowData == m_SparrowItemArray[j - 1].cbSparrowData)
							{
								(m_SparrowItemArray[j - 1] as tagSparrowItem).isEnable=false;
							}

						}

						(m_SparrowItemArray[j] as tagSparrowItem).isEnable=true;
					}
				}
			}
			RectifyControl();
		}

		//索引切换
		public function SwitchSparrowPoint(MousePoint:Point):uint
		{
			//基准位置
			var nXPos:uint=MousePoint.x - m_ControlPoint.x;
			var nYPos:uint=MousePoint.y - m_ControlPoint.y;

			//范围判断
			if (nXPos < 0 || nXPos > m_ControlSize.x)
			{
				return INVALID_ITEM;

			}
			if (nYPos < POS_SHOOT || nYPos > m_ControlSize.y)
			{
				return INVALID_ITEM;

			}

			//牌列子项
			if (nXPos < SPARROW_WIDTH * Memory.CountArray(m_SparrowItemArray))
			{
				var wViewIndex:uint=nXPos / SPARROW_WIDTH + m_wSparrowCount;
				if (wViewIndex >= Memory.CountArray(m_SparrowItemArray))
				{
					return wViewIndex - Memory.CountArray(m_SparrowItemArray);
				}

				return INVALID_ITEM;
			}


			//当前子项
			if (m_CurrentSparrow.cbSparrowData != 0 && nXPos >= (m_ControlSize.x - SPARROW_WIDTH))
			{
				return Memory.CountArray(m_SparrowItemArray);
			}

			return INVALID_ITEM;
		}

		//光标消息
		public function OnEventMouse(point:Point):Boolean
		{

			//获取索引
			var wHoverItem:uint=SwitchSparrowPoint(point);

			//响应判断
			if (m_bPositively == false && m_wHoverItem != INVALID_ITEM)
			{

				m_wHoverItem=INVALID_ITEM;
			}

			//更新判断
			if (wHoverItem != m_wHoverItem && m_bPositively == true)
			{
				allShootFalse(); //全部改成false
				m_wHoverItem=wHoverItem;
				if (m_wHoverItem != INVALID_ITEM)
				{

					if ((m_SparrowItemArray[m_wHoverItem] as tagSparrowItem) == null)
					{

						return false;
					}

					if ((m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).isEnable == true)
					{
						if (_status == 0)
						{

							(m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).bShoot=true;
						}
						else if (_status == 1) //这里判断吃牌情况
						{
							var sparrowData:uint=(m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).cbSparrowData;
							switch (chi_Arry.indexOf(sparrowData))
							{
								case 0:
								{
									findItem(chi_Arry[0]).bShoot=true;
									findItem(chi_Arry[1]).bShoot=true;
									_sendChiType=GameLogicDef.WIK_RIGHT;
									break;
								}
								case 1:
								{
									if (chi_Arry[3] != 0)
									{
										findItem(chi_Arry[1]).bShoot=true;
										findItem(chi_Arry[3]).bShoot=true;
										_sendChiType=GameLogicDef.WIK_CENTER;
									}
									else
									{
										findItem(chi_Arry[0]).bShoot=true;
										findItem(chi_Arry[1]).bShoot=true;
										_sendChiType=GameLogicDef.WIK_RIGHT;
									}
									break;
								}
								case 3:
								{
									if (chi_Arry[1] != 0)
									{
										findItem(chi_Arry[1]).bShoot=true;
										findItem(chi_Arry[3]).bShoot=true;
										_sendChiType=GameLogicDef.WIK_CENTER;
									}
									else
									{
										findItem(chi_Arry[4]).bShoot=true;
										findItem(chi_Arry[3]).bShoot=true;
										_sendChiType=GameLogicDef.WIK_LEFT;
									}
									break;
								}
								case 4:
								{
									findItem(chi_Arry[4]).bShoot=true;
									findItem(chi_Arry[3]).bShoot=true;
									_sendChiType=GameLogicDef.WIK_LEFT;
									break;
								}
							}
						}
						else if (_status == 2) //判断吃牌
						{
							for each (var j:tagSparrowItem in m_SparrowItemArray)
							{

								if (j.isEnable == true && j.cbSparrowData == (m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).cbSparrowData)
								{
									j.bShoot=true;
								}


							}
							_tingCenter=(m_SparrowItemArray[m_wHoverItem] as tagSparrowItem).cbSparrowData;
						}

					}

				}

			}

			return ((wHoverItem != INVALID_ITEM) ? true : false);

		}

		private function RectifyControl():void
		{
			//横向位置
			switch (m_XCollocateMode)
			{
				case enXCollocateMode.enXLeft:
				{
					m_ControlPoint.x=m_BenchmarkPos.x;
					break;
				}
				case enXCollocateMode.enXCenter:
				{
					m_ControlPoint.x=m_BenchmarkPos.x - m_ControlSize.x / 2;
					break;
				}
				case enXCollocateMode.enXRight:
				{
					m_ControlPoint.x=m_BenchmarkPos.x - m_ControlSize.x;
					break;
				}
			}
			;

			//竖向位置
			switch (m_YCollocateMode)
			{
				case enYCollocateMode.enYTop:
				{
					m_ControlPoint.y=m_BenchmarkPos.y;
					break;
				}
				case enYCollocateMode.enYCenter:
				{
					m_ControlPoint.y=m_BenchmarkPos.y - m_ControlSize.y / 2;
					break;
				}
				case enYCollocateMode.enYBottom:
				{
					m_ControlPoint.y=m_BenchmarkPos.y - m_ControlSize.y;
					break;
				}
			}
			;
			Invalidate();
		}



		private function OnPaint(pDC:BitmapData, rcClient:Rectangle):void
		{
			//绘画准备
			var nXExcursion:Number=m_ControlPoint.x + (Memory.CountArray(m_SparrowItemArray) - m_wSparrowCount) * SPARROW_WIDTH;
			//绘画麻将

			if (_status == 0)
			{
				if (!isShow)
				{
					for (var i:uint=0; i < m_wSparrowCount; i++)
					{
						//计算位置

						var nXScreenPos:Number=nXExcursion + SPARROW_WIDTH * i;
						var nYScreenPos:Number=m_ControlPoint.y + (((m_SparrowItemArray[i].bShoot == false)) ? POS_SHOOT : 0);


						//绘画麻将
						var cbSparrowData:uint=((m_bDisplayItem == true) ? m_SparrowItemArray[i].cbSparrowData : 0);
						m_SparrowResource.m_ImageUserBottom.DrawSparrowItem(pDC, cbSparrowData, nXScreenPos, nYScreenPos);

					}
				}
				else
				{
					for (var i:uint=0; i < m_wSparrowCount; i++)
					{
						//计算位置

						var nXScreenPos:Number=nXExcursion + 26 * i;
						var nYScreenPos:Number=m_ControlPoint.y + (((m_SparrowItemArray[i].bShoot == false)) ? POS_SHOOT : 0);
						//绘画麻将					
						m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC, showData[i], nXScreenPos, nYScreenPos);

					}
					if (m_center != 0)
					{
						var nXScreenPos:Number=nXExcursion + 26 * (i + 1);
						var nYScreenPos:Number=m_ControlPoint.y + (((m_SparrowItemArray[i].bShoot == false)) ? POS_SHOOT : 0);
						m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC, m_center, nXScreenPos, nYScreenPos);
					}
				}

			}
			else
			{
				for (var i:uint=0; i < m_wSparrowCount; i++)
				{


					var nXScreenPos:Number=nXExcursion + SPARROW_WIDTH * i;

					var nYScreenPos:Number=m_ControlPoint.y + (((m_SparrowItemArray[i].bShoot == false) || (m_SparrowItemArray[i].isEnable == false)) ? POS_SHOOT : 0);
					//计算位置

					//绘画麻将



					if ((m_SparrowItemArray[i] as tagSparrowItem).isEnable == false)
					{
						nYScreenPos=m_ControlPoint.y + POS_SHOOT;
					}
					var cbSparrowData:uint=((m_bDisplayItem == true) ? m_SparrowItemArray[i].cbSparrowData : 0);
					m_SparrowResource.m_ImageUserBottom.DrawSparrowItem(pDC, cbSparrowData, nXScreenPos, nYScreenPos);
					if ((m_SparrowItemArray[i] as tagSparrowItem).isEnable == false)
					{
						pDC.colorTransform(new Rectangle(nXScreenPos, nYScreenPos, SPARROW_WIDTH, SPARROW_HEIGHT), cTransform);
					}

				}
			}

			//当前麻将
			if (m_CurrentSparrow.cbSparrowData != 0 && isShow == false&&m_CurrentSparrow.isEnable==true)
			{
				//计算位置
				var nXScreenPos:Number=m_ControlPoint.x + m_ControlSize.x - SPARROW_WIDTH;
				var nYScreenPos:Number=m_ControlPoint.y + ((m_CurrentSparrow.bShoot == false && m_wHoverItem != Memory.CountArray(m_SparrowItemArray)) ? POS_SHOOT : 0);

				//绘画麻将
				var cbSparrowData:uint=((m_bDisplayItem == true) ? m_CurrentSparrow.cbSparrowData : 0);
				m_SparrowResource.m_ImageUserBottom.DrawSparrowItem(pDC, cbSparrowData, nXScreenPos, nYScreenPos);
			}
			else if (m_CurrentSparrow.cbSparrowData != 0 && isShow == false && m_CurrentSparrow.isEnable == false)
			{
				var nXScreenPos:Number=m_ControlPoint.x + m_ControlSize.x - SPARROW_WIDTH;
				var nYScreenPos:Number=m_ControlPoint.y + POS_SHOOT;

				//绘画麻将
				var cbSparrowData:uint=((m_bDisplayItem == true) ? m_CurrentSparrow.cbSparrowData : 0);
				m_SparrowResource.m_ImageUserBottom.DrawSparrowItem(pDC, cbSparrowData, nXScreenPos, nYScreenPos);
				pDC.colorTransform(new Rectangle(nXScreenPos, nYScreenPos, SPARROW_WIDTH, SPARROW_HEIGHT), cTransform);
			}

		}

		private function Invalidate():void
		{
			if (this.graphics)
			{
				this.graphics.clear();

				var g:Graphics2D=new Graphics2D(this.graphics);

				var rect:Rectangle=new Rectangle(0, 0, m_ControlSize.x, m_ControlSize.y);
				var pDC:BitmapData=new BitmapData(m_ControlSize.x, m_ControlSize.y, true, 0x00ffffff);

				OnPaint(pDC, rect);

				var bBrush:BitmapBrush=new BitmapBrush(pDC, null, false, true);

				g.fillRectangle(bBrush, 0, 0, pDC.width, pDC.height);



				bBrush=null;
				g=null;
				pDC=null;
			}

		}

		/*=================鼠标响应事件==========================*/
		private function OnEventMouseMove(event:MouseEvent):void
		{
			var MousePoint:Point=new Point(mouseX, mouseY);

			var r:Boolean=OnEventMouse(MousePoint);

			var bHandle:Boolean=r;
			RectifyControl();
			MousePoint=null;
		}

		private function OnEventClick(event:MouseEvent):void
		{
			//获取麻将
			var cbHoverSparrow:uint=GetHoverSparrow();
			if (_status == 0)
			{
				if (cbHoverSparrow != 0)
				{
					dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_OUT_SPARROW, cbHoverSparrow, cbHoverSparrow));
				}
			}
			else if (_status == 1)
			{
				if (cbHoverSparrow != 0)
				{
					dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, _sendChiType, _centerSparrow));
					_status=0;
				}
			}
			else if (_status == 2)
			{
				if (cbHoverSparrow != 0)
				{

					dispatchEvent(new GameViewEvent(GameViewEvent.nGVM_SPARROW_OPERATE, GameLogicDef.WIK_LISTEN, cbHoverSparrow));
					_status=0;
				}
			}


		}
		
		private function onEventMouseOut(evt:MouseEvent):void
		{
			m_wHoverItem=INVALID_ITEM;
			allShootFalse();
			RectifyControl();
		}

		/**
		 *	所有牌的bshoot设为false;
		 *
		 */
		public function allShootFalse():void
		{
			for each (var i:tagSparrowItem in m_SparrowItemArray)
			{
				i.bShoot=false;
			}
		}

		/**
		 *
		 * @param value
		 * @return 返回 当前拍的在排序中的位置
		 *
		 */
		private function findItem(value:uint):tagSparrowItem
		{
			for each (var i:tagSparrowItem in m_SparrowItemArray)
			{
				if (i.cbSparrowData == value && i.isEnable == true)
				{
					return i;
				}
			}
			return null;
		}
	}
}