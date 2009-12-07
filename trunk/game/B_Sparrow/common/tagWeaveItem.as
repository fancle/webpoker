package B_Sparrow.common
{
	public class tagWeaveItem
	{
		public var cbWeaveKind:uint;		//组合类型
		public var cbCenterSparrow:uint;		//中心麻将
		public var cbPublicSparrow:Boolean;		//公开标志
		public var wProvideUser:uint;		//供应用户
		
		/* public function tagWeaveItem()
		{
		}  */
		
		public static function ZeroMemory(data:tagWeaveItem):void
		{
			data.cbWeaveKind = 0;
			data.cbCenterSparrow = 0;
			data.cbPublicSparrow = false;
			data.wProvideUser = 0;
		}
	}
}