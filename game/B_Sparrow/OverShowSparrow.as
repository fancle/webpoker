package B_Sparrow
{
	import Application.utils.Memory;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import org.aswing.graphics.BitmapBrush;
	import org.aswing.graphics.Graphics2D;

	public class OverShowSparrow extends UIComponent
	{	
			//麻将数据
		protected var m_wSparrowCount:uint;//麻将数目
		protected var m_cbSparrowData:Array=new Array(14);//当前标志
		
		//控制变量
		protected var m_ControlSize:Point = new Point;
		protected var m_ControlPoint:Point=new Point;//基准位置
		protected var m_SparrowDirection:uint;//麻将方向
		
		protected var m_SparrowResource:SparrowResource;
		private var m_centerSparrow:uint;
		public function OverShowSparrow(res:SparrowResource)
		{
			super();
			m_SparrowResource=res;
			
			//麻将数据
			m_wSparrowCount=0;
			Memory.ZeroArray(m_cbSparrowData);
			m_ControlSize.x = 15*26;
			m_ControlSize.y = 2*36;
		}
				//设置麻将
		public function SetSparrowData(cbSparrowData:Array,wSparrowCount:uint):Boolean
		{
			//效验大小
			Memory.ASSERT(wSparrowCount <= Memory.CountArray(m_cbSparrowData));
			if (wSparrowCount > Memory.CountArray(m_cbSparrowData))
			{
				return false;
			}
			
			//设置麻将
			m_wSparrowCount=wSparrowCount;
			Memory.CopyArray(m_cbSparrowData,cbSparrowData,wSparrowCount); 
			Invalidate();
			return true;
		}
		private function Invalidate():void
		{
			if(this.graphics){
				this.graphics.clear();
				var g:Graphics2D=new Graphics2D(this.graphics);
				var rect:Rectangle=new Rectangle(0, 0,m_ControlSize.x, m_ControlSize.y);
				var pDC:BitmapData=new BitmapData(m_ControlSize.x, m_ControlSize.y, true, 0x00ffffff);
				OnPaint(pDC, rect);				
				var bBrush:BitmapBrush=new BitmapBrush(pDC, null, false, true);
				g.fillRectangle(bBrush, 0, 0, pDC.width, pDC.height);
				bBrush=null;
				g=null;
				pDC=null;
			}

		}
				//基准位置
		public function SetControlPoint(nXPos:int,nYPos:int):void
		{
			m_ControlPoint.x=nXPos;
			m_ControlPoint.y=nYPos;
		}	
		/**
		 *	设置中心牌 
		 * @param value 中心牌数据
		 * 
		 */
		public function setCenterSparrow(value:uint):void
		{
			m_centerSparrow = value;
			Invalidate();
				
		}
		private function OnPaint(pDC:BitmapData, rcClient:Rectangle):void{	
						//绘画麻将
				for (var i:uint=0; i < m_wSparrowCount; i++)
				{
						var nXPos:Number=m_ControlPoint.x + i*26;
						var nYPos:Number=m_ControlPoint.y;
						m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC,m_cbSparrowData[i],nXPos,nYPos);
				}
				if(m_centerSparrow!=0)
				{
					var nxCenter:Number = m_ControlPoint.x + (m_wSparrowCount+1)*26;
					var nyCenter:Number = m_ControlPoint.y;
					m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC,m_centerSparrow,nxCenter,nyCenter);	
				}

		}
	}
}