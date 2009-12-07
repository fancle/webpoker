package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class CMD_GP_UserSitReq
	{
		public static const sizeof_CMD_GP_UserSitReq:int = 2 + 2 + 1;
		
		public var wTableID:int;								//桌子位置WORD	
		public var wChairID:int;								//椅子位置WORD	
		public var cbPassLen:int = 0;							//密码长度BYTE			
		public var szTablePass:String = "";						//桌子密码TCHAR[PASS_LEN]
		
		public function toByteArray():ByteArray{
			var result:ByteArray = Memory.newLitteEndianByteArray();
			
			result.writeShort(wTableID);
			result.writeShort(wChairID);
			result.writeByte(cbPassLen);
			Memory.writeStringToByteArray(result,szTablePass,cbPassLen);
			
			return result;
		}
		
		public function CMD_GP_UserSitReq()
		{
		}

	}
}