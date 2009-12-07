package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;
	
	public class CMD_GQ_SitFailed
	{
		public var szFailedDescribe:String;				//错误描述TCHAR[256]
		
		public static function readData(bytes:ByteArray):CMD_GQ_SitFailed{
			var result:CMD_GQ_SitFailed = new CMD_GQ_SitFailed;
			
			result.szFailedDescribe = Memory.readStringByByteArray(bytes,bytes.length);
			
			return result;
		}
		
		public function CMD_GQ_SitFailed()
		{
		}

	}
}