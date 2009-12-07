package Application.model.game
{
	import Application.model.vo.protocol.room.CMD_GQ_ColumnInfo;
	import Application.model.vo.protocol.room.CMD_GQ_ServerInfo;
	
	public class objGameKind
	{
		public var szGameName:String;//游戏名称
		public var dwOnLineCount:uint = 0;//游戏在线人数
		public var serverConfigInfo:CMD_GQ_ServerInfo;//游戏的房间配置信息
		public var serverColumnInfo:CMD_GQ_ColumnInfo;//游戏房间列表信息
		public var arrGameTypeDescription:Array = new Array;//游戏类型数据描述列表
		public var arrGameServerList:Array = new Array;//游戏房间列表
		
		public function objGameKind()
		{
		}

	}
}