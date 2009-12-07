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
	
	//组合麻将
	public class WeaveSparrow extends UIComponent
	{
		//控制变量
		protected var m_bDisplayItem:Boolean;	//显示标志
		protected var m_ControlPoint:Point=new Point  ;//基准位置
		protected var m_SparrowDirection:uint;//麻将方向
		protected var m_ControlSize:Point = new Point();
		
		//麻将数据
		protected var m_wSparrowCount:uint;//麻将数目
		protected var m_cbSparrowData:Array=new Array(4);//麻将数据
		
		protected var m_SparrowResource:SparrowResource;
		
		public function WeaveSparrow(res:SparrowResource)
		{
			m_SparrowResource=res;
			
			//状态变量
			m_bDisplayItem=false;
			
			m_ControlSize.x = 78;//这里可能要改动
			m_ControlSize.y = 56;
			m_SparrowDirection=enDirection.Direction_South;
			
			//麻将数据
			m_wSparrowCount=0;
			Memory.ZeroArray(m_cbSparrowData);
		}
		
		static public function Destroy(data:WeaveSparrow):void
		{
			if(data)
			{
				data.m_SparrowResource = null;
				data.m_ControlPoint = null;
				data.m_cbSparrowData = null;
			}
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
		//设置显示
		public function SetDisplayItem(bDisplayItem:Boolean):void
		{
			m_bDisplayItem=bDisplayItem;
			Invalidate();
			
		}
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

		//内部函数
		//获取麻将
		public function GetSparrowData(wIndex:uint):uint
		{
			Memory.ASSERT(wIndex < Memory.CountArray(m_cbSparrowData));
			return (m_bDisplayItem == true || wIndex == 2)?m_cbSparrowData[wIndex]:0;
		}
		

		private function OnPaint(pDC:BitmapData, rcClient:Rectangle):void{
			//显示判断
			if (m_wSparrowCount == 0)
			{
				return;
			}

			//变量定义
			var nXScreenPos:Number=0;
			var nYScreenPos:Number=0;
			var nItemWidth:Number=0;
			var nItemHeight:Number=0;
			var nItemWidthEx:Number=0;
			var nItemHeightEx:Number=0;

			//绘画麻将
			switch (m_SparrowDirection)
			{
				case enDirection.Direction_South ://南向
					{
						//变量定义
						nItemWidth=m_SparrowResource.m_ImageTableBottom.GetViewWidth();
						nItemHeight=m_SparrowResource.m_ImageTableBottom.GetViewHeight();
						for(var i:int = 0;i<m_wSparrowCount; i ++)
 					 	{
		
							if(m_wSparrowCount==3||(i!=2 && m_wSparrowCount==4 ))
							{
								nXScreenPos  =m_ControlPoint.x + nItemWidth*i;
								if(i==3) nXScreenPos  =m_ControlPoint.x + nItemWidth*(i-1);								
								nYScreenPos = 20;
								m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC,GetSparrowData(i),nXScreenPos,nYScreenPos);
							}else{
								nXScreenPos  =m_ControlPoint.x + nItemWidth*(i-1);
								nYScreenPos = 10;
								m_SparrowResource.m_ImageTableBottom.DrawSparrowItem(pDC,GetSparrowData(i),nXScreenPos,nYScreenPos);
							}
						} 

						break;

					};
				case enDirection.Direction_North ://北向
					{
						//变量定义
						nItemWidth=m_SparrowResource.m_ImageTableTop.GetViewWidth();
						nItemHeight=m_SparrowResource.m_ImageTableTop.GetViewHeight();		
 					 	for(var i:int = 0;i<m_wSparrowCount; i ++)
 					 	{
		
							if(m_wSparrowCount==3||(i!=2 && m_wSparrowCount==4 ))
							{
								nXScreenPos  =m_ControlPoint.x + nItemWidth*i;
								if(i==3) nXScreenPos  =m_ControlPoint.x + nItemWidth*(i-1);								
								nYScreenPos = 20;
								m_SparrowResource.m_ImageTableTop.DrawSparrowItem(pDC,GetSparrowData(i),nXScreenPos,nYScreenPos);
							}else{
								nXScreenPos  =m_ControlPoint.x + nItemWidth*(i-1);
								nYScreenPos = 10;
								m_SparrowResource.m_ImageTableTop.DrawSparrowItem(pDC,GetSparrowData(i),nXScreenPos,nYScreenPos);
							}
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