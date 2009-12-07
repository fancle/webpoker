package Application.utils
{
	import common.assets.ModuleLib;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	
	/**
	 * 
	 * @author luqiang
	 * 头像管理单例 
	 */
	public class FaceMap
	{
		private static var _instance:FaceMap;
		private var _headMap:HashMap = new HashMap();
		private var _headClass:ApplicationDomain = ((ModuleLib.getInstance().lib) as HashMap).find("headPic") as ApplicationDomain;
		private var _bitMapData:BitmapData;
		private var _bgColor:uint;
		private var _maxNum:int;
		/**
		 * 
		 * @throws Error
		 */
		public function FaceMap()
		{
			if(_instance!=null){
				throw  new  Error("头像单例出错");
			}
			init();
		}
		/**
		 * 初始化获取bitmapData
		 */
		private function init():void{
			   var tempData:Class = (_headClass.getDefinition("headPic")) as Class;
				_bitMapData =  new tempData(0,0);
				_bgColor = _bitMapData.getPixel32(0,0);
				_maxNum = (_bitMapData.width/32)-1;
		}
		/**
		 * 
		 * @param faceId 头像id
		 * @return 
		 */
		public function getFace(faceId:int):BitmapData{
			if(faceId>_maxNum){
				throw new Error("头像超出索引范围");	
			}
			if(!_headMap.containsKey(faceId)){
				var rec:Rectangle = new Rectangle(faceId*32,0,32,32);			
			 	var bm:BitmapData = new BitmapData(32,32);			 				 	
			 	bm.copyPixels(_bitMapData,rec,new Point(0,0));
			 	var bm1:BitmapData = new BitmapData(32,32);
			 	bm1.threshold(bm,new Rectangle(0,0,32,32),new Point(0,0),"==",_bgColor,0x00000000,0xFFFFFFFF,true);
			 	_headMap.insert(faceId,bm1);
			}
			return _headMap.find(faceId) as BitmapData

		}
		
		public static function getInstance():FaceMap{
			if(_instance==null){
				_instance = new FaceMap();
			
			}
			return _instance;
		}
	}
}