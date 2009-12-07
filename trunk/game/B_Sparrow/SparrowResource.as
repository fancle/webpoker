package B_Sparrow
{
	import common.game.SkinImage;
	
	public class SparrowResource
	{
		//用户麻将
		public var m_ImageUserTop:SkinImage;//图片资源
		public var m_ImageUserBottom:SparrowListImage;//图片资源
		
		//桌子麻将
		public var m_ImageTableTop:SparrowListImage;//图片资源源
		public var m_ImageTableBottom:SparrowListImage;//图片资源
		
		//牌堆麻将
		public var m_ImageBackH:SkinImage;//图片资源
		public var m_ImageHeapSingleH:SkinImage;//图片资源
		public var m_ImageHeapDoubleH:SkinImage;//图片资源
		
		public function SparrowResource()
		{
			
		}
		
		/*------------------------------功能函数--------------------------*/
		//加载资源
		public function NewResource():Boolean
		{
			if(m_ImageUserTop)
			{
				return true;	
			}
			//用户麻将
			m_ImageUserTop = new SkinImage;
			m_ImageUserBottom = new SparrowListImage;
			
			//桌子麻将
			m_ImageTableTop = new SparrowListImage;
			m_ImageTableBottom = new SparrowListImage;
			
			//牌堆麻将
			m_ImageBackH = new SkinImage;
			m_ImageHeapSingleH = new SkinImage;
			m_ImageHeapDoubleH = new SkinImage;
			
			return true;
		}
		
		//消耗资源
		public function UnloadResource():Boolean
		{
			if(m_ImageUserTop == null)
			{
				return true;
			}
			
			//用户麻将
			m_ImageUserTop.Unload();
			m_ImageUserBottom.UnloadResource();
			
			//桌子麻将
			m_ImageTableTop.UnloadResource();
			m_ImageTableBottom.UnloadResource();
			
			//牌堆麻将
			m_ImageBackH.Unload();
			m_ImageHeapSingleH.Unload();
			m_ImageHeapDoubleH.Unload();
			
			//用户麻将
			m_ImageUserTop = null;
			m_ImageUserBottom = null;
			
			//桌子麻将
			m_ImageTableTop = null;
			m_ImageTableBottom = null;
			
			
			//牌堆麻将
			m_ImageBackH = null;
			m_ImageHeapSingleH = null;
			m_ImageHeapDoubleH = null;
			return true;			
		}
	}
}