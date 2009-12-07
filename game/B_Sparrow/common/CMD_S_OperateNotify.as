package B_Sparrow.common
{
	import flash.utils.ByteArray;
	
	public class CMD_S_OperateNotify
	{
		public static const sizeof_CMD_S_OperateNotify:uint = 2 + 1 + 1;
		
		public var wResumeUser:uint; //还原用户
		public var cbActionMask:uint; //动作掩码
		public var cbActionCard:uint; //动作扑克
		
		public function CMD_S_OperateNotify()
		{
		}
		
		public static function readData(data:ByteArray):CMD_S_OperateNotify
		{
			var result:CMD_S_OperateNotify = new CMD_S_OperateNotify();
			
			result.wResumeUser = data.readUnsignedShort();	//还原用户
			result.cbActionMask = data.readUnsignedByte();	//动作掩码
			result.cbActionCard = data.readUnsignedByte();	//动作扑克
			
			return result;
		}
	}
}