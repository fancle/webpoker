/**
 * 点对点聊天
 * @paramer
 */
package Application.model.vo.protocol.room
{
	import Application.utils.Memory;
	
	import common.data.GlobalDef;
	
	import flash.utils.ByteArray;
	
	public class CMD_GR_UserChat
	{
		public static const sizeof_Head_CMD_GR_UserChat:int = 2 + 2 + 4 + 4 + 4;
		
		public var wChatLength:uint;						//信息长度WORD
		public var crFontColor:uint;						//信息颜色COLORREF
		public var dwSendUserID:uint;						//发送用户DWORD
		public var dwTargetUserID:uint;						//目标用户DWORD
		public var szChatMessage:String;					//聊天信息TCHAR[MAX_CHAT_LEN]
		
		public static function readData(bytes:ByteArray):CMD_GR_UserChat{
			var result:CMD_GR_UserChat = new CMD_GR_UserChat;
			
			result.wChatLength = bytes.readUnsignedShort();
			bytes.readUnsignedShort();//内存补齐
			
			result.crFontColor = bytes.readUnsignedInt();
			result.dwSendUserID = bytes.readUnsignedInt();
			result.dwTargetUserID = bytes.readUnsignedInt();
			
			result.szChatMessage = Memory.readStringByByteArray(bytes,result.wChatLength);
			
			return result;
		}
		
		public function toByteArray():ByteArray{
			var bytes:ByteArray = Memory.newLitteEndianByteArray();
			
			bytes.writeShort(wChatLength);
			bytes.writeShort(0);
			
			bytes.writeUnsignedInt(crFontColor);
			bytes.writeUnsignedInt(dwSendUserID);
			bytes.writeUnsignedInt(dwTargetUserID);
			Memory.writeStringToByteArray(bytes,szChatMessage,wChatLength);
			
			return bytes;
		}
		
		public function CMD_GR_UserChat()
		{
		}

	}
}