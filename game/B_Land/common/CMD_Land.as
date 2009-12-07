package B_Land.common
{
	import common.data.GlobalDef;
	

	public class CMD_Land
	{
		public static const GAME_PLAYER:int =3; //游戏人数
        
		//游戏状态                              
		public static const GS_WK_FREE:int= GlobalDef.GS_FREE; //等待开始
		public static const GS_WK_SCORE:int=GlobalDef.GS_PLAYING; //叫分状态
		public static const GS_WK_PLAYING:int=GlobalDef.GS_PLAYING + 1; //游戏进行
		
		//超时次数托管
		public static const CT_OUTCART_TIMEOUT:int = 1;//超时3次自动托管

//////////////////////////////////////////////////////////////////////////
		//服务器命令结构

		public static const SUB_S_SEND_CARD:int=100; //发牌命令
		public static const SUB_S_LAND_SCORE:int=101; //叫分命令
		public static const SUB_S_GAME_START:int=102; //游戏开始
		public static const SUB_S_OUT_CARD:int=103; //用户出牌
		public static const SUB_S_PASS_CARD:int=104; //放弃出牌
		public static const SUB_S_GAME_END:int=105; //游戏结束


//////////////////////////////////////////////////////////////////////////
		//客户端命令结构

		public static const SUB_C_LAND_SCORE:int=1; //用户叫分
		public static const SUB_C_OUT_CARD:int=2; 	//用户出牌
		public static const SUB_C_PASS_CARD:int=3; 	//放弃出牌
		public static const SUB_C_TRUSTEE:int = 4;	//托管

		public function CMD_Land()
		{
		}

	}
}