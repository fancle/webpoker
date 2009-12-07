package Application.model.vo.protocol.login
{
	import flash.utils.ByteArray;
	
	public class CMD_GQ_ListConfig
	{
		public static const sizeof_CMD_GQ_ListConfig:uint = 1;
		public var bShowOnLineCount:Boolean;//显示人数 BYTE
		
		public static function readData(bytes:ByteArray):CMD_GQ_ListConfig{
			var listConfig:CMD_GQ_ListConfig = new CMD_GQ_ListConfig;
			
			listConfig.bShowOnLineCount = bytes.readBoolean();
			
			return listConfig;
		}
		
		public function CMD_GQ_ListConfig()
		{
		}

	}
}