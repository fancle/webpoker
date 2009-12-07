package Application.model.vo.protocol.gameFrame
{
	import flash.geom.Point;
	
	public class IPC_Property
	{
		public var userID:uint;							//用户ID
		public var userCoordinate:Point = new Point;	//头像坐标
		public var propertyID:int;						//道具ID
		
		public function IPC_Property()
		{
		}

	}
}