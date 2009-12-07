package Application.model.vo.protocol
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_Buffer
	{
		public var cmdHead:CMD_Head=new CMD_Head;
		public var baBuffer:ByteArray=Memory.newLitteEndianByteArray();
		
		public function CMD_Buffer()
		{
		}
		
		public static function readData(bytes:ByteArray):CMD_Buffer{
			var result:CMD_Buffer=new CMD_Buffer;
			var pos:int=bytes.position;
			
			result.cmdHead=CMD_Head.readData(bytes);
			bytes.position=CMD_Head.sizeof_CMD_Head;
			bytes.readBytes(result.baBuffer);
			
			bytes.position=pos;
			return result;
		}
		
		public function toByteArray():ByteArray{
			var result:ByteArray=Memory.newLitteEndianByteArray();
			
			result.writeBytes(cmdHead.toByteArray(),0,CMD_Head.sizeof_CMD_Head);
			result.position= CMD_Head.sizeof_CMD_Head;
			result.writeBytes(baBuffer);
			
			return result;
		}
		
	}
}