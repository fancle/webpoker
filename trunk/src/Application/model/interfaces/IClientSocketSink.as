package Application.model.interfaces
{
	import flash.utils.ByteArray;
	
	public interface IClientSocketSink
	{
		//参数介绍，wMainCmdID:主命令号、wSubCmdID:子命令号、baBuffer:真正数据、wDataSize:真正数据的长度
		function receiveSocketData(wMainCmdID:uint,wSubCmdID:uint,baBuffer:ByteArray,wDataSize:uint):void;
	}
}