package Application.utils
{
	import common.assets.SoundPlay;
	
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	public class SoundManager
	{
		public static const OPEN:String = "sound_open"; //状态开启
		public static const CLOSE:String = "sound_close";//状态关闭
		public static const SOUND:String = "sound";//类型
	    private static var _instance:SoundManager;
	    private var _isQuite:Boolean;//是否退出
		public function SoundManager()
		{
			if(_instance!=null){
				throw new Error("SoundManager单例出错");
			}
			_isQuite = false;
		}
		public static function getInstance():SoundManager{
			if(_instance==null){
				_instance = new SoundManager();
			}
			return _instance;
		}
		//播放声频
		public function playSound(s:SoundPlay,bRepate:Boolean =false):Boolean{
			if(_isQuite==true||s==null){
				return false;
			}
			s.play(bRepate);
			return true;
		}
		//停止播放
		public function stop(s:SoundPlay):void{
			if(s==null){
				return;
			}
			s.stop();
		}
		//设置状态
		public function  setQuit(b:Boolean):void{
			_isQuite = b;
			if(b==true){
				SoundMixer.stopAll();
				//可能这里需要发送摸个通知通知全局控制
			}
			
		}
		public function IsQuit():Boolean{
			return _isQuite;
		}
		public function setVolumn(value:Number):void{
			
            var transform:SoundTransform = SoundMixer.soundTransform;
            transform.volume = value;
            SoundMixer.soundTransform = transform;
			SoundMixer.soundTransform.volume = value; 
		}
	}
}