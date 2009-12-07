package Application.view.mediator.hall
{
	import Application.NotificationString;
	import Application.model.game.GameManagerProxy;
	import Application.model.interfaces.IGameItem;
	import Application.model.interfaces.IServerItem;
	import Application.model.vo.protocol.login.tagGlobalUserData;
	import Application.utils.GameUtil;
	
	import action.FallowDouDiZhu;
	import action.FallowMajiang;
	import action.IRoomInfo;
	import action.MatchDouDiZhu;
	import action.MatchMajiang;
	
	import common.assets.ModuleLib;
	import common.data.HallConfig;
	import common.data.StringDef;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class HallMediator extends Mediator implements IMediator
	{  
		public static const NAME:String="HallMediator";
		private var _topleftText:Label = ModuleLib.getInstance().gameStage.leftTopText;
		private var _value:tagGlobalUserData;
		private var _totalNum:uint;//房间总人数
		private var explainType:String = "[object MatchDouDiZhu]";		
		private  var gameManager:GameManagerProxy;
		private var _isFirst:Boolean = true;//是否是第一次初始化
		public function HallMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);						
	

		}
		private function init(evt:Event):void{		
			
			if(!getHallComponent().hasEventListener(FlexEvent.INITIALIZE))
			{
				gameManager =  facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy;
				getHallComponent().addEventListener(FlexEvent.INITIALIZE,addConfig);
			}
			
			if(!_isFirst){
				setData();
				
			}
                 
				
		}
        private function addConfig(evt:FlexEvent):void{
        	 getHallComponent().logout_btn.addEventListener(MouseEvent.CLICK,logoutHandle);//切换用户
		     getHallComponent().modify_btn.addEventListener(MouseEvent.CLICK,modifyHandle);//修改资料		
		     getHallComponent().duihuan_btn.addEventListener(MouseEvent.CLICK,duihuanHandle);
		     getHallComponent().addmoney.addEventListener(MouseEvent.CLICK,addMoney);//充值连接
		     _topleftText.addEventListener(MouseEvent.CLICK,onTextLink);//右上角广告链接
		     getHallComponent().majiang.addEventListener(MouseEvent.CLICK,majiangHandle);//显示麻将的所有房间
		     getHallComponent().doudizhu.addEventListener(MouseEvent.CLICK,doudizhuHandle);//显示斗地主的所有房间
		     _topleftText.text = HallConfig.getInstance().getLink("topLeft")["text"];		     //右上角广告链接
		     setData();
		      
		    
        }
        //设置数据
		public  function setData():void{				
			 var headUrl:String;
 			 getHallComponent().nickname.text = tagGlobalUserData.szNickName;//昵称
             getHallComponent().U_quan.text = tagGlobalUserData.lUserUQ.toString();//用户id
             getHallComponent().grade.level = tagGlobalUserData.cbHonorLevel;//用户等级S
             getHallComponent().U_bean.text = tagGlobalUserData.lGameGold.toString()//U豆
            // getHallComponent().honor.text = tagGlobalUserData.cbMember.toString();//荣誉
            if(tagGlobalUserData.wFaceID<10){
            	 headUrl = HallConfig.getInstance().getPhotoFile()+"0"+tagGlobalUserData.wFaceID+".png";
            }else{
            	headUrl = HallConfig.getInstance().getPhotoFile()+tagGlobalUserData.wFaceID+".png"
           }
			 getHallComponent().headPic.url = headUrl;
             doudizhuHandle()//默认打开斗地主
             _isFirst = false; 
		}

		//显示麻将房间
		private function majiangHandle(evt:MouseEvent = null):void{
			clearList();	
			getHallComponent().temp1.visible = false;
			getHallComponent().temp2.visible = true;	
			getHallComponent().arrow_sparrow.visible = true;
			getHallComponent().arrow_doudizhu.visible = false;	
		     getHallComponent().majiang.removeEventListener(MouseEvent.CLICK,majiangHandle);//显示麻将的所有房间
		     getHallComponent().doudizhu.addEventListener(MouseEvent.CLICK,doudizhuHandle);//显示斗地主的所有房间
		     var gameItem:IGameItem = gameManager.getGameItemByGameName(GameManagerProxy.gameKind_majiang) as IGameItem;
		     var arrFallow:Array = new Array;
		     var arrMatch:Array = new Array;
		     if(gameItem){
		     	arrFallow = gameItem.getServerListByTypeName(GameManagerProxy.gameType_xiuxian) as Array;
		     	arrMatch = gameItem.getServerListByTypeName(GameManagerProxy.gameType_jingji) as Array;
		     	_totalNum += gameItem.getOnLineCount(); 
		     }
		    
		     if(arrMatch.length!=0)
		     {
		     	for each(var index:IServerItem in arrMatch)
		     	{		     		
		     		var tempMatch:MatchMajiang = new MatchMajiang(index.getServerName(),index);
		     		var obj:Object = HallConfig.getInstance().getServerObject(index.getServerID());
		     		if(obj!=null){
		     					     	
		     			tempMatch.limitTxt = obj["description"];
		     			tempMatch.shuoming = obj["name"];
		     	
		     		}
		     		getHallComponent().jinji_list.addChild(tempMatch);
					tempMatch.Yes_btn.addEventListener(MouseEvent.CLICK,loginRoom,false,0,true);
					tempMatch.Xiangqing_btn.addEventListener(MouseEvent.CLICK,explainHandle,false,0,true);  
		     	}
		     }
		     if(arrFallow.length!=0)
		     {
		     	for each(var key:IServerItem in arrFallow)
		     	{
		     		var obj:Object = HallConfig.getInstance().getServerObject(key.getServerID());
		     		var tempFallow:FallowMajiang = new FallowMajiang(key.getServerName(),key.getOnlineCount().toString()+"/300","100",key);
		     		if(obj!=null){
		     			tempFallow.limit_txt.text = obj["description"];
		     			tempFallow.moneyNum = obj["multiple"];
		     			tempFallow.limitNum = obj["limit"];
		     		}

		     		
		     		getHallComponent().xiuxian_list.addChild(tempFallow);
					tempFallow.Yes_btn.addEventListener(MouseEvent.CLICK,loginRoom,false,0,true);
		     	}	
		     }		     
				  
		}
		//显示斗地主房间
		private function doudizhuHandle(evt:MouseEvent = null):void{
			clearList();
			getHallComponent().temp1.visible = true;
			getHallComponent().temp2.visible = false;
			getHallComponent().arrow_sparrow.visible = false;
			getHallComponent().arrow_doudizhu.visible = true;	
		    getHallComponent().majiang.addEventListener(MouseEvent.CLICK,majiangHandle);//显示麻将的所有房间
		    getHallComponent().doudizhu.removeEventListener(MouseEvent.CLICK,doudizhuHandle);//显示斗地主的所有房间
			
		    var gameItem:IGameItem = gameManager.getGameItemByGameName(GameManagerProxy.gameKind_doudizhu) as IGameItem;
		    var arrXiuXian:Array = new Array;
		    var arrJingJi:Array = new Array;
		    if(gameItem){
		    	arrXiuXian = gameItem.getServerListByTypeName(GameManagerProxy.gameType_xiuxian) as Array;
		    	arrJingJi =  gameItem.getServerListByTypeName(GameManagerProxy.gameType_jingji) as Array;
		    	_totalNum += gameItem.getOnLineCount();
		    }
		   
			if(arrJingJi.length!=0)
			{
				
				for each(var index:IServerItem in arrJingJi)
				{
					var obj:Object = HallConfig.getInstance().getServerObject(index.getServerID());
					var tempMatch:MatchDouDiZhu = new MatchDouDiZhu(index.getServerName(),index);
		 			if(obj!=null){
						tempMatch.limitTxt = obj["description"];						
		     			tempMatch.shuoming = obj["name"];
		     					
					} 

					getHallComponent().jinji_list.addChild(tempMatch);	
					tempMatch.Yes_btn.addEventListener(MouseEvent.CLICK,loginRoom,false,0,true);
					tempMatch.addEventListener(MouseEvent.MOUSE_OVER,onOver,false,0,true);
				    tempMatch.Xiangqing_btn.addEventListener(MouseEvent.CLICK,explainHandle,false,0,true); 
				}
			}	
			
			if(arrXiuXian.length!=0)
			{
			  	for each(var key:IServerItem in arrXiuXian)
			  	{
			  		var obj:Object = HallConfig.getInstance().getServerObject(key.getServerID());
			  		var tempFallow:FallowDouDiZhu = new FallowDouDiZhu(key.getServerName(),key.getOnlineCount().toString()+"/300人","100",key);
			  		if(obj!=null){
			  			tempFallow.limit_txt.text = obj["description"];
		     			tempFallow.moneyNum = obj["multiple"];
		     			tempFallow.limitNum = obj["limit"];
			  		}

			  		getHallComponent().xiuxian_list.addChild(tempFallow);
					tempFallow.Yes_btn.addEventListener(MouseEvent.CLICK,loginRoom,false,0,true);
			  	}	
			}
		}
		private function duihuanHandle(evt:MouseEvent):void{
			GameUtil.webLink(HallConfig.getInstance().getLink("duihuan")["url"]);
		}
		private function onOver(evt:MouseEvent):void
		{
			//((evt.currentTarget) as DisplayObject).filters = [new ColorMatrixFilter([2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0])];
		}
		/**
		 * 
		 * @param evt 登陆房间
		 */
		private function loginRoom(evt:MouseEvent):void{

			var serverItem:IServerItem = ((evt.currentTarget.parent) as IRoomInfo).serverItem as IServerItem;
			var gamename:String = serverItem.getGameName();//游戏名称
			var address:Object =serverItem.getServerAddr();
			(facade.retrieveProxy(GameManagerProxy.NAME) as GameManagerProxy).setCurrentServerItem(serverItem);//房间信息
			var obj:Object = {gamename:gamename,address:address};
			sendNotification(NotificationString.LOAD_GAME,obj,null);	
		}
		private function explainHandle(evt:MouseEvent):void{
			if(evt.currentTarget.parent.toLocaleString()== explainType){
				GameUtil.webLink(HallConfig.getInstance().getLink("doudizhuMatch")["url"]);//链接斗地主说明
			}else{
				GameUtil.webLink(HallConfig.getInstance().getLink("majiangMatch")["url"]);//链接麻将说明
			}
		}
		private function addMoney(evt:MouseEvent):void{
			GameUtil.webLink(HallConfig.getInstance().getLink("charge")["url"]);
		}
		//这里都要进行修改
		private function jiazai(evt:MouseEvent):void{
	
			 sendNotification(NotificationString.LOAD_GAME);
		}
		private function changeScreen(evt:MouseEvent = null):void{
			 ModuleLib.getInstance().gameStage.setFullScreen();
		}
		private function popUp(evt:MouseEvent):void{		       
             sendNotification(NotificationString.POSTS_EVENT,ModuleLib.getInstance().lib["post1"],"0");
		}
		//切换用户操作
		private function logoutHandle(evt:MouseEvent = null):void{
			//sendNotification(NotificationString.LOGOUT);
			GameUtil.webLink(HallConfig.getInstance().getLink("logout")["url"],"_self");
		}
		//修改资料
        private function modifyHandle(evt:MouseEvent):void{
        	GameUtil.webLink(HallConfig.getInstance().getLink("modify")["url"]);
        }
        private function onTextLink(evt:MouseEvent):void{
            GameUtil.webLink(HallConfig.getInstance().getLink("topLeft")["url"]);
        }
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function getViewComponent():Object
		{
			return viewComponent;
		}
		public function getHallComponent():hall{
			return viewComponent as hall;
		}
		private  function clearList():void{
			if(!_isFirst){
					getHallComponent().xiuxian_list.removeAllChildren();
				    getHallComponent().jinji_list.removeAllChildren();
			}
    	}

		public function dispose():void{
			 clearList();			
			 getHallComponent().majiang.addEventListener(MouseEvent.CLICK,majiangHandle);//显示麻将的所有房间
		     getHallComponent().doudizhu.addEventListener(MouseEvent.CLICK,doudizhuHandle);//显示斗地主的所有房间
		}
		override public function setViewComponent(viewComponent:Object):void
		{
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			      	 NotificationString.UPDATE_ONLINECOUNT
			       ];
		}
		
		override public function handleNotification(notification:INotification):void
		{   
			 switch(notification.getName()){
			 	case NotificationString.UPDATE_ONLINECOUNT:			 	   	 	    
			 		ModuleLib.getInstance().gameStage.onlineNumLabel.text = GameUtil.replaceText(StringDef.ONLINE_NUM,{num:notification.getBody()});//左上方在线人数
			 		break;
			 }

		}
		
		override public function onRegister():void
		{
				getHallComponent().addEventListener(Event.ADDED_TO_STAGE,init);   
		}
		
		override public function onRemove():void
		{
		}
		
	}
}