package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GQ_Message
	{
		public var wMessageType:uint;						//消息类型WORD
		public var wMessageLength:uint;						//消息长度WORD
		public var szContent:String;						//消息内容TCHAR[1024]
		
		public static function readData(bytes:ByteArray):CMD_GQ_Message{
			var result:CMD_GQ_Message = new CMD_GQ_Message;
			
			result.wMessageType = bytes.readUnsignedShort();
			result.wMessageLength = bytes.readUnsignedShort();
			result.szContent = Memory.readStringByByteArray(bytes,result.wMessageLength);
			
			return result;
		}
		
		public function CMD_GQ_Message()
		{
		}

	}
}