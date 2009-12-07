package Application.model.vo.protocol.gameFrame
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class CMD_GF_MatchMessage
	{
		public static var sizeof_CMD_GF_MatchMessage:int = 4 + 4 + 4 + 4 + GlobalDef.SERVER_LEN + GlobalDef.NAME_LEN
														+ (4-(GlobalDef.SERVER_LEN + GlobalDef.NAME_LEN)%4);
		
		public var dwMatchRank:int;					//排名　DWORD
		public var vardwMatchUD:int;				//U豆　DWORD				
		public var vardwMatchRY:int;				//荣誉值　DWORD
		public var vardwMarchUQ:int;				//U养　DWORD
		public var varszGameRoomName:String;		//房间名称　TCHAR[SERVER_LEN]
		public var varszNickName:String;			//用户昵称　TCHAR[NAME_LEN]
		
		public function CMD_GF_MatchMessage()
		{
		}
		
		public static function readData(data:ByteArray):CMD_GF_MatchMessage
		{
			var result:CMD_GF_MatchMessage = new CMD_GF_MatchMessage;
			
			result.dwMatchRank = data.readInt();
			result.vardwMatchUD = data.readInt();
			result.vardwMatchRY = data.readInt();
			result.vardwMarchUQ = data.readInt();
			result.varszGameRoomName = Memory.readStringByByteArray(data,GlobalDef.SERVER_LEN);
			result.varszNickName = Memory.readStringByByteArray(data,GlobalDef.NAME_LEN);
			
			return result;
		}	
		
		/* public function toByteArray():ByteArray
		{
			var bytes:ByteArray = Memory.newLitteEndianByteArray();
			
			bytes.writeInt(dwMatchRank);
			bytes.writeInt(vardwMatchUD);
			bytes.writeInt(vardwMatchRY);
			bytes.writeInt(vardwMarchUQ);
			Memory.writeStringToByteArray(bytes,varszGameRoomName,GlobalDef.SERVER_LEN);
			Memory.writeStringToByteArray(bytes,varszNickName,GlobalDef.NAME_LEN);
			
			return bytes;
			
		}	 */
	}
}