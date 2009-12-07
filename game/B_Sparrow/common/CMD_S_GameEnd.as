package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_GameEnd 
	{
		public static const sizeof_CMD_S_GameEnd:uint = 4*CMD_Sparrow.GAME_PLAYER + 4*4*CMD_Sparrow.GAME_PLAYER
													+1*14*CMD_Sparrow.GAME_PLAYER + 1*CMD_Sparrow.GAME_PLAYER + 
													1*81*CMD_Sparrow.GAME_PLAYER + 1*CMD_Sparrow.GAME_PLAYER +
													1*CMD_Sparrow.GAME_PLAYER + 1;
		
		public var lGameScore:Array;//游戏积分LONG[Game_Player]
		public var cbHuBei:Array;//胡牌对每个人的倍数/分数LONG[Game_Player][4]
		public var cbCardData:Array;//扑克数据(所有)byte[game_Player][14]
		public var cbHuData:Array;//扑克数据(胡牌)byte[game_player]
		public var cbHuType:Array;//番型byte[game_Player][81];
		public var cbFinalState:Array;//最终状态byte[Game_Player];
		public var cbHuSort:Array;//胡牌顺序byte[Game_Player];
		public var cbScoreType:uint;//游戏类型（用于客户端是否显示税收）byte
		
		public function CMD_S_GameEnd()
		{
			lGameScore = new Array(CMD_Sparrow.GAME_PLAYER);
			
			cbHuBei = new Array(CMD_Sparrow.GAME_PLAYER);
			for(var i:uint = 0 ;i<CMD_Sparrow.GAME_PLAYER; i++){
				cbHuBei[i] = new Array(4);
			}
			
			cbCardData = new Array(CMD_Sparrow.GAME_PLAYER);
			for(i=0;i<CMD_Sparrow.GAME_PLAYER;i++){
				cbCardData[i] = new Array(14);
			}
			
			cbHuData = new Array(CMD_Sparrow.GAME_PLAYER);
			
			cbHuType = new Array(CMD_Sparrow.GAME_PLAYER);
			for(i=0;i<CMD_Sparrow.GAME_PLAYER;i++){
				cbHuType[i] = new Array(81);
			}
			
			cbFinalState = new Array(CMD_Sparrow.GAME_PLAYER);
			
			cbHuSort = new Array(CMD_Sparrow.GAME_PLAYER);
		}
		
		public static function readData(data:ByteArray):CMD_S_GameEnd
		{
			var result:CMD_S_GameEnd = new CMD_S_GameEnd();
			
			for(var i:int = 0;i<CMD_Sparrow.GAME_PLAYER;i++){
				result.lGameScore[i] = data.readInt();
			}
			for(i = 0;i<CMD_Sparrow.GAME_PLAYER;i++){
				for(var j:int=0;j<4;j++){
					result.cbHuBei[i][j] = data.readInt();
				}
			}
			for(i = 0;i<CMD_Sparrow.GAME_PLAYER;i++){
				for(j=0;j<14;j++){
					result.cbCardData[i][j] = data.readUnsignedByte();
				}
			}
			for(i=0;i<CMD_Sparrow.GAME_PLAYER;i++){
				result.cbHuData[i] = data.readUnsignedByte();
			}				
			for(i = 0;i<CMD_Sparrow.GAME_PLAYER;i++){
				for(j=0;j<81;j++){
					result.cbHuType[i][j] = data.readUnsignedByte();
				}
			}
			for(i=0;i<CMD_Sparrow.GAME_PLAYER;i++){
				result.cbFinalState[i] = data.readUnsignedByte();
			}	
			for(i=0;i<CMD_Sparrow.GAME_PLAYER;i++){
				result.cbHuSort[i] = data.readUnsignedByte();
			}
			result.cbScoreType = data.readUnsignedByte();
			
			return result;
		}

	}
}