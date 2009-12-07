package Application.model.net.socket
{
	import Application.model.interfaces.IClientSocket;
	import Application.model.interfaces.IClientSocketDataHandle;
	import Application.model.interfaces.IClientSocketSink;
	import Application.model.vo.protocol.CMD_Buffer;
	import Application.model.vo.protocol.CMD_Head;
	import Application.utils.Memory;
	
	import common.assets.ModuleLib;
	import common.data.GlobalDef;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;

	public class ClientSocket extends EventDispatcher implements IClientSocket
	{
		private var _socket:Socket;
		private var _hostIP:String;
		private var _hostPort:int;
		
		private var _socketSink:IClientSocketSink;
		private var _socketDataHandle:IClientSocketDataHandle;
		private var isFirstMsg:Boolean = false;//是否第一次接收到消息
		
		private var timer:Timer;//连接时启动计时，以超时退出
		
		protected var m_cbRecvBuf:ByteArray=Memory.newLitteEndianByteArray();//接收缓冲
		protected var m_wRecvSize:int;//接收长度
		/**
		 * ============================================================================
		 * ----------------------------------初始化------------------------------------
		 * ============================================================================
		 */
		public function ClientSocket()
		{
			_initObj();
		}
		private function _initObj():void{
			timer=new Timer(GlobalDef.SOCKET_CONNECT_TIMEROUT_DELAY,GlobalDef.SOCKET_CONNECT_TIMEROUT_COUNT);
			timer.addEventListener(TimerEvent.TIMER,_timerListener);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,_timerListener);
			
			//初始化数据处理类
			var CMD_Handle:Class = (ModuleLib.getInstance().lib.find("HandleBean") as ApplicationDomain).getDefinition("CMD_Handle") as Class;
			_socketDataHandle = new CMD_Handle;
			
			_initSocket();
		}
		private function _initSocket():void{
			if(!_socket){
				_socket=new Socket;
				_socket.endian=Endian.LITTLE_ENDIAN;
				
				_socket.addEventListener(Event.CONNECT,_socketListener);
				_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,_socketListener);
				_socket.addEventListener(ProgressEvent.SOCKET_DATA,_socketListener);
				_socket.addEventListener(IOErrorEvent.IO_ERROR,_socketListener);
				_socket.addEventListener(Event.CLOSE,_socketListener); 
			}
		}
		/**
		 * ============================================================================
		 * ----------------------------------外部调用-----------------------------------
		 * ============================================================================
		 */
		//设置消息处理者
		public function setClientSocketSink(_clientSocketSink:IClientSocketSink):void
		{
			_socketSink=_clientSocketSink;
		}
		//得到消息处理者
		public function getClientSocketSink():IClientSocketSink
		{
			if(_socketSink) return _socketSink;
			return null;
		}
		public function getSocketDataHandle():IClientSocketDataHandle{
			return _socketDataHandle;
		}
		//判断是否已经连接
		public function isConnected():Boolean
		{
			if(_socket){
				if(_socket.connected) return true;
			}
			return false;
		}
		//连接
		public function connect(_ip:String=null, _port:int=0):void
		{
			if(!_socket) _initObj();
			
			if(_ip!=null) _hostIP=_ip;
			if(_port!=0) _hostPort=_port;
					
			try{
				if(GlobalDef.DEBUG)trace("in ClientSocket connect: start connect");
				if(_ip==null||_port==0){
					_socket.connect(_hostIP,_hostPort);
				}
				else{
					_socket.connect(_ip,_port);
				}
				timer.start();//启动计时
			}
			catch(error:Error){
				if(GlobalDef.DEBUG)trace("in ClientSocket connect:error.message=" + error.message);
			}
		}
		//发送
		public function send(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Boolean{
			return sendData(wMainCmdID,wSubCmdID,baData,wDataSize);
		}
		//关闭
		public function close():void
		{
			dispose();
		}
		//////////////////////////////////////////////////////////
		//资源释放
		public function dispose():void{
			reset();
			//清除socket事件侦听
			if(_socket.hasEventListener(Event.CONNECT)) _socket.removeEventListener(Event.CONNECT,_socketListener);
			if(_socket.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,_socketListener);
			if(_socket.hasEventListener(ProgressEvent.SOCKET_DATA)) _socket.removeEventListener(ProgressEvent.SOCKET_DATA,_socketListener);
			if(_socket.hasEventListener(IOErrorEvent.IO_ERROR)) _socket.removeEventListener(IOErrorEvent.IO_ERROR,_socketListener);
			if(_socket.hasEventListener(Event.CLOSE)) _socket.removeEventListener(Event.CLOSE,_socketListener);
			
			//释放Socket资源
			if(_socket.connected){
				_socket.close();
			}
			_socket=null;
			
			m_cbRecvBuf.clear();
			m_wRecvSize = 0;
			
			//清除其它保存的引用
			_socketDataHandle.dispose();
			_socketDataHandle=null;			
			
			if(timer.hasEventListener(TimerEvent.TIMER)) timer.removeEventListener(TimerEvent.TIMER,_timerListener);
			if(timer.hasEventListener(TimerEvent.TIMER_COMPLETE)) timer.removeEventListener(TimerEvent.TIMER_COMPLETE,_timerListener);
			
			if(timer.running) timer.reset();
			
			timer=null;
		}
			
		/**
		 * ============================================================================
		 * ----------------------------------功能函数-----------------------------------
		 * ============================================================================
		 */
		private function socketDataHandle():void{
			if(_socket.bytesAvailable>0){
				try{
					//读取数据
					var iRetCode:int=_socket.bytesAvailable;
	
					//将socket中的数据读入接收缓冲区m_cbRecvBuf中
					_socket.readBytes(m_cbRecvBuf,m_wRecvSize,iRetCode);
					//m_wRecvSize在connect时初始化为0,iRetCode为接收数据的长度
					m_wRecvSize+= iRetCode;
					var i:int = 1;
					
					while(m_wRecvSize>=CMD_Head.sizeof_CMD_Head){
						if(GlobalDef.DEBUG)trace("in ClientSocket analyzeData:((((((((((((((((((((((((((((((((((( 循环次数：" + i++);
						//变量定义
						var wPacketSize:int=0;				
						var pHead:CMD_Head=CMD_Head.readData(m_cbRecvBuf);
						//提取出消息头中所存消息包的大小wPacketSize
						wPacketSize=pHead.cmd_info.wPacketSize;
						if(GlobalDef.DEBUG)trace("in ClientSocket analyzeData:((((((((((((((((((((((((((((((((((( pHead.cmd_info.wPacketSize=" + pHead.cmd_info.wPacketSize);
						if (pHead.cmd_info.byMessageVer != GlobalDef.SOCKET_VER)
						{
							trace("in ClientSocket analyzeData: 数据包版本错误");
							throw Error("数据包版本错误");
						}
						//消息包的大小
						if (wPacketSize > GlobalDef.SOCKET_PACKAGE + CMD_Head.sizeof_CMD_Head)
						{
							if(GlobalDef.DEBUG)trace("in ClientSocket analyzeData: 数据包太大");
							
							throw Error("数据包太大");
						}
						if (m_wRecvSize < wPacketSize)
						{
							if(GlobalDef.DEBUG)trace("in ClientSocket analyzeData: no more data" + m_wRecvSize +"<"+ wPacketSize);
							return;
						}  
						/* 拷贝数据 */
						var cbDataBuffer:ByteArray=Memory.newLitteEndianByteArray();
						//把消息包从接收缓冲区里拷贝到cbDataBuffer中
						Memory.CopyMemory(cbDataBuffer,m_cbRecvBuf,wPacketSize);
						//接收缓冲区数据大小改变
						m_wRecvSize-= wPacketSize;
						var cbNewRecvBuf:ByteArray=Memory.newLitteEndianByteArray();
						//把接收缓冲区中剩下的数据扔到cbNewRecvBuf中去
						Memory.CopyMemory(cbNewRecvBuf,m_cbRecvBuf,m_wRecvSize, 0, wPacketSize);
						//用cbNewRecvBuf来覆盖m_cbRecvBuf,也就是说当前接收缓冲区中存放的读取有用信息之后剩下的东西
						m_cbRecvBuf = cbNewRecvBuf;
						m_cbRecvBuf.position=0;
						analyzePacket(cbDataBuffer);
					}
				}
				catch(error:Error){
					
				}
			}			
		}
		private function analyzePacket(baDataPacket:ByteArray):void{
			//解析数据
			try{
				var cmdBuffer:CMD_Buffer=getSocketDataHandle().analyzeData(baDataPacket);
			}
			catch(error:Error){
				if(GlobalDef.DEBUG)trace("in ClientSocket analyzePacket: error.message = " + error.message);
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
		
		///////////////////////////////////////////////////////////////////////
		
		/* 发送命令数据 */
		public function sendData(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Boolean
		{
			//var bytes:ByteArray=processData(wMainCmdID,wSubCmdID,baData,wDataSize);
			var obj:Object = processData(wMainCmdID,wSubCmdID,baData,wDataSize);
			var bytes:ByteArray;
			var wSendDataSize:int;
			
			if(obj){
				bytes = obj["dataBuffer"];
				bytes.position = 0;
				wSendDataSize = obj["sendDataSize"];
			}
			
			if(bytes&&_socket.connected){
				_socket.writeBytes(bytes,0,wSendDataSize);
				_socket.flush();
				return true;
				if(GlobalDef.DEBUG)trace("in ClientSocket sendData: send socket data success -- bytes.length=" + bytes.length);
			}				
			return false;	
		}	
		/* 处理将要发送的数据----对它们进行整合加密等 */
		public function processData(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Object
		{
			if(getSocketDataHandle()!=null){
				return getSocketDataHandle().processData(wMainCmdID,wSubCmdID,baData,wDataSize);
			}
			return null;
		}
		/////////////////////////socket的事件处理函数////////////////////////////////
		private function connectHandle():void{
			if(GlobalDef.DEBUG)trace("in ClientSocket conectHandle:receive connect event");
			if(!isFirstMsg){
				//发送_socket连接的事件
				dispatch(ClientSocketEvent.SOCKET_CONNECT);
				if(timer.running) timer.reset();//停止计时				
			}
		}
		private function errorHandle():void{
			if(GlobalDef.DEBUG)trace("in ClientSocket errorHandle: connect securityError event");
			close();
			dispatch(ClientSocketEvent.SOCKET_ERROR);			
		}
		private function closeHandle():void{
			if(GlobalDef.DEBUG)trace("in ClientSocket closeHandle:connect close event");
			dispatch(ClientSocketEvent.SOCKET_CLOSE);
			dispose();
		}
		private function reset():void{
			//数据处理类重置
			_socketDataHandle.reset();
			//连接计数重置
			if(timer.running) timer.reset();//停止计时			
		}
		/////////////////////////////////////////////////////////////
		//调度事件
		private function dispatch(type:String):Boolean {
			return dispatchEvent(new ClientSocketEvent(type)); 
		}
		/**
		 * ============================================================================
		 * ----------------------------------侦听器-------------------------------------
		 * ============================================================================
		 */
		private function _socketListener(evt:Event):void{
			switch(evt.type){
				case Event.CONNECT:{
					connectHandle();
					break;
				}
				case SecurityErrorEvent.SECURITY_ERROR:
				case IOErrorEvent.IO_ERROR:{
					errorHandle();
					if(GlobalDef.DEBUG)trace("in ClientSocket _socketListener:" + evt);
					
					break;
				}
				case ProgressEvent.SOCKET_DATA:{
					if(GlobalDef.DEBUG)trace("in ClientSocket _socketListener:receive SOCKET_DATA event");
					if (isFirstMsg) {
						//服务器端在第一次收到连接请求“<policy-file-request/>”后，会向客户端发送策略文件-------如果不发，则此模块出现错误
						var tempStr:String="";
						while (_socket.bytesAvailable>0) {
							tempStr+=_socket.readUTFBytes(_socket.bytesAvailable);							
						}
						//发送_socket正式连接的事件
						dispatch(ClientSocketEvent.SOCKET_CONNECT);
						if(timer.running) timer.reset();//停止计时
						
						isFirstMsg = false;
						return;
					}
					
					socketDataHandle();
					break;
				}
				case Event.CLOSE:{
					closeHandle();
					break;
				}
			}
		}
		private function _timerListener(evt:TimerEvent):void{
			switch(evt.type){
				case TimerEvent.TIMER:{
					this.connect();
					break;
				}
				case TimerEvent.TIMER_COMPLETE:{
					close();
					dispatch(ClientSocketEvent.SOCKET_TIMEOUT);
					break;
				}
			}
		}
	}
}