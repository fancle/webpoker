package Application.model.net.socket
{
	import Application.model.interfaces.IClientSocketSink;
	
	import common.data.CMD_DEF_HALL;
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class ClientSocketSinkBase extends Proxy implements IClientSocketSink,IProxy
	{
		public static var instance:ClientSocketSinkBase;
		
		private var _clientSocket:ClientSocket;
		private var _hostIP:String;
		private var _hostPort:uint;
		
		public function ClientSocketSinkBase(_ip:String,_port:uint,_proxyName:String,_proxyData:Object=null)
		{
			super(_proxyName,_proxyData);
			
			_init(_ip,_port);
		}
		private function _init(_ip:String,_port:uint):void{
			setHostIP(_ip);
			setHostPort(_port);
			
			_initSocket();
			_configSocketListener();
		}
		private function _initSocket():void{
			_clientSocket=new ClientSocket;
			_clientSocket.setClientSocketSink(this);
		}
		private function _configSocketListener():void{
			_clientSocket.addEventListener(ClientSocketEvent.SOCKET_CONNECT,_clientSocketListener);
			_clientSocket.addEventListener(ClientSocketEvent.SOCKET_ERROR,_clientSocketListener);
			_clientSocket.addEventListener(ClientSocketEvent.SOCKET_CLOSE,_clientSocketListener);
			_clientSocket.addEventListener(ClientSocketEvent.SOCKET_TIMEOUT,_clientSocketListener);		
		}
		/**
		 * ====================================================
		 * ----------------------------------------------------
		 * ====================================================
		 */
		private function setHostIP(_ip:String):void{
			_hostIP=_ip;
		}
		private function setHostPort(_port:uint):void{
			_hostPort=_port;
		}
		private function getHostIP():String{
			return _hostIP;
		}
		private function getHostPort():uint{
			return _hostPort;
		}
		/**
		 * ====================================================
		 * ----------------------------------------------------
		 * ====================================================
		 */
		public function isContented():Boolean{
			if(_clientSocket.isConnected()) return true;
			return false;
		}
		public function connect():void{
			if(_clientSocket.isConnected()){
				_clientSocket.close();
			}
			
			_clientSocket.connect(this.getHostIP(),this.getHostPort());
		}
		public function close():void{
			if(_clientSocket.isConnected()){
				_clientSocket.close();
			}
		}
		/**
		 * 四个参数分别为：主命令号、子命令号、数据实体、数据实体大小
		 * 
		 */
		public function send(wMainCmdID:uint, wSubCmdID:uint, baData:ByteArray, wDataSize:uint):Boolean{
			return _clientSocket.send(wMainCmdID,wSubCmdID,baData,wDataSize);
		}
		/* 注册为socket消息处理类 */
		/* public function registerSocketDataHandle():void{
			
		} */
		protected function changeHost(_ip:String,_port:uint):void{
			setHostIP(_ip);
			setHostPort(_port);
		}
		//释放资源
		public function dispose():void{
			//清除socket事件侦听
			if(_clientSocket.hasEventListener(ClientSocketEvent.SOCKET_CONNECT)){
				 _clientSocket.removeEventListener(ClientSocketEvent.SOCKET_CONNECT,_clientSocketListener);
			}
			if(_clientSocket.hasEventListener(ClientSocketEvent.SOCKET_ERROR)){
				 _clientSocket.removeEventListener(ClientSocketEvent.SOCKET_ERROR,_clientSocketListener);
			}
			if(_clientSocket.hasEventListener(ClientSocketEvent.SOCKET_CLOSE)){
				 _clientSocket.removeEventListener(ClientSocketEvent.SOCKET_CLOSE,_clientSocketListener);
			}
			if(_clientSocket.hasEventListener(ClientSocketEvent.SOCKET_TIMEOUT)){
				 _clientSocket.removeEventListener(ClientSocketEvent.SOCKET_TIMEOUT,_clientSocketListener);
			}
			//释放clientSocket资源
			_clientSocket.dispose();
			
			//清除其它保存的引用
			
		}
		
		protected function connectHandle():void{
			
		}
		protected function errorHandle():void{
			
		}
		protected function closeHandle():void{
			
		}
		protected function timeoutHandle():void{
			
		}
		/**
		 * ====================================================
		 * ------------------------侦听器----------------------
		 * ====================================================
		 */
		private function _clientSocketListener(evt:ClientSocketEvent):void{
			switch(evt.type){
				case ClientSocketEvent.SOCKET_CONNECT:{
					connectHandle();
					break;
				}
				case ClientSocketEvent.SOCKET_ERROR:{
					errorHandle();
					break;
				}
				case ClientSocketEvent.SOCKET_CLOSE:{
					closeHandle();
					break;
				}
				case ClientSocketEvent.SOCKET_TIMEOUT:{
					timeoutHandle();
					break;
				}
			}
		}
		/**
		 * ====================================================
		 * -------------------覆盖接口方法----------------------
		 * ====================================================
		 */
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		override public function getProxyName():String
		{
			return null;
		}
		
		override public function setData(data:Object):void
		{
		}
		
		override public function getData():Object
		{
			return null;
		}
		
		override public function onRegister():void
		{
		}
		
		override public function onRemove():void
		{
		}
		
		////////////////////////////////////////////////////////////////////////
		/* ------------------------------------------------------------------ */
		public function receiveSocketData(wMainCmdID:uint, wSubCmdID:uint, baBuffer:ByteArray, wDataSize:uint):void
		{
			if(GlobalDef.DEBUG)trace("in ClientSocketBase receiveSocketData:------------------------------- wMainCmdID = " + wMainCmdID);
			if(GlobalDef.DEBUG)trace("in ClientSocketBase receiveSocketData:------------------------------- wSubCmdID = " + wSubCmdID);
			//内核命令
			if(wMainCmdID == CMD_DEF_HALL.MDM_KN_COMMAND){
				switch(wSubCmdID){
					//网络检测
					case CMD_DEF_HALL.SUB_KN_DETECT_SOCKET:{
						send(CMD_DEF_HALL.MDM_KN_COMMAND, CMD_DEF_HALL.SUB_KN_DETECT_SOCKET, baBuffer, wDataSize);
						break;
					}
				}
			} 
			
		}
	}
}