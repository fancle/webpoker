package Application.model.vo.protocol.gameFrame
{
	import Application.model.vo.protocol.room.tagUserScore;
	
	import flash.utils.ByteArray;

	//用户状态
	public class IPC_UserScore
	{
		public static  const sizeof_IPC_UserScore = 4 + tagUserScore.sizeof_tagUserScore;
		public var dwUserID:uint;//用户 I D
		public var UserScore:tagUserScore = new tagUserScore;//用户积分
		public function IPC_UserScore()
		{

		}
		public static function readData(data:ByteArray):IPC_UserScore
		{
			var result:IPC_UserScore=new IPC_UserScore;
			
			result.dwUserID = data.readUnsignedInt();
			result.UserScore = tagUserScore.readData(data);
			
			return result;
		}
	}
}

