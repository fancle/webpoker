package Application.model.vo.protocol
{
	import flash.utils.ByteArray;
	
	import Application.utils.Memory;

	public class CMD_Head
	{
		public static const sizeof_CMD_Head:int=CMD_Info.sizeof_CMD_Info + CMD_Command.sizeof_CMD_Command; 
		
		public var cmd_info:CMD_Info = new CMD_Info;
		public var cmd_command:CMD_Command = new CMD_Command;
		
		public function CMD_Head()
		{
			super();
		}
		
		/*
		 * */
		public static function readData(data:ByteArray):CMD_Head{
			var pos:int=data.position;
			
			var result:CMD_Head=new CMD_Head;
			
			result.cmd_info.byMessageVer=data.readUnsignedByte();
			result.cmd_info.byCheckCode=data.readUnsignedByte();
			result.cmd_info.wPacketSize=data.readUnsignedShort();
			result.cmd_command.wMainCmdID=data.readUnsignedShort();
			result.cmd_command.wSubCmdID=data.readUnsignedShort();
			
			data.position=pos;
			
			return result;
		}
		
		public function toByteArray():ByteArray{
			var result:ByteArray=Memory.newLitteEndianByteArray();
			
			result.writeByte(cmd_info.byMessageVer);
			result.writeByte(cmd_info.byCheckCode);
			result.writeShort(cmd_info.wPacketSize);
			result.writeShort(cmd_command.wMainCmdID);
			result.writeShort(cmd_command.wSubCmdID);
			
			return result;
		}
	}
}