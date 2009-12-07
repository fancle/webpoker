package Application.control.net.gameFrame
{
	import Application.model.gameFrame.GameFrameProxy;
	import Application.utils.SoundManager;
	
	import common.data.IPC_DEF;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class IPC_ControlCmd extends SimpleCommand implements ICommand
	{
		public function IPC_ControlCmd()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var gameFrameProxy:GameFrameProxy = facade.retrieveProxy(GameFrameProxy.NAME) as GameFrameProxy;
			
			var obj:Object = notification.getBody();
			
			switch(notification.getType()){
				case SoundManager.SOUND:		//游戏音乐控制
				{
					switch(notification.getBody() as String)
					{
						case SoundManager.CLOSE:		//关闭游戏音乐
						{
							if(gameFrameProxy)
								gameFrameProxy.sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONTROL,IPC_DEF.IPC_SUB_CLOSE_SOUND,null,0);
							break;
						}
						case SoundManager.OPEN:		//打开游戏音乐
						{
							if(gameFrameProxy)
								gameFrameProxy.sendIPCChannelMessage(IPC_DEF.IPC_MAIN_CONTROL,IPC_DEF.IPC_SUB_OPEN_SOUND,null,0);
							break;
						}
					}
					break;
				}
				
			} 
		}
		
	}
}