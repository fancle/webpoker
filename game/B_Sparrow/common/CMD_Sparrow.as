package B_Sparrow.common
{
	import common.data.GlobalDef;
	
	public class CMD_Sparrow
	{
		public static const GAME_PLAYER:int =2; //游戏人数
		// 游戏状态
		public static const GS_MJ_FREE:uint = GlobalDef.GS_FREE;	//空闲状态
		public static const GS_MJ_PLAY:uint = (GlobalDef.GS_PLAYING+1);	//游戏状态
		//public static const GS_MJ_HAI_DI:uint = (GlobalDef.GS_PLAYING+2);	//海底状态
		
		/*------------------------------服务器命令结构------------------------------------------*/
		
		public static const SUB_S_GAME_START:uint = 100;	//游戏开始
		public static const SUB_S_OUT_CARD:uint = 101;		//出牌命令
		public static const SUB_S_OPERATE_RESULT:uint = 102;//操作命令
		public static const SUB_S_SEND_CARD:uint = 105;		//发送扑克
		public static const SUB_S_SEND_DANCE:uint = 110;	//发送跳舞.
		public static const SUB_S_SEND_HU:uint = 111;		//发送胡牌..
		public static const SUB_S_GAME_END:uint = 107;		//游戏结束
		public static const SUB_S_OPERATE:uint = 108;		//预操作命令
		public static const SUB_S_LISTEN_CARD:uint = 109;	//发送听牌.
		public static const SUB_S_FALSE_GANG:uint = 112;	//假杠..
		public static const SUB_S_OUT_CARD_QIANG:uint = 113;									//
		
		/*------------------------------客户端命令结构------------------------------------------*/
		public static const SUB_C_OUT_CARD:uint = 1			//出牌命令
		public static const SUB_C_OPERATE_SPARROW:uint = 2		//操作扑克
		public static const SUB_C_OPERATE:uint = 3			//预操作扑克
	}
}