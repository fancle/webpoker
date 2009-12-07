package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class tagUserScore
	{
		public static const sizeof_tagUserScore:int = 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4;
		
		public var lScore:int;								//用户分数LONG
		public var lGameGold:int;							//U豆LONG
		public var lInsureScore:int;						//存储金币LONG
		public var lWinCount:int;							//胜利盘数LONG
		public var lLostCount:int;							//失败盘数LONG
		public var lDrawCount:int;							//和局盘数LONG
		public var lFleeCount:int;							//断线数目LONG
		public var lExperience:int;							//用户经验LONG
		public var lUserUQ:uint;							//用户U券 LONG
		public var lTableRevenue:int;						//桌子费 LONG
		
		public static function readData(bytes:ByteArray):tagUserScore{
			var result:tagUserScore = new tagUserScore;
			
			result.lScore = bytes.readInt();
			result.lGameGold = bytes.readInt();
			result.lInsureScore = bytes.readInt();
			result.lWinCount = bytes.readInt();
			result.lLostCount = bytes.readInt();
			result.lDrawCount = bytes.readInt();
			result.lFleeCount = bytes.readInt();
			result.lExperience = bytes.readInt();
			result.lUserUQ = bytes.readUnsignedInt();
			result.lTableRevenue = bytes.readInt();
			
			return result;
		}
		public function tagUserScore()
		{
		}

	}
}