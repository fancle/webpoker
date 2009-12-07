package Application.model.vo.protocol.login
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GQ_Login_Error
	{
		public static const sizeof_CMD_GQ_Login_Error:uint=4 + 128;
		
		////////////////////////////////////////////////////////////////////
		public var lErrorCode:int;						//错误代码 LONG	
		public var szErrorDescribe:String;				//错误消息 TCHAR[128]
		////////////////////////////////////////////////////////////////////
		
		public function CMD_GQ_Login_Error()
		{
		}	
		
		public static function readData(bytes:ByteArray):CMD_GQ_Login_Error{
			var result:CMD_GQ_Login_Error = new CMD_GQ_Login_Error;
			
			result.lErrorCode = bytes.readInt();
			result.szErrorDescribe = Memory.readStringByByteArray(bytes,128);
			
			return result;
		}
		
		

	}
}