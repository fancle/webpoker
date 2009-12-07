package Application.model.vo.protocol.login
{
	import flash.utils.ByteArray;
	
	public class tagDataDescribe
	{
		public static const sizeof_tagDataDescribe:uint = 2 + 2 ;
		
		public var wDataSize:uint;//数据描述的大小 word
		public var wDataDescribe:uint;//数据描述的种类 word
		
		public static function readData(bytes:ByteArray):tagDataDescribe{
			var result:tagDataDescribe=new tagDataDescribe;
			
			result.wDataSize=bytes.readUnsignedShort();
			result.wDataDescribe=bytes.readUnsignedShort();
			
			return result;
		}
		
		public function tagDataDescribe()
		{
		}

	}
}