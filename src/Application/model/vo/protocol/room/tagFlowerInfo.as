package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class tagFlowerInfo
	{
		public static const sizeof_tagFlowerInfo:int = 4 + 4 + 4 + 4 + 1 + 1 + 2;
		
		public var nFlowerID:int;							//鲜花ID int
		public var lPrice:int;								//鲜花价格 LONG
		public var lSendUserCharm:int;						//赠送魅力 LONG
		public var lRcvUserCharm:int;						//接受魅力 LONG
		public var cbDiscount:int;							//会员折扣 BYTE
		public var bNullity:Boolean;						//禁止标识 bool
		
		public static function readData(data:ByteArray):tagFlowerInfo
		{
			var result:tagFlowerInfo = new tagFlowerInfo;
			
			result.nFlowerID = data.readInt();
			result.lPrice = data.readInt();
			result.lSendUserCharm = data.readInt();
			result.lRcvUserCharm = data.readInt();
			
			result.cbDiscount = data.readByte();
			result.bNullity = data.readBoolean();
			data.readShort();
			
			return result;
		}
		public function tagFlowerInfo()
		{
		}

	}
}