package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_SendHuCard
	{
		public static const sizeof_CMD_S_SendHuCard:uint = 2 + 2 + 1*14 + 1 + 1 + 4*3 + 1 + 3;//三个boolean值因为换类型而每个占到4字节
		
		public var wHuUser:uint;						//胡牌用户word
		public var wProvideUser:uint;					//点炮用户word
		public var cbHuCardList:Array = new Array(14);	//胡牌列表byte[14]
		public var cbHuCard:uint;						//所胡的牌byte
		public var bZiMo:Boolean;						//是否自摸boolean
		public var bIsFirstHu:Boolean;					//若非自摸，是否是首胡者boolean
		public var bIsGangHu:Boolean;					//是否杠胡boolean
		public var cbHideChair:uint;					//要隐藏控制窗口的用户座位号byte
		
		public function CMD_S_SendHuCard()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_SendHuCard
		{
			var result:CMD_S_SendHuCard = new CMD_S_SendHuCard;
			
			result.wHuUser = data.readUnsignedShort();
			result.wProvideUser = data.readUnsignedShort();
			for(var i:int = 0; i<14; i++){
				result.cbHuCardList[i] = data.readUnsignedByte();
			}
			result.cbHuCard = data.readUnsignedByte();
			result.bZiMo = data.readBoolean();
			result.bIsFirstHu = data.readBoolean();
			result.bIsGangHu = data.readBoolean();
			result.cbHideChair = data.readUnsignedByte();
			
			return result;
		}

	}
}