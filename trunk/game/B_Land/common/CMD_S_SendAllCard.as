package B_Land.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_SendAllCard
	{
		public static const sizeof_CMD_S_SendAllCard:int = 2 + CMD_Land.GAME_PLAYER*20 + 3 + 1;
		
		public var wCurrentUser:uint;												//当前玩家WORD
		public var bCardData:Array = new Array(CMD_Land.GAME_PLAYER);			//扑克列表BYTE[CMD_Land.GAME_PLAYER][20]
		public var bBackCardData:Array = new Array(3);								//底牌扑克BYTE
		
		public static function readData(bytes:ByteArray):CMD_S_SendAllCard{
			var result:CMD_S_SendAllCard = new CMD_S_SendAllCard;
			
			result.wCurrentUser = bytes.readUnsignedShort();
			for(var i:int = 0;i<CMD_Land.GAME_PLAYER; i++){
				for(var j:int = 0; j<20; j++){
					result.bCardData[i][j] = bytes.readUnsignedByte();
				}
			}
			for(var k:int=0; k<3; k++){
				result.bBackCardData[k] = bytes.readUnsignedByte();
			}
			
			return result;
		}
		
		public function CMD_S_SendAllCard()
		{
			for(var i:int=0; i<CMD_Land.GAME_PLAYER; i++){
				bCardData[i] = new Array(20);
			}
		}

	}
}