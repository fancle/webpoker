package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_StatusPlay
	{
		public static const sizeof_CMD_S_StatusPlay:uint = 4 + 2 + 2 + 2 + 1 + 1 + 1 * 2 + 1 + 1 * 2 
															+ 2 + 1 + 1 * 2 + 1 * 2 * 60 
															+ 1 + 1 * 14 + 1
															+ 1 * 2 + 1 * 2 * 4;
		
		// 游戏变量
		public var lCellScore:int = 0;//单元积分
		public var wSiceCount:uint;//骰子点数
		public var wBankerUser:uint;//庄家用户
		public var wCurrentUser:uint;//当前用户
		 
		 
		 //状态变量
		 public var cbActionCard:uint;//动作扑克
		 public var cbActionMask:uint;//动作掩码
		 //public var cbHearStatus[GAME_PLAYER]//听牌状态
		 
		 public var  cbHearStatus:Array = new Array(2);//听牌状态
		 public var cbLeftCardCount:uint//剩余数目
		 public var bTrustee:Array = new Array(2);	//是否托管
		 
		 //出牌信息
		 public var wOutCardUser:uint//出牌用户
		 public var cbOutCardData:uint//出牌扑克
		 //public var cbDiscardCount[GAME_PLAYER]	//丢弃数目
		 //public var cbDiscardCard[GAME_PLAYER][60];	//丢弃记录
		 
		 public var cbDiscardCount:Array = new Array(2);//丢弃数目
		 public var cbDiscardCard:Array = new Array(2);//丢弃记录
		 
		 //	扑克数据
		 public var cbCardCount:uint;	//扑克数目
		 public var cbCardData:Array = new Array(14);	//扑克列表
		 public var cbSendCardData:uint;	//发送扑克
		 
		 //组合扑克
		 public var cbWeaveCount:Array = new Array(2);	//组合数目
		 public var WeaveItemArray:Array = new Array(2);	//组合扑克
		 
		public function CMD_S_StatusPlay()
		{
			for(var i:uint = 0; i < cbDiscardCard.length; i++)
			{
				cbDiscardCard[i] = new Array(60);
			}
			for(i = 0; i < WeaveItemArray.length; i++)
			{
				WeaveItemArray[i] = new Array(4);
				for(var k:uint = 0; k < (WeaveItemArray[i] as Array).length; k++)
				{
					WeaveItemArray[i][k] = new CMD_WeaveItem();
				}
			}
		}
		
		public static function readData(data:ByteArray):CMD_S_StatusPlay
		{
			var pos:int = data.position;
			var result:CMD_S_StatusPlay = new CMD_S_StatusPlay;
			
			//游戏变量
			result.lCellScore = data.readUnsignedInt();//单元积分
			result.wSiceCount = data.readUnsignedShort();//骰子点数
			result.wBankerUser = data.readUnsignedShort();//庄家用户
			result.wCurrentUser = data.readUnsignedShort();//当前用户
			
			//状态变量
			result.cbActionCard = data.readUnsignedByte();//动作扑克
			result.cbActionMask= data.readUnsignedByte();//动作掩码
			
			for(var i:uint = 0; i < result.cbHearStatus.length; i++)
			{
				result.cbHearStatus[i] = data.readUnsignedByte();//听牌状态
			}
			
			result.cbLeftCardCount= data.readUnsignedByte();//剩余数目
			
			for(i = 0; i < result.bTrustee.length; i++)
			{
				result.bTrustee[i] = data.readUnsignedInt();//是否托管
			}
			
			//出牌信息
			result.wOutCardUser = data.readUnsignedShort();//出牌用户
			result.cbOutCardData = data.readUnsignedByte();//出牌扑克
			
			for(i = 0; i < result.cbDiscardCount.length; i++)
			{
				result.cbDiscardCount[i] = data.readUnsignedByte();//丢弃数目	
			}
			
			for(i = 0; i < result.cbDiscardCard.length; i++)
			{
				for(var k:uint = 0; k < (result.cbDiscardCard[i] as Array).length; k++)
				{
					result.cbDiscardCard[i][k] = data.readUnsignedByte();
				}//丢弃记录
			}
			
			
			//扑克数据
			result.cbCardCount = data.readUnsignedByte();	//扑克数目
			
			for(i = 0; i < result.cbCardData.length; i++)
			{
				result.cbCardData[i] = data.readUnsignedByte();		//扑克列表
			}
			
			result.cbSendCardData = data.readUnsignedByte();		//发送扑克
			
			
			//组合扑克
			for(i = 0; i < result.cbWeaveCount.length; i++)
			{
				result.cbWeaveCount[i] = data.readUnsignedByte();	//组合数目	
			}
			
			for(i = 0; i < (result.WeaveItemArray[i] as Array).length; i++)
			{
				for(var k:uint = 0; k < (result.WeaveItemArray[i] as Array).length; i++)
				{
					result.WeaveItemArray[i][k] = CMD_WeaveItem.readData(data);//组合扑克
				}
			}
			
			data.position = pos;
			return result;
			
		}
		
	}
}