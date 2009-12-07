package Application.model.interfaces
{
	import Application.model.vo.protocol.CMD_Buffer;
	
	import flash.utils.ByteArray;
	
	public interface IClientSocketDataHandle
	{
		function processData(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Object;
		function analyzeData(bytes:ByteArray):CMD_Buffer;
		function reset():void//重置数据
		function dispose():void;//释放资源
	}
}