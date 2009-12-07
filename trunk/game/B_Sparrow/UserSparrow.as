package B_Sparrow
{
	import common.game.enDirection;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import org.aswing.graphics.BitmapBrush;
	import org.aswing.graphics.Graphics2D;

	//用户麻将
	public class UserSparrow extends UIComponent
	{
		//麻将数据
		protected var m_wSparrowCount:uint; //麻将数目
		protected var m_bCurrentSparrow:Boolean; //当前标志

		//控制变量
		protected var m_ControlPoint:Point=new Point; //基准位置
		protected var m_ControlSize:Point=new Point; //空间大小
		protected var m_SparrowDirection:uint; //麻将方向

		protected var m_SparrowResource:SparrowResource;

		private var pDC:BitmapData;

		private var m_sparrowData:Array=new Array();
		private var isShow:Boolean=false;
		private var m_center:uint;

		public function UserSparrow(res:SparrowResource)
		{
			m_SparrowResource=res;
			//麻将数据
			m_wSparrowCount=0;
			m_bCurrentSparrow=false;

			//控制变量
			m_SparrowDirection=enDirection.Direction_East;
			m_ControlSize.x=14 * 25 + 40;
			m_ControlSize.y=37;
		}

		private function createPDC():void
		{

		}

		static public function Destroy(data:UserSparrow):void
		{
			if (data)
			{
				data.m_SparrowResource=null;
				data.m_ControlPoint=null;
			}
		}

		//设置麻将
		public function SetCurrentSparrow(bCurrentSparrow:Boolean):Boolean
		{
			//设置变量
			m_bCurrentSparrow=bCurrentSparrow;
			Invalidate();
			return true;
		}

		//设置麻将
		public function SetSparrowData(wSparrowCount:uint, bCurrentSparrow:Boolean):Boolean
		{

			//设置变量
			isShow=false;
			m_wSparrowCount=wSparrowCount;
			m_bCurrentSparrow=bCurrentSparrow;
			Invalidate();
			return true;
		}

		public function setShowSparrowData(sparrowData:Array, count:uint,centerValue:uint):void
		{
			isShow=true;
			m_sparrowData=sparrowData;
			m_wSparrowCount=count;
			m_center = centerValue;
			Invalidate();
		}

		//控件控制
		//设置方向
		public function SetDirection(Direction:uint):void
		{
			m_SparrowDirection=Direction;
		}

		//基准位置
		public function SetControlPoint(nXPos:int, nYPos:int):void
		{
			m_ControlPoint.x=nXPos;
			m_ControlPoint.y=nYPos;
			Invalidate();
		}

		public function DrawSparrowControl(pDC:BitmapData=null):void
		{
			switch (m_SparrowDirection)
			{
				case enDirection.Direction_North: //北向
				{
					//当前麻将
					if (m_bCurrentSparrow == true)
					{
						var nXPos:Number=m_ControlPoint.x;
						var nYPos:Number=m_ControlPoint.y;
						m_SparrowResource.m_ImageUserTop.DrawBitmapData(pDC, nXPos, nYPos);
					}
					//正常麻将
					if (m_wSparrowCount > 0)
					{
						var nXPos:Number=0;
						var nYPos:Number=0;
						for (var i:uint=0; i < m_wSparrowCount; i++)
						{
							nYPos=m_ControlPoint.y;
							nXPos=m_ControlPoint.x + i * 25 + 40;
							m_SparrowResource.m_ImageUserTop.DrawBitmapData(pDC, nXPos, nYPos);
						}
					}
					break;
				}
			}

		}

		private function OnPaint(pDC:BitmapData, rcClient:Rectangle):void
		{
			switch (m_SparrowDirection)
			{
				case enDirection.Direction_North: //北向
				{
					if (!isShow)
					{
						if (m_bCurrentSparrow == true)
						{
							var nXPos:Number=m_ControlPoint.x;
							var nYPos:Number=m_ControlPoint.y;
							m_SparrowResource.m_ImageUserTop.DrawBitmapData(pDC, nXPos, nYPos);
						}
						//正常麻将
						if (m_wSparrowCount > 0)
						{
							var nXPos:Number=0;
							var nYPos:Number=0;
							for (var i:uint=0; i < m_wSparrowCount; i++)
							{
								nYPos=m_ControlPoint.y;
								nXPos=m_ControlPoint.x + i * 25 + 40;
								m_SparrowResource.m_ImageUserTop.DrawBitmapData(pDC, nXPos, nYPos);
							}
						}
					}else{
											//正常麻将
						if (m_wSparrowCount > 0)
						{
							var nXPos:Number=0;
							var nYPos:Number=0;
							for (var i:uint=0; i < m_wSparrowCount; i++)
							{
								nYPos=m_ControlPoint.y;
								nXPos=m_ControlPoint.x + i * 25 + 40;
								m_SparrowResource.m_ImageTableTop.DrawSparrowItem(pDC,m_sparrowData[i],nXPos, nYPos);
							}
							m_SparrowResource.m_ImageTableTop.DrawSparrowItem(pDC,m_center,m_ControlPoint.x, m_ControlPoint.y);
						}
					}
					//当前麻将

					break;
				}
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

	}
}