package Application.model.vo.protocol.common
{
	public class tagMessageBody
	{
		public var text:String;				//消息内容
		public var title:String;			//弹出框标题
		public var type:String;				//弹出类型---只有OK、有确定与取消
		public var closeHandler:Function;	//点确定或者取消之后的处理
		
		public function tagMessageBody()
		{
		}

	}
}