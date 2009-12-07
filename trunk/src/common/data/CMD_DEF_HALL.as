/**
 * 主命令
 * 	子命令
 * 
 * 请求命令：GP="GAME RESPONSE"
 * 响应命令：GQ="GAME REQEST"
 */
package common.data
{
	public class CMD_DEF_HALL
	{
		//内核命令码
		public static const MDM_KN_COMMAND:int = 0									//内核命令
		public static const SUB_KN_DETECT_SOCKET:int = 1							//检测命令
		public static const SUB_KN_SHUT_DOWN_SOCKET:int = 2							//中断网络
		
		//////////////////////////////////////////////////////////////////////////
		//登录命令码
		public static const MDM_GR_LOGON:int = 1;//登录
		
		public static const SUB_GP_LONON_FLASH:int = 80;//flash版登录
		public static const SUB_GP_LOGON_ACCOUNT:int = 1;//帐号登录
		public static const SUB_GQ_LOGON_SUCCESS:int = 100;//登陆成功
		public static const SUB_GQ_LOGON_ERROR:int = 101;//登陆失败
		public static const SUB_GQ_LOGON_FINISH:int = 102;//登陆完成---完成了所有登录相关的处理，比如完成了人物信息的接收，完成了游戏列表的接收等
		//////////////////////////////////////////////////////////////////////////
		//游戏列表命令码

		public static const MDM_GR_SERVER_LIST:int = 2;								//列表信息
		
		public static const SUB_GQ_LIST_TYPE:int = 100;								//类型列表
		public static const SUB_GQ_LIST_KIND:int = 101;								//种类列表
		public static const SUB_GQ_LIST_STATION:int = 102;							//站点列表
		public static const SUB_GQ_LIST_SERVER:int = 103;							//房间列表
		public static const SUB_GQ_LIST_FINISH:int = 104;							//发送完成
		public static const SUB_GQ_LIST_CONFIG:int = 105;							//列表配置
		
		public function CMD_DEF_HALL()
		{
		}

	}
}