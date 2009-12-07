package Application.model.vo.protocol.gameFrame
{
	import flash.utils.ByteArray;
	
	//用户状态
	public class IPC_UserStatus
	{
		public static const sizeof_IPC_UserStatus:uint = 4 + 1;
		
		public var dwUserID:uint;//用户ID
		public var cbUserStatus:uint;//用户状态
		
		public function IPC_UserStatus()
		{

		}
		public static function readData(data:ByteArray):IPC_UserStatus
		{
			var result:IPC_UserStatus=new IPC_UserStatus;
			
			result.dwUserID = data.readUnsignedInt();
			result.cbUserStatus = data.readUnsignedByte();
			
			return result;
		}
	}
}