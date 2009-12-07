package Application.model.vo.protocol.room
{
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
		
	public class CMD_GQ_UserInfoHead
	{
		public static const sizeof_CMD_GQ_UserInfoHead:int = 2 + 2 + 4 + 4 + 4 + 4 + 4 + 4 + 1 + 1 + 1 + 1
							 + 2 + 2 + 1 + 1 + 1 + 1 + tagUserScore.sizeof_tagUserScore + 4 + 4 * GlobalDef.PROPERTY_COUNT;
										
		//用户属性
		public var wFaceID:int;										//头像索引	WORD
		public var dwUserID:uint;									//用户 I D	DWORD
		public var dwGameID:uint;									//游戏 I D	DWORD  暂不用
		public var dwHonorRank:int;									//排名	DWORD
		public var dwUserRight:int;									//用户等级	DWORD	
		public var lLoveliness:int;									//用户魅力	LONG
		public var dwMasterRight:int;								//管理权限	DWORD
		
		//用户属性
		public var cbGender:int;									//用户性别	BYTE
		public var cbMemberOrder:int;								//会员等级	BYTE
		public var cbMasterOrder:int;								//管理等级	BYTE
		public var cbHonorLevel:int;								//游戏等级	BYTE

		//用户状态
		public var wTableID:int;									//桌子号码	WORD
		public var wChairID:int;									//椅子位置	WORD	
		public var cbUserStatus:int;								//用户状态	BYTE
	
		//用户积分
		public var UserScoreInfo:tagUserScore = new tagUserScore;	//积分信息	tagUserScore
		
		//扩展信息
		public var dwCustomFaceVer:int;								//上传头像	DWORD
		public var dwPropResidualTime:Array = new Array(GlobalDef.PROPERTY_COUNT);	//道具时间	DWORD[PROPERTY_COUNT]
		
		//public var lMatchScore:int;									//LONG
		
		public static function readData(bytes:ByteArray):CMD_GQ_UserInfoHead{
			var result:CMD_GQ_UserInfoHead = new CMD_GQ_UserInfoHead;
			
			result.wFaceID = bytes.readShort();
			bytes.readShort();//跳过补齐
			
			result.dwUserID = bytes.readUnsignedInt();
			result.dwGameID = bytes.readUnsignedInt();
			result.dwHonorRank = bytes.readUnsignedInt();
			result.dwUserRight = bytes.readUnsignedInt();
			result.lLoveliness = bytes.readInt();
			result.dwMasterRight = bytes.readInt();
			
			result.cbGender = bytes.readByte();
			result.cbMemberOrder = bytes.readByte();
			result.cbMasterOrder = bytes.readByte();
			result.cbHonorLevel = bytes.readByte();
			
			result.wTableID = bytes.readShort();
			result.wChairID = bytes.readShort();
			
			result.cbUserStatus = bytes.readByte();
			bytes.readByte();//跳过补齐
			bytes.readByte();//跳过补齐
			bytes.readByte();//跳过补齐
			
			result.UserScoreInfo = tagUserScore.readData(bytes);
			result.dwCustomFaceVer = bytes.readInt();
			
			for(var i:int=0; i<GlobalDef.PROPERTY_COUNT; i++){
				result.dwPropResidualTime[i] = bytes.readInt();
			}
			
			//result.lMatchScore = bytes.readInt();
			
			return result;
		}		
		public function CMD_GQ_UserInfoHead()
		{
		}

	}
}