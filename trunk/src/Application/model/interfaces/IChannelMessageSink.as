package Application.model.interfaces
{
	import flash.utils.ByteArray;
	
	public interface IChannelMessageSink
	{
		//处理网络消息
		function OnIPCSocketMessage(wMainCmdID:uint,
								wSubCmdID:uint,
								pBuffer:ByteArray,
								wDataSize:int):Boolean;
		//处理信道消息
		function OnIPCChannelMessage(wMainCmdID:uint,
								  wSubCmdID:uint,
								  pIPCBuffer:*, 
								  wDataSize:uint):Boolean;
	}
}