package Application.model.vo.protocol.room
{
	import common.data.GlobalDef;
	
	import mx.utils.ObjectUtil;
	
	public class tagUserData
	{
		public static const sizeof_tagUserData:int = 2 + 4*7 + GlobalDef.NAME_LEN + GlobalDef.GROUP_LEN + GlobalDef.UNDER_WRITE_LEN
									+ 1 + 1 + 1 + 1 +  4*8 + 2 + 2 + 1*4 + 4*GlobalDef.PROPERTY_COUNT;
		//用户属性
		public var wFaceID:uint;							//头像索引 WORD
		public var dwCustomFaceVer:uint;					//上传头像 DWORD
		public var dwUserID:uint;							//用户 I D DWORD
		public var dwHonorRank:uint;						//排名 DWORD
		//public var dwMatchSection:uint;					//比赛阶段 DWORD
		public var dwUserRight:uint;						//用户等级 DWORD
		public var lLoveliness:int;							//用户魅力 LONG
		public var dwMasterRight:int;						//管理权限 DWORD
		public var szName:String;							//用户名字 TCHAR[NAME_LEN]
		public var szNickName:String;						//用户昵称
		public var szGroupName:String;						//社团名字 TCHAR[GROUP_LEN]
		public var szUnderWrite:String;						//个性签名 TCHAR[UNDER_WRITE_LEN]

		//用户属性
		public var cbGender:int;							//用户性别 BYTE
		public var cbMemberOrder:int;						//会员等级 BYTE
		public var cbMasterOrder:int;						//管理等级 BYTE
		public var cbHonorLevel:int;						//游戏等级	BYTE

		//用户积分
		public var lInsureScore:int;						//消费金币 LONG
		public var lGameGold:int;							//U豆 LONG
		public var lScore:int; 								//用户分数（比赛币） LONG
		public var lWinCount:int;							//胜利盘数 LONG
		public var lLostCount:int;							//失败盘数 LONG
		public var lDrawCount:int;							//和局盘数 LONG
		public var lFleeCount:int;							//断线数目 LONG
		public var lExperience:int;							//用户经验 LONG
		public var lUserUQ:uint;							//用户U券 LONG
		public var lTableRevenue:int;						//桌子费 LONG

		//用户状态
		public var wTableID:int;							//桌子号码 WORD
		public var wChairID:int;							//椅子位置 WORD
		public var cbUserStatus:int;						//用户状态 BYTE

		//其他信息
		public var cbCompanion:int;							//用户关系 BYTE
		public var dwPropResidualTime:Array = new Array;	//道具时间 DWORD[PROPERTY_COUNT]
		
		public function tagUserData()
		{
		}
		
		public function clone():tagUserData{
			var result:tagUserData = new tagUserData;
			
			var claInfo:Object=ObjectUtil.getClassInfo(this);
			var props:Array=claInfo["properties"];
			for each (var key:String in props)
			{
				result[key]=this[key];				
			}
			
			return result;
		}
	}
}