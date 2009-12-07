package Application.model.vo.protocol.gameFrame
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GF_Info
	{
		public static const sizeof_CMD_GF_Info:int = 1;
		
		public var bAllowLookon:Boolean;
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeBoolean(bAllowLookon);
			
			return result;
		}
		
		public function CMD_GF_Info()
		{
		}

	}
}