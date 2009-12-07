package B_Sparrow
{
	import Application.utils.Memory;
	
	import common.game.enDirection;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import org.aswing.graphics.BitmapBrush;
	import org.aswing.graphics.Graphics2D;
	
	//丢弃麻将
	public class DiscardSparrow extends UIComponent
	{
		//麻将数据
		protected var m_wSparrowCount:uint;//麻将数目
		protected var m_cbSparrowData:Array=new Array(20);//当前标志
		
		//控制变量
		protected var m_ControlSize:Point = new Point;
		protected var m_ControlPoint:Point=new Point;//基准位置
		protected var m_SparrowDirection:uint;//麻将方向
		
		protected var m_SparrowResource:SparrowResource;
		
		public function DiscardSparrow(res:SparrowResource)
		{
			m_SparrowResource=res;
			
			//麻将数据
			m_wSparrowCount=0;
			Memory.ZeroArray(m_cbSparrowData);
			m_ControlSize.x = 10*26;
			m_ControlSize.y = 2*36;
			//控制变量
			//m_SparrowDirection=enDirection.Direction_East;
		}
		
		static public function Destroy(data:DiscardSparrow):void
		{
			if(data)
			{
				data.m_SparrowResource = null;
				data.m_ControlPoint = null;
				data.m_cbSparrowData = null;	
			}	
		}
		
		//增加麻将
		public function AddSparrowItem(cbSparrowData:uint):Boolean
		{
			//清理麻将
			if(m_wSparrowCount >= Memory.CountArray(m_cbSparrowData))
			{
				this.m_wSparrowCount--;
				Memory.MoveArray(m_cbSparrowData,m_cbSparrowData,Memory.CountArray(m_cbSparrowData) - 1,0,1);
			}	
			
			//设置麻将
			m_cbSparrowData[m_wSparrowCount++]=cbSparrowData; 
			Invalidate();
			return true;
		}
		public function RemoveSparrowItem(cbSparrowData:uint):Boolean
		{
			m_cbSparrowData[m_wSparrowCount--] = null;
			Invalidate();
			return true;
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
		
		//控件控制
		//设置方向
		public function SetDirection(Direction:uint):void
		{
			m_SparrowDirection=Direction;
		}
		
		//基准位置
		public function SetControlPoint(nXPos:int,nYPos:int):void
		{
			m_ControlPoint.x=nXPos;
			m_ControlPoint.y=nYPos;
		}		

		private function OnPaint(pDC:BitmapData, rcClient:Rectangle):void{
			switch (m_SparrowDirection)
			{
				case enDirection.Direction_South ://南向
					{
						//绘画麻将
						for (var i:uint=0; i < m_wSparrowCount; i++)
						{
							var nXPos:Number=m_ControlPoint.x + i % 10 * 26;
							var nYPos:Number=m_ControlPoint.y + uint(i / 10) * 26;
							m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC,m_cbSparrowData[i],nXPos,nYPos);
						}
//						trace("m_cbSparrowData:"+m_cbSparrowData);
//						trace("m_cbSparrowDataLength:"+m_cbSparrowData.length);
						break;
					};
				case enDirection.Direction_North ://北向
					{
						//绘画麻将
						for (var i:uint=0; i < m_wSparrowCount; i++)
						{
							var nXPos:Number=m_ControlPoint.x - ((m_wSparrowCount - 1 - i )% 10) * 26;
							var nYPos:Number=m_ControlPoint.y - (uint(((m_wSparrowCount - 1 - i )/ 10) + 1) * 25) - 10;
							m_SparrowResource.m_ImageTableTop.DrawSparrowItem(pDC,m_cbSparrowData[m_wSparrowCount - i - 1],nXPos,nYPos);
						}
						break;
				}
			}
			
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
	}
}