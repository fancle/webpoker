package Application.model.vo.protocol.gameFrame
{
	import common.data.GlobalDef;
	
	public class IPC_GF_ServerInfo
	{
		public static  const sizeof_IPC_GF_ServerInfo:int = 4 + 2 + 2 + 2 
										+ 2 + 2 + 2 + GlobalDef.KIND_LEN + GlobalDef.SERVER_LEN + 8 + 8 + 8;
		public var dwUserID:uint;//用户 I D
		public var wTableID:uint;//桌子号码
		public var wChairID:uint;//椅子号码
		public var wKindID:uint;//类型标识
		public var wServerID:uint;//房间标识
		public var wGameGenre:uint;//游戏类型
		public var wChairCount:uint;//椅子数目
		public var szKindName:String = new String;//类型名字
		public var szServerName:String = new String;//房间名称
		public var fCellScore:Number;//单位额度
		public var fHighScore:Number;//最高额度
		public var fLessScore:Number;//最低额度

		public function IPC_GF_ServerInfo()
		{
			
		}

	}
}