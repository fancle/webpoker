package Application.model.vo.protocol
{
	import flash.utils.ByteArray;
	
	import Application.utils.Memory;
	
	public class CMD_Command
	{
		public static const sizeof_CMD_Command:int=2+2;
		
		public var wMainCmdID:uint;//主命令码
		public var wSubCmdID:uint;//子命令码
		
		public function CMD_Command()
		{
			super();
		}
		
		public static function readData(data:ByteArray):CMD_Command{
			var pos:int=data.position;
			
			var result:CMD_Command=new CMD_Command;
			
			result.wMainCmdID=data.readShort();
			result.wSubCmdID=data.readShort();
			
			data.position=pos;
			
			return result;
		}
		public function toByteArray():ByteArray{
			var result:ByteArray=Memory.newLitteEndianByteArray();
			
			result.writeShort(wMainCmdID);
			result.writeShort(wSubCmdID);
			
			return result;
		}
	}
}