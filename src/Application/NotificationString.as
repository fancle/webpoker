package Application{

	public class NotificationString{
		//系统通知
	 	public static const STARTUP:String = "startup"; //启动系统
	 	public static const LOAD_MODULE_COMPLETE:String = "load_module_complete";//加载模块完成
		public static const LOAD_LOGIN_MODULE:String = "load_login_module";//加载登陆模块
		public static const RESIZE:String = "resize";//舞台尺寸的改变
		public static const LOAD_EVENT:String = "load_event";//加载进度通知  三种状态0表示开始加载 1表示正在加载进度 2表示结束加载 只有 1的时候需要传递后边的值       bytesLoaded   bytesTotal
		public static const LOAD_CONFIG:String = "load_config";//加载配置文件
		public static const LOAD_CONFIG_COMPLETE:String = "load_config_complete";//配置文件加载完成
		public static const CONNECT_LOADING:String = "connect_loading"; //加载网路连接的显示 2种状态 0表示开始加载 1表示卸载
		public static const ALERT:String = "alert";//提示信息  消息体中发送的是{title:提示信息，text:说明内容，closeHandler:回调函数}  消息类型 默认为确定按钮    0 为确定|取消按钮 
		public static const POSTS_EVENT:String = "posts_event";//公告通知 0为显示公告 1为关闭公告
		public static const LOAD_GAME:String = "load_game";//加载单个游戏资源及素材
		public static const LOAD_GAME_MODULE_COMPLETE:String = "load_game_module_complete";//加载单个游戏某块完毕
		
		//发送命令
		public static const LOGIN_SUCCESS:String="login_success";//帐户核对正确 登陆成功 消息体为附送过来的用户信息 tagGlobalUserData类
	 	public static const LOGIN_FAIL:String = "login_fail";//登陆失败
	 	
	 	//进入旅游房间
	 	public static const GAME_ROOM_SUCCESS:String = "game_room_success";//进入游戏房间成功
	 	public static const GAME_ROOM_INIT_DATA:String = "game_room_init_data";//游戏房间初始数据
	 	public static const GAME_ROOM_DATA:String = "game_room_data";//房间接收数据
	 	
	 	//房间socket关闭
	 	public static const ROOM_SOCKET_CLOSE:String = "game_socket_close";
	 	
	 	//游戏框架相关
	 	public static const MSG_GAMEFRAME:String = "msg_gameFrame";//在游戏框架当中显示消息
	 	public static const MSG_MATCHOVER:String = "msg_matchOver";//比赛场中比赛结束的奖状
	 	
	 	//
	 	public static const GAME_FRAME_PROPERTY:String = "game_frame_property";//道具
	 	
	 	//////////////////////////////////////////////////////////////////////////////////////////////////////
	 	
	 	/**
	 	 * ============================================================================================
	 	 * --------------------------------------zhang------------------------------------------------
	 	 * ============================================================================================
	 	 */
	 	//socket连接
	 	public static const CONNECT_SOCKET:String="connect_socket";//建立socket连接 可能有N个状态 "login"表示登录socket "hall"表示大厅socket
	 	public static const SOCKET_CONNECT_ERROR:String =  "socket_connect_error";//socket连接错误 可能有2个状态：0表示socket的ioError或者securityError 1表示连接超时
	 	public static const SOCKET_CONNECTED:String="Socket_connect";//socket已经建立,type参数来指示是什么socket
	 	//登录相关
	 	public static const CMD_LOGIN_ACCOUNT:String="cmd_login_account";//帐户登录信息
	 	//游戏列表相关
	 	public static const CMD_SERVER_LIST:String = "cmd_server_list";//进入大厅时的初始化信息 type为游戏列表命令码的子命令号
	 	//游戏相关
	 	public static const CMD_ROOM_LOGIN:String = "cmd_room_login";//进入房间的时候的登录
	 	public static const CMD_ROOM_USER:String = "cmd_room_user";//用户信息
	 	public static const CMD_ROOM_INFO:String = "cmd_room_info";//配置信息
	 	public static const CMD_ROOM_STATUS:String = "cmd_room_status";//房间状态信息
	 	public static const CMD_ROOM_MESSAGE:String = "cmd_room_message";//房间消息
	 	public static const CMD_ROOM_PRESENT:String = "cmd_room_present";//礼物信息
	 	public static const CMD_ROOM_SERVER_INFO:String = "cmd_room_server_info";//大厅游戏人数更新
	 	public static const CMD_GAME_ROOM:String = "cmd_game_room";//进入游戏界面时的初始化信息 	
	 	
	 	//游戏框架相关	 	
	 	public static const CMD_GAME_FRAME:String = "cmd_game_frame";//启动或者移除游戏框架 type为："regist"/"remove"
	 	public static const CMD_FRAME_USER:String = "cmd_frame_user";
	 	
	 	public static const IPC_KERNEL:String = "ipc_kernel";
	 	public static const IPC_CONTROL:String = "ipc_control";//
	 	public static const IPC_PROPERTY:String = "ipc_property";//
	 	
	 	/**
	 	 * ============================================================================================
	 	 * ---------------------------------------lu------------------------------------------------
	 	 * ============================================================================================
	 	 */
	     public static const LOGOUT:String = "logout"//切换用户注销操作
	     public static const ROOM_LOGIN:String = "room_login";//房间登录成功
	     public static const OPEN_WISPER:String = "open_wisper";//打开私聊视窗
	     public static const SHOW_USERINFO:String = "show_userinfo";//打开用户信息
	     public static const CLOSE_USERINFO:String = "close_userinfo";//关闭用户信息
	     public static const EXIT_ROOM:String = "exit_room";//退出房间
	     public static const UPDATE_ONLINECOUNT:String = "update_onlineCount";//更新总人娄
	     
	     public static const TEST_GAME_LOGIN:String = "test_game_login";//测试游戏框架进入命令
	     
	 	/**
	 	 * ============================================================================================
	 	 * ---------------------------------------kang------------------------------------------------
	 	 * ============================================================================================
	 	 */
	 	 
	 	 public static const CHAT_INPUT:String = "chat_input"//接收公共聊消息；
	 	 public static const WISPER_INPUT:String = "wisper_input"//接收私聊消息；
	 	 public static const INIT_WISPER_DATA:String = "init_wisper_data";//初始化私聊信息
	 	 public static const CLOSE_WISPER:String = "close_wisper";//关闭私聊视窗
	 	 public static const CHANGE_MSG_ALERT:String = "change_msg_alert";//改变新消息按钮提示状态
	 	 public static const START_MSG_ALERT:String = "start_msg_alert";//开启新消息提示功能
	 	 public static const CLOSE_MSG_ALERT:String = "close_msg_alert";//关闭新消息提示功能
	 	 public static const READ_MSG_ALERT:String = "read_msg_alert";//读取新消息，并删除新消息相应用户
	 	 //---------------------------GAME-------------------------->>
	 	 public static const GAME_CHAT_INPUT:String = "game_chat_input";
	 	 
	 	public function NotificationString(){	 		
	 	}
	}
}