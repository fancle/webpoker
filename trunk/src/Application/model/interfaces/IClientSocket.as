/**
 * 
 * ClientSocket的接口，在该接口的实现类当中只处理
 * 	建立socket连接、关闭连接、接收上层数据向远程服务器发送、从远程服务器接收数据然后交给上层(IClientSocketSink)去处理、加密组合数据、解密解析验证数据
 * 
 */
package Application.model.interfaces
{
	import flash.utils.ByteArray;
	
	public interface IClientSocket
	{
		function isConnected():Boolean;
		function connect(_ip:String=null,_port:int=0):void;
		function close():void;
		
		function setClientSocketSink(_clientSocketSink:IClientSocketSink):void;
		function getClientSocketSink():IClientSocketSink;
		function getSocketDataHandle():IClientSocketDataHandle;
		
		/* 发送数据 */
		function sendData(wMainCmdID:uint,wSubCmdID:uint,baData:ByteArray,wDataSize:uint):Boolean;
		
		/* 组合加密数据 */
		function processData(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Object;		
	}
}