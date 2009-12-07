package B_Land.common
{
	import flash.utils.ByteArray;
	//游戏结束
	public class CMD_S_GameEnd
	{
		public static  const sizeof_CMD_S_GameEnd:uint = 4 + 4*3 + 1*3 + 1*54 + 1 + 1 + 1;
		public var lGameTax:int;										//游戏税收LONG
		public var lGameScore:Array = new Array(3);						//游戏积分LONG	
		public var bCardCount:Array = new Array(3);						//扑克数目BYTE
		public var bCardData:Array = new Array(54);						//扑克列表 BYTE

		public function CMD_S_GameEnd()
		{
		}
		public static function readData(data:ByteArray):CMD_S_GameEnd
		{
			var result:CMD_S_GameEnd=new CMD_S_GameEnd;
			//游戏税收
			result.lGameTax = data.readInt();
			//游戏积分
			for (var i:uint = 0; i < result.lGameScore.length; i ++)
			{
				result.lGameScore[i]=data.readInt();
			}
			//扑克数目
			for (i = 0; i <result.bCardCount.length; i ++)
			{
				result.bCardCount[i]=data.readUnsignedByte();
			}
			//扑克列表
			for (i = 0; i <result.bCardData.length; i ++)
			{
				result.bCardData[i]=data.readUnsignedByte();
			}
			
			
			return result;
		}
	}
}