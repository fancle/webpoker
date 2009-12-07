package common.assets
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class SoundPlay
	{
		private var _soundData:Sound;
		private var _soundChannel:SoundChannel;
		public function SoundPlay()
		{
		}
		//加载本地资源
		public function LoadLocalSoundData(value:Class):Boolean{
			if(value==null){
				return false;
			}
			_soundData = new value();
			return true;			
		}
		//卸载资源
		public function unLoad():void{
			_soundData = null;
			_soundChannel = null;
		}
		//播放 参数代表是否循环播放 
		public function play(bReplay:Boolean = false):Boolean{
			if(_soundData == null)
				return false;
			_soundChannel = _soundData.play(0, bReplay ? 0x7fffffff : 0);
			return true;
		}
		public function stop():void{
			if(_soundData==null||_soundChannel==null){
				return;
			}
		    _soundChannel.stop();
		    			
		}

	}
}