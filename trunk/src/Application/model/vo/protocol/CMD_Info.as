package Application.model.vo.protocol
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_Info
	{
		public static const sizeof_CMD_Info:int=1+1+2;
		
		public var byMessageVer:uint;//版本号
		public var byCheckCode:uint;//效验字段
		public var wPacketSize:uint;//数据大小
		
		public function CMD_Info()
		{
			super();
		}
		public static function readData(bytes:ByteArray):CMD_Info{
			var result:CMD_Info = new CMD_Info;
			
			result.byMessageVer = bytes.readUnsignedByte();
			result.byCheckCode = bytes.readUnsignedByte();
			result.wPacketSize = bytes.readUnsignedShort();
			
			return result;
		} 
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeByte(byMessageVer);
			result.writeByte(byCheckCode);
			result.writeShort(wPacketSize);
			
			return result;
		}
	}
}