package Application.view.mediator.room
{
	import Application.NotificationString;
	import Application.control.net.room.CMD_GameRoomCmd;
	
	import chair.*;
	
	import common.assets.ModuleLib;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.DisplayObject;
	
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	public class RoomMediator extends Mediator implements IMediator
	{
		/**
		 * 
		 * @default 
		 */
		public static const NAME:String="RoomMediator";
		private var _gameName:String;
		private var _wisperWin:WisperComponent;
		
		public function RoomMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			//TODO: implement function

		}

		override public function getMediatorName():String
		{
			return NAME;
		}

		override public function getViewComponent():Object
		{
			return viewComponent;
		}

		override public function handleNotification(note:INotification):void
		{
			switch (note.getName())
			{
				case NotificationString.ROOM_LOGIN:{				
					ModuleLib.getInstance().gameStage.addModule((ModuleLib.getInstance().lib as HashMap).find("room") as DisplayObject);
					(ModuleLib.getInstance().gameStage).exitRoomBtn.visible = true;//显示退出房间的按钮
					(ModuleLib.getInstance().gameStage).findChairBtn.visible = true
				    if(!facade.hasMediator(TableAreaMediator.NAME)){
				    	facade.registerMediator(new TableAreaMediator(view.tableArea));				    	
				    }
				    (facade.retrieveMediator(TableAreaMediator.NAME) as TableAreaMediator).ClassName = gameName;
				    if(!(facade.hasMediator(UserListMediator.NAME))){
				    	facade.registerMediator(new UserListMediator(view.dg));
				    }
				    if(!(facade.hasMediator(ChatMediator.NAME)))
				    {
				    	facade.registerMediator(new ChatMediator(view.chatView));
				    }
				    if(!(facade.hasMediator(WisperMediator.NAME)))
				    {
				    	if(_wisperWin == null)
						{
							_wisperWin = new WisperComponent();
							_wisperWin.visible = false;
							PopUpManager.addPopUp(_wisperWin,view);
							PopUpManager.removePopUp(_wisperWin);
							facade.registerMediator(new WisperMediator(gameName,_wisperWin));	
						}
				    }
					break;
				}

				case NotificationString.GAME_ROOM_SUCCESS:
				{

					
					break;
				}
				case NotificationString.OPEN_WISPER:
				{
					if(_wisperWin.isPopUp == true)
					{
						PopUpManager.removePopUp(_wisperWin);
					}
					
					if(_wisperWin.isPopUp == false)
					{	
						_wisperWin.visible = true;
						PopUpManager.addPopUp(_wisperWin,view);
						PopUpManager.centerPopUp(_wisperWin);
						if(!(facade.hasMediator(WisperMediator.NAME)))
						{
							facade.registerMediator(new WisperMediator(gameName,_wisperWin));
						}
						
						var _data:Object = {"userId":(note.getBody()as Object)["userId"],"userName":(note.getBody()as Object)["userName"]};
						//sendNotification(NotificationString.INIT_WISPER_DATA,(note.getBody()as Object));
						sendNotification(NotificationString.INIT_WISPER_DATA,_data);
					}
					break;	
				}
				case NotificationString.CLOSE_WISPER:
				{
					if(_wisperWin.isPopUp == true)
					{
						//facade.removeMediator(WisperMediator.NAME);
						PopUpManager.removePopUp(_wisperWin);
					}
					
					break;
				}
				case NotificationString.EXIT_ROOM:
				{
					sendNotification(NotificationString.CMD_GAME_ROOM,null,CMD_GameRoomCmd.ROOM_SOCKET_CLOSE);
					break;
				}
				case NotificationString.ROOM_SOCKET_CLOSE:
					//	清除聊天信息；
					view.chatView.chatText.cleanAll();
				    ModuleLib.getInstance().gameStage.addModule((ModuleLib.getInstance().lib as HashMap).find("hall") as DisplayObject);
					ModuleLib.getInstance().gameStage.exitRoomBtn.visible = false;
					ModuleLib.getInstance().gameStage.findChairBtn.visible = false;
				    break;
				default:
					break;
			}
		}

		override public function listNotificationInterests():Array
		{
			return [NotificationString.GAME_ROOM_SUCCESS,					
					NotificationString.ROOM_LOGIN,
					NotificationString.OPEN_WISPER,
					NotificationString.CLOSE_WISPER,
					NotificationString.EXIT_ROOM,
					NotificationString.ROOM_SOCKET_CLOSE
					];
		}

		/**
		 * 
		 * @return 
		 */
		public function get view():RoomModule
		{
			return viewComponent as RoomModule;
		}
   
        /**
         * 
         * 设置游戏类型
         */
        public function set gameName(value:String):void{
        	  _gameName = value;
        }
        
        public function get gameName():String{
        	   return _gameName;
        }

	}
}
