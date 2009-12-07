package Application.model.vo.protocol.system
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class tagClientSerial
	{
		public static const sizeof_tagClientSerial:uint = 4 + 4*3;
		
		public var dwSystemVer:uint;
		public var dwComputerID:Array=new Array(3);
		
		public function tagClientSerial()
		{
		}
		
		public function toByteArray():ByteArray{
			var result:ByteArray=Memory.newLitteEndianByteArray();
			
			result.writeUnsignedInt(dwSystemVer);
			for(var i:int=0;i<3;i++){
				result.writeUnsignedInt(dwComputerID[i]);
			}
			
			return result;
		}
	}
}