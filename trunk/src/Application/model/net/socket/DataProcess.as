/**
 * socket接收数据处理线程
 * 		1)调用CMD_Handle.analyzeData()来自集中解析解密数据
 *		2)抛给IClientSocketSink实现类去处理具体的消息
 */
package Application.model.net.socket
{
	import Application.model.interfaces.IClientSocket;
	import Application.model.interfaces.IClientSocketSink;
	import Application.model.vo.protocol.CMD_Buffer;
	import Application.model.vo.protocol.CMD_Head;
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
		
	public class DataProcess
	{
		private var _socketSink:IClientSocketSink;//消息处理者
		private var _socketReference:IClientSocket;//clientSocket
		private var baRevBuffer:ByteArray=Memory.newLitteEndianByteArray();//接收数据
		
		public function DataProcess(bytes:ByteArray,socketSink:IClientSocketSink,_socket:IClientSocket)
		{
			_init(bytes,socketSink,_socket);
			//setTimeout(analyzeData,1);
			analyzeData();
		}
		private function _init(bytes:ByteArray,socketSink:IClientSocketSink,_socket:IClientSocket):void{
			Memory.CopyMemory(baRevBuffer,bytes,bytes.length,0,0);
			_socketSink=socketSink;
			_socketReference=_socket;
		}
		/* 解析数据，并抛给IClientSocketSink的实现类去处理 */
		private function analyzeData():void{
			
			var nRevDataSize:int=baRevBuffer.length;
			var i:int = 1;
			while(nRevDataSize>=CMD_Head.sizeof_CMD_Head){
				trace("in DataProcess analyzeData:((((((((((((((((((((((((((((((((((( 循环次数：" + i++);
				//变量定义
				var wPacketSize:int=0;				
				var pHead:CMD_Head=CMD_Head.readData(baRevBuffer);
				//提取出消息头中所存消息包的大小wPacketSize
				wPacketSize=pHead.cmd_info.wPacketSize;
				trace("in DataProcess analyzeData:((((((((((((((((((((((((((((((((((( pHead.cmd_info.wPacketSize=" + pHead.cmd_info.wPacketSize);
				if (pHead.cmd_info.byMessageVer != GlobalDef.SOCKET_VER)
				{
					trace("in DataProcess analyzeData: 数据包版本错误");
					throw Error("数据包版本错误");
				}
				//消息包的大小
				  if (wPacketSize > GlobalDef.SOCKET_PACKAGE + CMD_Head.sizeof_CMD_Head)
				{
					trace("in DataProcess analyzeData: 数据包太大");
					
					throw Error("数据包太大");
				}
				if (nRevDataSize < wPacketSize)
				{
					trace("in DataProcess analyzeData: no more data" + nRevDataSize +"<"+ wPacketSize);
					return;
				}  
				//拷贝数据
				var cbDataBuffer:ByteArray=Memory.newLitteEndianByteArray();
				//把消息包从接收缓冲区里拷贝到cbDataBuffer中
				Memory.CopyMemory(cbDataBuffer,baRevBuffer,wPacketSize);
				//接收缓冲区数据大小改变
				nRevDataSize-= wPacketSize;
				var cbNewRecvBuf:ByteArray=Memory.newLitteEndianByteArray();
				//把接收缓冲区中剩下的数据扔到cbNewRecvBuf中去
				Memory.CopyMemory(cbNewRecvBuf,baRevBuffer,nRevDataSize, 0, wPacketSize);
				//用cbNewRecvBuf来覆盖m_cbRecvBuf,也就是说当前接收缓冲区中存放的读取有用信息之后剩下的东西
				baRevBuffer = cbNewRecvBuf;
				baRevBuffer.position=0;
				analyzePacket(cbDataBuffer);
			}
			dispose();
		}
		
		private function analyzePacket(baDataPacket:ByteArray):void{
			//解析数据
			try{
				var cmdBuffer:CMD_Buffer=_socketReference.getSocketDataHandle().analyzeData(baDataPacket);
			}
			catch(error:Error){
				trace("in DataProcess analyzePacket: error.message = " + error.message);
				return;
			}
			if(cmdBuffer){
				var wMainCmdID:uint=cmdBuffer.cmdHead.cmd_command.wMainCmdID;
				var wSubCmdID:uint=cmdBuffer.cmdHead.cmd_command.wSubCmdID;
				var wDataSize:uint=cmdBuffer.cmdHead.cmd_info.wPacketSize-CMD_Head.sizeof_CMD_Head;				
				var baBuffer:ByteArray=cmdBuffer.baBuffer;
				//将解密后的数据交给IClientSocketSink实现类去处理
				_socketSink.receiveSocketData(wMainCmdID,wSubCmdID,baBuffer,wDataSize);
			}
		}
		
		private function dispose():void{
			baRevBuffer=null;
			_socketSink=null;
		}
	}
}