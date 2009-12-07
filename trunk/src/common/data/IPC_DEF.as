package common.data
{
	public class IPC_DEF
	{
		//////////////////////////////////////////////////////////////////////////
		//内核主命令码
		public static const IPC_MIAN_IPC_KERNEL:uint=0;//内核命令
		
		//内核子命令码
		public static const IPC_SUB_IPC_CLIENT_CONNECT:uint=1;//连接通知
		public static const IPC_SUB_IPC_SERVER_ACCEPT:uint=2;//应答通知
		public static const IPC_SUB_IPC_CLIENT_CLOSE:uint=3;//关闭通知
		public static const IPC_SUB_IPC_MESSAGE:uint = 4;//消息
		
		//////////////////////////////////////////////////////////////////////////
		//IPC 配置信息
		
		public static const IPC_MAIN_CONFIG:int=2;//配置信息
		
		public static const IPC_SUB_SERVER_INFO:int=1;//房间信息
		public static const IPC_SUB_COLUMN_INFO:int=2;//列表信息
		
		//////////////////////////////////////////////////////////////////////////
		//IPC 控制信息
		
		public static const IPC_MAIN_CONTROL:int=4;//控制信息
		
		public static const IPC_SUB_START_FINISH:int=1;//启动完成
		public static const IPC_SUB_CLOSE_FRAME:int=2;//关闭框架
		public static const IPC_SUB_CLOSE_GAMECLIENT:int = 3;//关闭游戏
		public static const IPC_SUB_CLOSE_SOUND:int = 10;//关闭游戏音乐
		public static const IPC_SUB_OPEN_SOUND:int = 11;//打开游戏音乐
		
		//////////////////////////////////////////////////////////////////////////
		//IPC 用户信息
		
		public static const IPC_MAIN_USER:int=3;//用户信息

		public static const IPC_SUB_USER_COME:int=1;//用户信息
		public static const IPC_SUB_USER_STATUS:int=2;//用户状态
		public static const IPC_SUB_USER_SCORE:int=3;//用户积分
		public static const IPC_SUB_GAME_START:int=4;//游戏开始
		public static const IPC_SUB_GAME_FINISH:int=5;//游戏结束
		
		//////////////////////////////////////////////////////////////////////////
		//IPC 道具消息
		
		public static const IPC_MAIN_PROPERTY:int = 5;//道具消息
		
		public static const IPC_SUB_PROPERTY_SEND:int = 1;//发送
		public static const IPC_SUB_PROPERTY_RECV:int = 2;//接收
		
		//////////////////////////////////////////////////////////////////////////
		
		public function IPC_DEF()
		{
		}

	}
}