package Application
{
	import Application.control.GameCmd;
	import Application.control.LoadGameCmd;
	import Application.control.alert.AlertCmd;
	import Application.control.connect.ConnectSocketCmd;
	import Application.control.game.GameModuleCmd;
	import Application.control.loaderpane.ConnectLoadCmd;
	import Application.control.loaderpane.LoaderPaneCmd;
	import Application.control.login.LogoutCmd;
	import Application.control.login.loginInitCmd;
	import Application.control.login.loginSuccessCmd;
	import Application.control.net.CMD_LoginAccountCmd;
	import Application.control.net.CMD_ServerListCmd;
	import Application.control.net.SocketErrorCmd;
	import Application.control.net.gameFrame.CMD_FrameUserCmd;
	import Application.control.net.gameFrame.CMD_RoomGameFrameCmd;
	import Application.control.net.gameFrame.IPC_ControlCmd;
	import Application.control.net.gameFrame.IPC_KernelCmd;
	import Application.control.net.gameFrame.IPC_PropertyCmd;
	import Application.control.net.room.CMD_GameRoomCmd;
	import Application.control.net.room.CMD_GameRoomInfoCmd;
	import Application.control.net.room.CMD_RoomLoginCmd;
	import Application.control.net.room.CMD_RoomMessageCmd;
	import Application.control.net.room.CMD_RoomPresentCmd;
	import Application.control.net.room.CMD_RoomServerInfoCmd;
	import Application.control.net.room.CMD_RoomTableCmd;
	import Application.control.net.room.CMD_RoomUserCmd;
	import Application.control.titlewindow.TitleWindowCmd;
	import Application.model.game.GameManagerProxy;
	import Application.view.componentView.loaderpane.connectLoad;
	import Application.view.componentView.loaderpane.loadPane;
	import Application.view.componentView.titlewindow.titleWindow;
	import Application.view.mediator.loaderpane.ConnectLoadMediator;
	import Application.view.mediator.loaderpane.LoaderPaneMediator;
	import Application.view.mediator.titlewindow.titleWindowMediator;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade; 
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		
		public static function getInstance(key:String):ApplicationFacade{
            if ( instanceMap[ key ] == null ) instanceMap[ key ] = new ApplicationFacade( key );
            return instanceMap[ key ] as ApplicationFacade;
		}
		
		public function ApplicationFacade(key:String)
		{
			super(key);
		}
		
		override protected function initializeController():void{
			super.initializeController();			
		    registerCommand(NotificationString.STARTUP,GameCmd);//系统初始化 
			registerCommand(NotificationString.LOAD_LOGIN_MODULE, loginInitCmd);//登陆初始化
			registerCommand(NotificationString.LOAD_EVENT,LoaderPaneCmd);//加载面板初始化
			registerCommand(NotificationString.CONNECT_LOADING,ConnectLoadCmd);//网络连接面板初始化
			registerCommand(NotificationString.ALERT,AlertCmd);//提示面板初始化
			registerCommand(NotificationString.LOGIN_SUCCESS,loginSuccessCmd);//登陆成功初始化
			
			registerCommand(NotificationString.POSTS_EVENT,TitleWindowCmd);//公告板
			registerCommand(NotificationString.LOAD_GAME,LoadGameCmd);//加载单个游戏module及素材
			registerCommand(NotificationString.LOAD_GAME_MODULE_COMPLETE,GameModuleCmd);//加载成功单个游戏素材及游戏
			//============================================zhang=============================================
			registerCommand(NotificationString.CONNECT_SOCKET,ConnectSocketCmd);//连接socket命令--根据参数来决定连接登录socket还是大厅socket
			registerCommand(NotificationString.SOCKET_CONNECT_ERROR,SocketErrorCmd);//socket连接出现错误--根据参数来确定是什么类型错误
			
			registerCommand(NotificationString.CMD_LOGIN_ACCOUNT,CMD_LoginAccountCmd);//发送登录信息给服务器(通过socket)
			registerCommand(NotificationString.CMD_SERVER_LIST,CMD_ServerListCmd);//关于登录之后发送的游戏列表相关信息
			registerCommand(NotificationString.CMD_GAME_ROOM,CMD_GameRoomCmd);//进入游戏房间命令
			//游戏房间相关
			registerCommand(NotificationString.CMD_ROOM_LOGIN,CMD_RoomLoginCmd);//进入游戏房间前的登录
			registerCommand(NotificationString.CMD_ROOM_INFO,CMD_GameRoomInfoCmd);//房间配置
			registerCommand(NotificationString.CMD_ROOM_USER,CMD_RoomUserCmd);//房间里的用户信息
			registerCommand(NotificationString.CMD_ROOM_STATUS,CMD_RoomTableCmd);//房间桌子信息及状态
			registerCommand(NotificationString.CMD_ROOM_MESSAGE,CMD_RoomMessageCmd);//房间桌子信息及状态
			registerCommand(NotificationString.CMD_ROOM_PRESENT,CMD_RoomPresentCmd);//房间礼物信息
			registerCommand(NotificationString.CMD_ROOM_SERVER_INFO,CMD_RoomServerInfoCmd);//游戏人数更新
			//游戏框架相关
			registerCommand(NotificationString.CMD_GAME_FRAME,CMD_RoomGameFrameCmd);//注册或者移除框架接口
			registerCommand(NotificationString.CMD_FRAME_USER,CMD_FrameUserCmd);//
			
			registerCommand(NotificationString.IPC_KERNEL,IPC_KernelCmd);
			registerCommand(NotificationString.IPC_CONTROL,IPC_ControlCmd);
			registerCommand(NotificationString.IPC_PROPERTY,IPC_PropertyCmd);
			
			//=============================================lu===============================================
			registerCommand(NotificationString.LOGOUT,LogoutCmd);
			//=============================================kang=============================================
		}
		override protected function initializeView():void{
			super.initializeView();			
			registerMediator(new LoaderPaneMediator(new loadPane()));//注册加载面板	
			registerMediator(new ConnectLoadMediator(new connectLoad()));//注册网络连接显示面板	
		    registerMediator(new titleWindowMediator(new titleWindow()));//注册弹出面板
		}
		override protected function initializeModel():void{
			super.initializeModel();
			registerProxy(new GameManagerProxy());
		}
		//启动系统 
		public function startup(app:game):void{
			sendNotification(NotificationString.STARTUP,app);//发送启动通知			    
		}
	}
}