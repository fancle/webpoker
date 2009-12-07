package B_Sparrow.common
{
	public class GameLogicDef
	{
		/*-----------------------------常量定义---------------------------------*/
		public static const MAX_WEAVE:uint=4;//最大组合
		public static const MAX_INDEX:uint=34;//最大索引
		public static const MAX_COUNT:uint=14;//最大数目
		public static const MAX_REPERTORY:uint=64;//最大库存
		
		/*----------------------------- 逻辑掩码 ---------------------------------*/
		public static const MASK_COLOR:uint=0xF0;//花色掩码
		public static const MASK_VALUE:uint=0x0F;//数值掩码
		
		/*------------------------------动作定义---------------------------------*/
		
		//	动作标志
		public static const WIK_NULL:uint=0x0000;	//没有类型
		public static const WIK_LEFT:uint=0x0001;	//左吃类型
		public static const WIK_CENTER:uint=0x0002;	//中吃类型
		public static const WIK_RIGHT:uint=0x0004;	//右吃类型
		public static const WIK_PENG:uint=0x0008;	//碰牌类型
		public static const WIK_GANG:uint=0x0010;	//杠牌类型
		public static const WIK_FILL:uint=0x0800;	//补牌类型	
		public static const WIK_LISTEN:uint=0x0040;	//暗听类型
		public static const WIK_DANCE:uint=0x0200;	//明听类型
		public static const WIK_CHI_HU:uint=0x0020;	//吃胡类型
		
		
		/*-----------------------------胡牌定义(暂时定义)--------------------------------------*/
		
		//牌型掩码
		public static const CHK_MASK_SMALL:uint = 0x0000FFFF;	//小胡掩码
		public static const CHK_MASK_GREAT:uint = 0xFFFF0000;	//大胡掩码
		
		//小胡牌型
		public static const CHK_NULL:uint=0x00000000;		//非胡类型
		public static const CHK_JI_HU:uint=0x00000001;		//鸡胡类型
		public static const CHK_PING_HU:uint=0x00000002;	//平胡类型
		
		//大胡牌型
		public static const CHK_PENG_PENG:uint = 0x00010000;	//碰碰胡牌
		public static const CHK_QI_XIAO_DUI:uint = 0x00020000;	//七小对牌
		public static const CHK_SHI_SAN_YAO:uint = 0x00040000;	//十三幺牌
		
		/*-----------------------------胡牌权位(暂时定义)-------------------------------------*/
		
		//牌权掩码
		public static const CHR_MASK_SMALL:uint = 0x000000FF;	//小胡掩码
		public static const CHR_MASK_GREAT:uint = 0xFFFFFF00;	//大胡掩码
		
		//大胡权位
		public static const	CHR_DI:uint = 0x00000100;			//地胡权位
		public static const CHR_TIAN:uint = 0x00000200;			//天胡权位
		public static const CHR_QING_YI_SE:uint = 0x00000400;	//清一色牌
		public static const CHR_QIANG_GANG:uint = 0x00000800;	//抢杆权位
		public static const CHR_QUAN_QIU_REN:uint =	0x00001000;	//全求权位
		
		public static const CHK_HAO_HUA_DUI:uint=0x0400;//豪华对牌 */
		
		
//-------------------------------OLDER EDITION---------------------------------------------------->>		
		
		//特殊胡牌
/* 		public static const CHK_SIXI_HU:uint=0x0010;//四喜胡牌
		public static const CHK_BANBAN_HU:uint=0x0020;//板板胡牌
		public static const CHK_LIULIU_HU:uint=0x0040;//六六顺牌
		public static const CHK_QUEYISE_HU:uint=0x0080;//缺一色牌		 */
		
		//大胡牌型
/* 		public static const CHK_PENG_PENG:uint=0x0100;//碰碰胡牌
		public static const CHK_JIANG_JIANG:uint=0x0200;//将将胡牌
		public static const CHK_QI_XIAO_DUI:uint=0x0400;//七小对牌
		public static const CHK_HAO_HUA_DUI:uint=0x0400;//豪华对牌 */

		//需将权位
/* 		public static const CHR_DI:uint=0x0001;//地胡权位
		public static const CHR_TIAN:uint=0x0002;//天胡权位
		public static const CHR_HAI_DI:uint=0x0004;//海底权位
		public static const CHR_QIANG_GANG:uint=0x0008;//抢杆权位 */
		
		//乱将权位
/* 		public static const CHR_QING_YI_SE:uint=0x0100;//清色权位
		public static const CHR_QUAN_QIU_REN:uint=0x0200;//全求权位 */
		public static const HUTYPE:Array = new Array("大四喜（20番）",
														"大三元（20番）",
														"绿一色（20番）",
														"九莲宝灯（20番）",
														"四杠（20番）",
														"大车轮（20番）",
														"十三幺（20番）",
														"清老头（20番）",
														"小四喜（20番）",
														"小三元（20番）",
														"字一色（20番）",
														"四暗刻（20番）",
														"一色双龙抱（20番）",
														"",
														"",
														"",
														"三杠（3番）",
														"混幺九（2番）",
														"七对（2番）",
														"",
														"",
														"清一色（7番）",
														"一色三同顺（3番）",
														"",
														"",
														"",
														"",
														"清龙（2番）",
														"",
														"",
														"",
														"三同刻（3番）",
														"三暗刻（3番）",
														"",
														"",
														"",
														"",
														"三风刻（7番）",
														"",
														"",
														"三色同顺（2番）",
														"",
														"",
														"妙手回春（1番）",
														"海底捞月（1番）",
														"杠上开花（1番）",
														"抢杠和（1番）",
														"碰碰和（2番）",
														"混一色（2番）",
														"",
														"",
														"",
														"",
														"双箭刻（2番）",
														"全带幺（3番）",
														"",
														"",
														"",
														"箭刻（1番）",
														"",
														"",
														"门前清（1番）",
														"平和（1番）",
														"",
														"",
														"",
														"",
														"断幺（1番）",
														"",
														"",
														"",
														"",
														"",
														"",
														"",
														"",
														"",
														"",
														"",
														"自摸（1番）",
														"听牌（1番）"
														);
		/* =========================游戏结束状态======================================= */
		
		public static const FINAL_STATE_ZHU:uint = 0						//无效
		public static const FINAL_STATE_JIAO_NO:uint = 1					//无叫
		public static const FINAL_STATE_JIAO_YES:uint = 2					//有叫
		public static const FINAL_STATE_TING:uint = 3						//听牌
		public static const FINAL_STATE_DANCE:uint = 4						//跳舞.
		public static const FINAL_STATE_HU:uint = 5							//平胡.
		public static const FINAL_STATE_HU_ZIMO:uint = 6					//自摸.
		public static const FINAL_STATE_QUIT:uint = 7						//强退								
														
	}
}