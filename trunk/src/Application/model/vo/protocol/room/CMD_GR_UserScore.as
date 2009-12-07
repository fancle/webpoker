package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class CMD_GR_UserScore
	{
		public static const sizeof_CMD_GR_UserScore:int = 4 + 4 + 4 + tagUserScore.sizeof_tagUserScore;
		
		public var lLoveliness:int;						//用户魅力LONG
		public var dwUserID:uint;						//用户 I D DWORD
		//public var dwMatchSection:uint;				//比赛阶段
		public var dwHonorRank:uint;					//排名 DWORD
		public var UserScore:tagUserScore;				//积分信息tagUserScore
		
		public static function readData(data:ByteArray):CMD_GR_UserScore
		{
			var result:CMD_GR_UserScore = new CMD_GR_UserScore;
			
			result.lLoveliness = data.readInt();
			result.dwUserID = data.readUnsignedInt();
			//result.dwMatchSection = data.readUnsignedInt();
			result.dwHonorRank = data.readUnsignedInt();
			result.UserScore = tagUserScore.readData(data);
			
			return result;
		}
		
		public function CMD_GR_UserScore()
		{
		}

	}
}