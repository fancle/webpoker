package Application.model.interfaces
{
	import flash.utils.ByteArray;
	
	public interface ISocketDataSink
	{
		function RecvSocketData(wMainCmdID:uint, wSubCmdID:uint, pBuffer:ByteArray, wDataSize:int):Boolean;
	}
}