package Application.model.vo.protocol.room
{
	import flash.utils.ByteArray;
	
	public class tagPropertyInfo
	{
		public static const sizeof_tagPropertyInfo:int = 4 * 21 + 1 + 1 + 2;
		public var nPropertyID:int;							//道具ID int
		public var dwPropCount1:uint;						//道具数目DWORD
		public var dwPropCount2:uint;						//道具数目DWORD
		public var dwPropCount3:uint;						//道具数目DWORD
		public var dwPropCount4:uint;						//道具数目DWORD
		public var dwPropCount5:uint;						//道具数目DWORD
		public var dwPropCount6:uint;						//道具数目DWORD
		public var dwPropCount7:uint;						//道具数目DWORD
		public var dwPropCount8:uint;						//道具数目DWORD
		public var dwPropCount9:uint;						//道具数目DWORD
		public var dwPropCount10:uint;						//道具数目DWORD
		public var lPrice1:int;								//道具价格LONG
		public var lPrice2:int;								//道具价格LONG
		public var lPrice3:int;								//道具价格LONG
		public var lPrice4:int;								//道具价格LONG
		public var lPrice5:int;								//道具价格LONG
		public var lPrice6:int;								//道具价格LONG
		public var lPrice7:int;								//道具价格LONG
		public var lPrice8:int;								//道具价格LONG
		public var lPrice9:int;								//道具价格LONG
		public var lPrice10:int;							//道具价格LONG
		public var cbDiscount:int;							//会员折扣BYTE
		public var bNullity:Boolean;						//禁止标识bool
		
		public static function readData(bytes:ByteArray):tagPropertyInfo{
			var result:tagPropertyInfo = new tagPropertyInfo;
			
			result.nPropertyID = bytes.readInt();
			result.dwPropCount1 = bytes.readUnsignedInt();
			result.dwPropCount2 = bytes.readUnsignedInt();
			result.dwPropCount3 = bytes.readUnsignedInt();
			result.dwPropCount4 = bytes.readUnsignedInt();
			result.dwPropCount5 = bytes.readUnsignedInt();
			result.dwPropCount6 = bytes.readUnsignedInt();
			result.dwPropCount7 = bytes.readUnsignedInt();
			result.dwPropCount8 = bytes.readUnsignedInt();
			result.dwPropCount9 = bytes.readUnsignedInt();
			result.dwPropCount10 = bytes.readUnsignedInt();
			result.lPrice1 = bytes.readInt();
			result.lPrice2 = bytes.readInt();
			result.lPrice3 = bytes.readInt();
			result.lPrice4 = bytes.readInt();
			result.lPrice5 = bytes.readInt();
			result.lPrice6 = bytes.readInt();
			result.lPrice7 = bytes.readInt();
			result.lPrice8 = bytes.readInt();
			result.lPrice9 = bytes.readInt();
			result.lPrice10 = bytes.readInt();
			result.cbDiscount = bytes.readByte();
			result.bNullity = bytes.readBoolean();
			
			bytes.readShort();
			
			return result;
		}
		public function tagPropertyInfo()
		{
		}

	}
}