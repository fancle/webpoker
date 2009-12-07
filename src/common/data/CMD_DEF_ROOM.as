package common.data
{
	public class CMD_DEF_ROOM
	{
		//////////////////////////////////////////////////////////////////////////
		//登录数据包定义
		
		public static const MDM_GR_LOGON:int = 1;											//房间登录
		
		public static const SUB_GP_LOGON_ACCOUNTS:int = 1;									//帐户登录
		public static const SUB_GP_LOGON_USERID:int = 2;										//I D 登录
		
		public static const SUB_GQ_LOGON_SUCCESS:int = 100;									//登录成功
		public static const SUB_GQ_LOGON_ERROR:int = 101;									//登录失败
		public static const SUB_GQ_LOGON_FINISH:int = 102;									//登录完成
		
		//////////////////////////////////////////////////////////////////////////
		//用户数据包定义
		
		public static const MDM_GR_USER:int = 2;												//用户信息
		
		public static const SUB_GP_USER_SIT_REQ:int = 1;										//坐下请求
		public static const SUB_GR_USER_LOOKON_REQ:int = 2;									//旁观请求
		public static const SUB_GR_USER_STANDUP_REQ:int = 3;									//起立请求
		public static const SUB_GR_USER_LEFT_GAME_REQ:int = 4;								//离开游戏
		
		public static const SUB_GQ_USER_COME:int = 100;										//用户进入
		public static const SUB_GQ_USER_STATUS:int = 101;									//用户状态
		public static const SUB_GR_USER_SCORE:int = 102;										//用户分数
		public static const SUB_GQ_SIT_FAILED:int = 103;										//坐下失败
		public static const SUB_GR_USER_RIGHT:int = 104;										//用户权限
		public static const SUB_GR_MEMBER_ORDER:int = 105;									//会员等级
		
		public static const SUB_GR_USER_CHAT:int = 200;										//聊天消息
		public static const SUB_GR_USER_WISPER:int = 201;									//私语消息
		public static const SUB_GP_USER_RULE:int = 202;										//用户规则
		
		public static const SUB_GR_USER_INVITE:int = 300;									//邀请消息
		public static const SUB_GR_USER_INVITE_REQ:int = 301;								//邀请请求
		
		//////////////////////////////////////////////////////////////////////////
		//配置信息数据包

		public static const MDM_GR_INFO:int = 3;												//配置信息

		public static const SUB_GQ_SERVER_INFO:int = 100;									//房间配置
		public static const SUB_GR_ORDER_INFO:int = 101;										//等级配置
		public static const SUB_GR_MEMBER_INFO:int = 102;									//会员配置
		public static const SUB_GQ_COLUMN_INFO:int = 103;									//列表配置
		public static const SUB_GQ_CONFIG_FINISH:int = 104;									//配置完成
		
		//////////////////////////////////////////////////////////////////////////
		//房间状态数据包

		public static const MDM_GR_STATUS:int = 4;											//状态信息

		public static const SUB_GQ_TABLE_INFO:int = 100;										//桌子信息
		public static const SUB_GQ_TABLE_STATUS:int = 101;									//桌子状态
		
		//////////////////////////////////////////////////////////////////////////
		//管理数据包

		public static const MDM_GR_MANAGER:int = 5;											//管理命令

		public static const SUB_GR_SEND_WARNING:int = 1;										//发送警告
		public static const SUB_GR_SEND_MESSAGE:int = 2;										//发送消息
		public static const SUB_GR_LOOK_USER_IP:int = 3;										//查看地址
		public static const SUB_GR_KILL_USER:int = 4;										//踢出用户
		public static const SUB_GR_LIMIT_ACCOUNS:int = 5;									//禁用帐户
		public static const SUB_GR_SET_USER_RIGHT:int = 6;									//权限设置
		public static const SUB_GR_OPTION_SERVER:int = 7;									//房间设置
		
		//////////////////////////////////////////////////////////////////////////
		//房间数据包

		public static const MDM_GR_SERVER_INFO:int = 11;										//房间信息

		public static const SUB_GR_ONLINE_COUNT_INFO:int = 100;								//在线信息
		
		//////////////////////////////////////////////////////////////////////////
		//系统数据包
		
		public static const MDM_GR_SYSTEM:int = 10;											//系统数据
		
		public static const SUB_GQ_MESSAGE:int = 100;										//系统消息
		
		//////////////////////////////////////////////////////////////////////////
		//游戏消息
		public static const MDM_GF_GAME:int= 100;
		
		//////////////////////////////////////////////////////////////////////////
		//框架消息
		public static const MDM_GF_FRAME:int= 101;
		
		public static const SUB_GF_INFO:int = 1;//游戏信息
		public static const SUB_GF_USER_CHAT:int= 200;//用户聊天
		//以下的本程序不使用，在游戏当中使用，随后删除
		public static const SUB_GF_OPTION:int= 100;//游戏配置
		public static const SUB_GF_SCENE:int= 101;//场景信息
		public static const SUB_GF_USER_READY:int= 2;//用户同意
		public static const SUB_GF_MESSAGE:int= 300;//系统消息
		public static const SUB_GF_MATCHMESSAGE:int = 350;//比赛结果
		
		//////////////////////////////////////////////////////////////////////////
		//鲜花道具
		
		public static const MDM_GF_PRESENT:int = 102;
		
		public static const SUB_GF_PROP_ATTRIBUTE:int = 553;					//道具属性
		
		public static const SUB_GF_FLOWER_ATTRIBUTE:int = 500;					//鲜花属性
		public static const SUB_GF_FLOWER:int = 501;							//鲜花消息
		
		public static const SUB_GF_PROP_BUGLE:int = 554;						//喇叭道具
		public static const SUB_GF_EXCHANGE_CHARM:int = 502;					//兑换魅力
		
		public function CMD_DEF_ROOM()
		{
		}

	}
}