package B_Sparrow.common
{
	/**
	 * 杠牌结果
	 */
	public class tagGangCardResult
	{
		public var cbCardCount:uint;				//扑克数目
		public var cbCardData:Array = new Array(4);	//扑克数据
		public var cbGangType:Array = new Array(4);	//杠牌类型
		
		public function tagGangCardResult()
		{
			cbCardCount = 0;
			for(var i:int = 0; i<4; i++){
				cbCardData[i] = 0;
				cbGangType[i] = 0;
			}			
		} 

	}
}