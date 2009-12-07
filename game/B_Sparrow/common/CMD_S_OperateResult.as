package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_OperateResult
	{
		public static const sizeof_CMD_S_OperateResult:uint = 2 + 2 + 2 + 1 + 1 + 2 + 1 + 1;
		
		public var wCurrentUser:uint;//当前用户word		不使用
		public var wOperateUser:uint;//操作用户word		使用
		public var wProvideUser:uint;//供应用户word		使用
		public var cbCurrentCard:uint;//发送扑克byte		不使用
		public var cbOperateCode:uint;//操作代码word		使用
		public var cbOperateCard:uint;//操作扑克byte		使用
		
		public function CMD_S_OperateResult()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_OperateResult
		{
			var result:CMD_S_OperateResult = new CMD_S_OperateResult;
			
			result.wCurrentUser = data.readUnsignedShort();
			result.wOperateUser = data.readUnsignedShort();
			result.wProvideUser = data.readUnsignedShort();
			result.cbCurrentCard = data.readUnsignedByte();
			data.readUnsignedByte();
			result.cbOperateCode = data.readUnsignedShort();
			result.cbOperateCard = data.readUnsignedByte();	
			
			return result;
		}
	}
}