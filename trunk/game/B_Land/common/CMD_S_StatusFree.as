package B_Land.common
{
	import flash.utils.ByteArray;
	//游戏状态
	public class CMD_S_StatusFree
	{
		public static const sizeof_CMD_S_StatusFree:uint = 4 + 4 + 8*CMD_Land.GAME_PLAYER + 8*CMD_Land.GAME_PLAYER;
		public var fBaseScore:Number = new Number;//基础积分
		//历史积分
		public var lTurnScore:Array = new Array(CMD_Land.GAME_PLAYER);			//积分信息LONGLONG
		public var lCollectScore:Array = new Array(CMD_Land.GAME_PLAYER);			//积分信息LONGLONG
		public function CMD_S_StatusFree()
		{
		}
		public static function readData(data:ByteArray):CMD_S_StatusFree
		{
			var result:CMD_S_StatusFree=new CMD_S_StatusFree;
			
			result.fBaseScore = data.readInt();
			data.readInt();
			
			for(var i:int=0; i<CMD_Land.GAME_PLAYER; i++){
				var Llonglong:uint = data.readUnsignedInt();
				var Hlonglong:int = data.readInt();
				result.lTurnScore[i] = Number(Hlonglong*0x100000000)|Llonglong;
			}
			
			for(i=0; i<CMD_Land.GAME_PLAYER; i++){
				Llonglong = data.readUnsignedInt();
				Hlonglong = data.readInt();
				result.lCollectScore[i] = Number(Hlonglong*0x100000000)|Llonglong;
			}
			
			return result;
		}
	}
}