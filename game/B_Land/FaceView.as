package B_Land
{
	import common.data.HallConfig;
	import common.game.interfaces.IFaceView;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	
	public class FaceView extends UIComponent implements IFaceView
	{
		private var loader:Loader = new Loader();
		private var _mask:Shape = new Shape();
		private var position:int;
		private var progress:adLoading = new adLoading();
		private var url:String;
		public function FaceView(nIndex:int,pos:int)
		{
			createFace(nIndex,pos);
			
		}
		public function createFace(nIndex:int,pos:int):Boolean{
			position = pos;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_mask.graphics.beginFill(0xFF0000,1);
			_mask.graphics.drawRect(0,0,76,80);
			_mask.graphics.endFill();
			addChild(progress);
			progress.x = 40;
			progress.y = 40;
			try{
				var index:String;
				if(nIndex<10){
					 index = "0"+nIndex;
				}else{
					 index = nIndex.toString();
				}
				url = HallConfig.getInstance().getPhotoFile()+index+".png";
				loader.load(new URLRequest(url));
				return true;
			}catch(e:Error){
				trace("图片加载出错了")
				trace(url);
				return false;
			}
			return false;
		}
		private function onComplete(evt:Event):void{
			//loader.width = ((loader.width*80)/loader.height);
			removeChild(progress);
			loader.height = ((76*loader.height)/loader.width);
			loader.width = 76;				
			this.addChild(loader);
			this.addChild(_mask);
			loader.mask = _mask;
			
		}
		private function onProgress(evt:ProgressEvent):void{
			
		}
		private function onError(evt:IOErrorEvent):void{
			trace("头像加载出错");
			trace(url);
		}
		public function getMovieClip():UIComponent{
			 return this;
		}
		public  function moveMovieClip(x:Number, y:Number):void{
			 this.transform.matrix = new Matrix(-1,0,0,1,x + getSize().x,y);
		}
		public function destroy():void{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			this.removeChild(loader);
			loader = null;
		}
		
		//这个估计没用
		public static function getSize():Point
		{
			return new Point(152, 143);
		}
		public function setOffLine(value:Boolean):void{
			return;
		}
		public function get pos():int{
			return position;
		}
	}
}