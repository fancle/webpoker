package B_Land.common
{
	import flash.system.ApplicationDomain;
	

	public class MaterialLib
	{
		private var _materialArray:Array;
        private var _materialUrlArr:Array;
        private static var instance:MaterialLib;
		public function MaterialLib()
		{
			_materialUrlArr=[];
			_materialArray=[];
			if (instance != null)
			{
				throw new Error("实例化单例类出错-MaterialLib");
			}
			return;
		}

		public function push(param1:ApplicationDomain, param2:String=""):void
		{
			if (param2 != "")
			{
				_materialUrlArr.push(param2);
			}
			_materialArray.push(param1);
			return;
		}

		public function getClass(param1:String):Class
		{
			var _loc_2:Class;
			return searchClass(param1);
		}

		public function hasUrl(param1:String):Boolean
		{
			var _loc_2:Boolean;
			var _loc_3:int;
			var _loc_4:*=_materialUrlArr.length;
			while (_loc_3 < _loc_4)
			{

				if (_materialUrlArr[_loc_3] == param1)
				{
					return true;
				}
				_loc_3++;
			}
			return false;
		}

		private function searchClass(param1:String):Class
		{
			var _loc_2:int;
			var _loc_3:*=_materialArray.length;
			while (_loc_2 < _loc_3)
			{

				if ((_materialArray[_loc_2] as ApplicationDomain).hasDefinition(param1))
				{
					return (_materialArray[_loc_2] as ApplicationDomain).getDefinition(param1) as Class;
				}
				_loc_2++;
			}
			return null;
		}

		public function getMaterial(param1:String):Object
		{
			var _loc_2:*=getClass(param1);
			if (_loc_2 != null)
			{
				return new _loc_2;
			}
			return null;
		}

		public static function getInstance():MaterialLib
		{
			if (instance == null)
			{
				instance=new MaterialLib;
			}
			return instance;
		}


	}
}