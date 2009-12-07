package common.game
{
	import Application.model.interfaces.IGameClass;
	import Application.model.interfaces.IGameClassContainer;
	import Application.model.interfaces.IGameView;
	import Application.model.vo.protocol.common.tagMessageBody;
	import Application.model.vo.protocol.gameFrame.CMD_GF_Info;
	import Application.model.vo.protocol.gameFrame.CMD_GF_Option;
	import Application.model.vo.protocol.gameFrame.IPC_GF_ServerInfo;
	import Application.model.vo.protocol.gameFrame.IPC_Message;
	import Application.model.vo.protocol.gameFrame.IPC_Property;
	import Application.model.vo.protocol.gameFrame.IPC_UserStatus;
	import Application.model.vo.protocol.room.tagUserData;
	import Application.model.vo.protocol.room.tagUserScore;
	import Application.utils.SoundManager;
	
	import common.assets.SoundPlay;
	import common.data.CMD_DEF_ROOM;
	import common.data.GlobalDef;
	import common.data.IPC_DEF;
	import common.data.StringDef;
	import common.game.timeutils.TimerMap;
	import common.game.vo.TagServerAttribute;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.modules.Module;
	
	import org.aswing.util.LinkedList;



	public class GameBaseClass extends Module implements IGameClass
	{
		protected var _assets:LoaderInfo;
		protected var m_clientContainer:IGameClassContainer;
		protected var m_GameClientView:GameBaseView;
		
		//房间信息
		protected var m_wTableID:uint; //桌子号码
		protected var m_wChairID:uint; //椅子号码

		protected var m_dwUserID:uint; //用户 I D
		protected var m_ServerAttribute:TagServerAttribute; //房间属性

		//游戏信息
		protected var m_bInquire:Boolean; //关闭询问
		//protected var m_bLookonMode:Boolean;//旁观模式
		protected var m_bGameStatus:uint; //游戏状态

		protected var m_pMeUserItem:tagUserData; //自己信息
		protected var m_pUserItem:Array; //玩家信息
		protected var m_UserItemFactory:LinkedList; //用户信息列表

		//定时器信息
		protected var m_nTimerID:uint; //定时器 ID
		protected var m_nElapseCount:uint; //定时器计数
		protected var m_wTimerChairID:uint; //定期器位置
		protected var m_TimerWork:TimerMap; //定时器

		//声音信息
		private var m_SoundResource:HashMap;

		public function GameBaseClass()
		{
			super();
		}
		///////////////////////////////////////////////////////////////////
		//初始化过程
		///////////////////////////////////////////////////////////////////
		/**
		 * 在框架初始化游戏(传框架引用及游戏资源)后自动执行 
		 * 
		 */
		private function isReady():Boolean
		{
			if (_assets != null && m_clientContainer != null)
			{
				if (InitGameClass() == false)
					return false; //初始化游戏
				return m_clientContainer.OnIPCChannelMessage(IPC_DEF.IPC_MIAN_IPC_KERNEL, IPC_DEF.IPC_SUB_IPC_CLIENT_CONNECT, null, 0);
			}
			return false;
		}
		public function InitGameClass():Boolean
		{
			do
			{
				m_SoundResource=new HashMap();

				//定时器信息
				m_nTimerID=0;
				m_nElapseCount=0;
				m_wTimerChairID=GlobalDef.INVALID_CHAIR;
				m_TimerWork = new TimerMap;

				m_dwUserID=0;
				m_wTableID=GlobalDef.INVALID_TABLE;
				m_wChairID=GlobalDef.INVALID_CHAIR;
				m_bGameStatus=GlobalDef.US_FREE; //状态  空闲

				m_bInquire=true;

				m_ServerAttribute=new TagServerAttribute();
				m_pUserItem=new Array(GlobalDef.MAX_CHAIR);
				//m_UserItemLookon = new LinkedList;
				m_UserItemFactory = new LinkedList;
				
				//初始化游戏view
				if (m_GameClientView == null)
				{
					m_GameClientView=CreateGameView();
					if (m_GameClientView == null)
					{
						break;
					}
					m_GameClientView.x=0;
					m_GameClientView.y=0;
					addChild(m_GameClientView);
				}
				if (m_GameClientView.InitGameView() == false)
				{
					break;
				}
				m_GameClientView.RectifyGameView(758, 595); //这里写死了 以后要注意
				
				return true;
			} while (false)
			
			return false; 
		}

		/**
		 * 添加游戏视图
		 */
		protected function CreateGameView():GameBaseView
		{
			return null;
		}
		///////////////////////////////////////////////////////////////
		//须子类覆盖的方法
		///////////////////////////////////////////////////////////////
		/**
		 * 时间消息
		 * @param wChairID
		 * @param nElapse
		 * @param nTimerID
		 * @return 
		 * 
		 */
		protected function  OnEventTimer(wChairID:uint,  nElapse:uint,  nTimerID:uint):Boolean
		{
			return false;
		}
		/**
		 *  进程消息
		 * @return
		 */
		protected function OnEventProcess(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:*, wDataSize:uint):Boolean
		{
			return false;
		}
		
		/**
		 * 游戏消息 
		 * @param wSubCmdID
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnGameMessage(wSubCmdID:uint, pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			return true;
		}
		
		/**
		 * 框架消息 
		 * @param wSubCmdID
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnFrameMessage(wSubCmdID:uint, pBuffer:ByteArray,  wDataSize:uint):Boolean
		{
			return false;
		}

		/**
		 * 游戏场景消息 
		 * @param cbGameStation
		 * @param bLookonOther
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function OnGameSceneMessage(cbGameStation:uint, pBuffer:ByteArray,  wDataSize:uint):Boolean
		{
			return true;
		}
		
		public function DestroyGameClass():void
		{
			//删除视图资源
			if (m_GameClientView)
			{
				m_GameClientView.DestroyGameView();
				removeChild(m_GameClientView);
				m_GameClientView = null;
			}			
			//删除声音资源
			if(m_SoundResource)
			{
				
				var sa:Array = m_SoundResource.toArray();				
				for (var i:uint=0; i<sa.length; i ++)
				{
					SoundManager.getInstance().stop(sa[i]);
					sa[i].unLoad();
					sa[i] = null;
				}
				m_SoundResource.clear();
				m_SoundResource = null;
			} 
			//删除定时器
			if (m_nTimerID!=0 && m_TimerWork)
			if (m_TimerWork)
			{
				m_TimerWork.killTimer(m_nTimerID);
				m_TimerWork.Destroy();
				m_TimerWork = null;
				m_nTimerID=0;
				m_nElapseCount=0;
				m_wTimerChairID=GlobalDef.INVALID_CHAIR;
			}
			//旁观用户
			/*if (m_UserItemLookon)
			{
				m_UserItemLookon.clear();
				m_UserItemLookon = null;
			}*/

			//游戏用户
			if (m_ServerAttribute && m_UserItemFactory)
			{
				for (var i:uint=0; i<m_ServerAttribute.wChairCount; i++)
				{
					if (m_pUserItem[i]!=null)
					{
						m_UserItemFactory.remove(m_pUserItem[i]);
						m_pUserItem[i]=null;
					}
				}
				m_UserItemFactory.clear();
				m_UserItemFactory = null;
				m_ServerAttribute = null;
			}

			m_clientContainer = null;
			m_pUserItem.length = 0;
			m_pUserItem 	  = null;
			
			//m_bLookonMode=true;
			m_pMeUserItem=null;
			m_bGameStatus=GlobalDef.US_FREE;
			m_wTableID=GlobalDef.INVALID_TABLE;
			m_wChairID=GlobalDef.INVALID_CHAIR;
			
			//m_IMain = null; 
		}
		////////////////////////////////////////////////////////////
		protected function OnTimer(nIDEvent:int):Boolean
		{
			return false;
		}
		
		//////////////////////////////////////////////////////////////////////////////
		//子类调用方法
		//////////////////////////////////////////////////////////////////////////////
		//定时器接口
		//定时器位置
		public function GetTimeChairID():uint
		{
			return m_wTimerChairID;
		}
		protected function SetTimer(wTimerID:int, dwElapse:uint):void
		{
			if (m_TimerWork)
			{
				m_TimerWork.setTimer(wTimerID,dwElapse, timerHandler);
			}
		}
		protected function KillTimer(wTimerID:int):void
		{
			if (m_TimerWork)
			{
				m_TimerWork.killTimer(wTimerID);
			}
		}
		//设置定时器
		public function SetGameTimer(wChairID:uint, nTimerID:uint, nElapse:uint):Boolean
		{
			if (m_ServerAttribute == null ||
				m_TimerWork == null)
			{
				return false;
			}
			//逻辑处理
			if (m_nTimerID!=0)
			{
				KillGameTimer(m_nTimerID);
			}
			if ((wChairID<m_ServerAttribute.wChairCount)&&(nElapse>0))
			{
				//设置变量
				m_nTimerID=nTimerID;
				m_nElapseCount=nElapse;
				m_wTimerChairID=wChairID;

				//设置界面
				m_TimerWork.setTimer(nTimerID,1000, timerHandler);

				return OnEventTimer(m_wTimerChairID,nElapse,nTimerID);

			}

			return false;
		}
		//删除定时器
		public function KillGameTimer(nTimerID:uint):Boolean
		{
			//逻辑处理
			if ((m_nTimerID!=0)&&
			((m_nTimerID==nTimerID)||(nTimerID==0)))
			{
				//设置界面
				if (m_TimerWork)
				{
					m_TimerWork.killTimer(m_nTimerID);
				}
				if (m_wTimerChairID!= GlobalDef.INVALID_CHAIR)
				{
					OnEventTimerKilled(m_wTimerChairID,
					  m_nTimerID);
				
				}
				//设置变量
				m_nTimerID=0;
				m_nElapseCount=0;
				m_wTimerChairID= GlobalDef.INVALID_CHAIR;

				return true;
			}

			return false;
		}
		///////////////////////////////////////////////////////////
		//旁观状态
		public function IsLookonMode():Boolean
		{
			//return m_bLookonMode;
			return false;
		}
		//允许旁观
		public function IsAllowLookon():Boolean
		{
			//return m_bAllowLookon;
			return false
		}
		//状态接口

		//游戏状态
		public function GetGameStatus():uint
		{
			return m_bGameStatus;
		}
		//游戏状态
		public function SetGameStatus( bGameStatus:uint):void
		{
			m_bGameStatus=bGameStatus;
		}
		//用户接口
		//自己位置
		public function GetMeChairID():uint
		{
			return m_wChairID;
		}
		//获取玩家
		public function GetUserInfo(wChairID:uint):tagUserData
		{
			if (wChairID>=GlobalDef.MAX_CHAIR || m_ServerAttribute == null)
			{
				return null;
			}
			if (wChairID>=m_ServerAttribute.wChairCount)
			{
				return null;
			}
			return m_pUserItem[wChairID];
		}
		private function GetFaceCoordinateByUserID(userID:uint):Point
		{
			return m_GameClientView.GetUserFaceCoordinate(userID);
		}
		//发送准备
		protected function SendUserReady(pBuffer:ByteArray, wDataSize:uint):Boolean
		{
			return SendSocketChannelMessage(CMD_DEF_ROOM.MDM_GF_FRAME,CMD_DEF_ROOM.SUB_GF_USER_READY,pBuffer,wDataSize);
		}
		//发送游戏数据
		protected function SendGameData(wSubCmdID:uint,pBuffer:ByteArray=null, wDataSize:uint=0):Boolean
		{
			return SendSocketChannelMessage(CMD_DEF_ROOM.MDM_GF_GAME,wSubCmdID,pBuffer,wDataSize);
		}
		//发送道具信息
		protected function SendProperty(userID:uint):Boolean{
			var p:IPC_Property = new IPC_Property;
			p.userID = userID;
			
			return SendIPCChannelMessage(IPC_DEF.IPC_MAIN_PROPERTY,IPC_DEF.IPC_SUB_PROPERTY_SEND,p);
		}
		////////////////////////////////////////////////////////////
		protected function OnStart(wParam:uint, lParam:uint):uint
		{
			return 0;
		}
		protected function OnExit(wParam:uint, lParam:uint = 0):uint
		{
			SendEventExitGameClient(lParam > 0 ? true : false);
			return 0;
		}
		//////////////////////////////////////////////////////////////////////////////
		//功能方法
		//////////////////////////////////////////////////////////////////////////////
		private function timerHandler(nIDEvent:int):void
		{
			//时间处理
			if ((m_nTimerID==nIDEvent) && (m_wTimerChairID!=GlobalDef.INVALID_CHAIR))
			{
				//消息处理
				if (m_nElapseCount>0)
				{
					m_nElapseCount--;
				}
				
				var bSuccess:Boolean=OnEventTimer(m_wTimerChairID,
				 m_nElapseCount,
				 m_nTimerID);
				if ((m_nElapseCount==0)||(bSuccess==false))
				{
					KillGameTimer(m_nTimerID);
				}
				
				return;
			}
			OnTimer(nIDEvent);
		}
		//时间更新
		protected function  OnEventTimerKilled(wChairID:uint,  nTimerID:uint):void
		{
			var wViewChairID:uint=this.SwitchViewChairID(wChairID);
			if(m_GameClientView)m_GameClientView.SetUserTimer(wViewChairID,0);
		}
		//////////////////////////////////////////////////////////////////////////////
		/**
		 * 获取自己
		 * @return 
		 * 
		 */
		public function GetMeUserInfo():tagUserData
		{
			return m_pMeUserItem;
		}
		
		/**
		 * 房间属性
		 * @return 
		 * 
		 */
		public function GetServerAttribute():TagServerAttribute
		{
			return m_ServerAttribute;
		}
		/**
		 *  处理传过来的基本信息如：房间信息，自己信息等
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		private function OnIPCConfig(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:*, wDataSize:uint):Boolean
		{
			switch (wSubCmdID)
			{
				case IPC_DEF.IPC_SUB_SERVER_INFO:
				{ //房间信息
					if (wDataSize < IPC_GF_ServerInfo.sizeof_IPC_GF_ServerInfo)
					{
						return false;
					}
					var pServerInfo:IPC_GF_ServerInfo=pIPCBuffer as IPC_GF_ServerInfo;
					m_wTableID=pServerInfo.wTableID; //桌子号
					m_wChairID=pServerInfo.wChairID; //椅子号
					m_dwUserID=pServerInfo.dwUserID; //用户id
					if (m_ServerAttribute)
					{
						m_ServerAttribute.wKindID=pServerInfo.wKindID;
						m_ServerAttribute.wServerID=pServerInfo.wServerID;
						m_ServerAttribute.wGameGenre=pServerInfo.wGameGenre;
						
						m_ServerAttribute.wChairCount=pServerInfo.wChairCount;
						m_ServerAttribute.szKindName = String(pServerInfo.szKindName);
						m_ServerAttribute.szServerName = String(pServerInfo.szServerName);
						m_ServerAttribute.fCellScore = Number(pServerInfo.fCellScore);
						m_ServerAttribute.fHighScore = Number(pServerInfo.fHighScore);
						m_ServerAttribute.fLessScore = Number(pServerInfo.fLessScore);
						
						//更新游戏属性
						if(m_GameClientView)
							m_GameClientView.UpdateServerAttribute(m_ServerAttribute);
					}
					return true;
				}
			}
			return false;
		}

		/**
		 * 通知游戏服务端 - 游戏客户端已经OK
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		private function onIPCControl(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:*, wDataSize:uint):Boolean
		{
			switch (wSubCmdID)
			{
				case IPC_DEF.IPC_SUB_START_FINISH:
				{
					//获取场景
					var Info:CMD_GF_Info=new CMD_GF_Info;
					//Info.bAllowLookon=m_bAllowLookon?1:0;
					Info.bAllowLookon= false;
					var pBuffer:ByteArray=Info.toByteArray();
					//发送消息
					SendSocketChannelMessage(CMD_DEF_ROOM.MDM_GF_FRAME, CMD_DEF_ROOM.SUB_GF_INFO, pBuffer, CMD_GF_Info.sizeof_CMD_GF_Info);
					configComplete();
					return true;
					break;
				}
				case IPC_DEF.IPC_SUB_CLOSE_FRAME ://关闭框架
				{
						if(GlobalDef.DEBUG)trace("in GameBaseClass onIPCControl:&&&&&&&&&&&&&&&&&&&&************^ closeGame!");
						m_bInquire=false;
						CloseChannelMessage(true,true);
						
						return true;

				}
				case IPC_DEF.IPC_SUB_CLOSE_GAMECLIENT:		//关闭游戏
				{
					if(pIPCBuffer!=null){
						m_bInquire = (pIPCBuffer["socketConnected"] as int)==0?false:true;
					}
					
					SendEventExitGameClient();
					break;
				}
				case IPC_DEF.IPC_SUB_CLOSE_SOUND:		//关闭游戏音乐
				{
					
					SoundManager.getInstance().setVolumn(0);
					break;
				}
				case IPC_DEF.IPC_SUB_OPEN_SOUND:		//打开游戏音乐
				{
					
					SoundManager.getInstance().setVolumn(1);
					break;
				}
			}
			return false;
		}
		/**
		 * 
		 * 配置完成
		 */
		protected function configComplete():void{
			return;
		}
		/**
		 * 用户信息 
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		private function OnIPCUser(wMainCmdID:uint,
		  wSubCmdID:uint,
		  pIPCBuffer:*, 
		  wDataSize:uint):Boolean
		{
			var i:uint=0;
			switch (wSubCmdID)
			{
				case IPC_DEF.IPC_SUB_USER_COME ://用户消息----发送上桌之前的在桌玩家的时候
					{
						if (wDataSize<tagUserData.sizeof_tagUserData)
						{
							return false;
						}
						var UserData:tagUserData = pIPCBuffer as tagUserData;
						ActiveUserItem(UserData.clone());
				
						return true;
						break;
					};
				case IPC_DEF.IPC_SUB_USER_STATUS ://用户状态---当房间收到SUB_GR_USER_STATUS命令时
					{
						if (wDataSize<IPC_UserStatus.sizeof_IPC_UserStatus)
						{
							return false;
						}
						//消息处理
						var pUserStatus:IPC_UserStatus=pIPCBuffer as IPC_UserStatus;
						if(GlobalDef.DEBUG){
							trace("in GameBaseClass OnIPCUSer---IPC_SUB_USER_STATUS:pUserStatus.dwUserID = " + pUserStatus.dwUserID);
							trace("in GameBaseClass OnIPCUSer---IPC_SUB_USER_STATUS:pUserStatus.cbUserStatus = " + pUserStatus.cbUserStatus);
						}
						if (pUserStatus.cbUserStatus<GlobalDef.US_SIT)
						{
							if (pUserStatus.dwUserID==m_dwUserID)
							{
								DestroyGameClass();
								return true;
							}
							else
							{
								//
								
								DeleteUserItem(pUserStatus.dwUserID);
							}
						}
						else
						{
							//	
							UpdateUserItem(pUserStatus.dwUserID,pUserStatus.cbUserStatus);
						}
						return true;
						break;
					};
				case IPC_DEF.IPC_SUB_USER_SCORE ://用户积分
					{
						/* if (wDataSize<IPC_UserScore.sizeof_IPC_UserScore)
						{
							return false;
						}

						//消息处理
						var pUserScore:IPC_UserScore=pIPCBuffer as IPC_UserScore;
						UpdateUserScore(pUserScore.dwUserID,pUserScore.UserScore); */
						return true;
						break;
					};
				case IPC_DEF.IPC_SUB_GAME_START ://游戏开始----收到桌子状态变为游戏状态时
					{
						if(GlobalDef.DEBUG) trace("in GameBaseClass OnIPCUser:gameStart");
						//设置用户
						if (m_ServerAttribute)
						{
							for (i=0; i<m_ServerAttribute.wChairCount; i++)
							{
								if (m_pUserItem[i]!=null)
								{
									m_pUserItem[i].cbUserStatus=GlobalDef.US_PLAY;
									OnEventUserStatus(m_pUserItem[i],m_pUserItem[i].wChairID,false);
								}
							} 

							return true;
						}
						break;
					};
				case IPC_DEF.IPC_SUB_GAME_FINISH ://游戏结束-----收到桌子状态变为非游戏状态时
					{
						trace("in GameBaseClass OnIPCUser:gameFinish");
						if (m_ServerAttribute)
						{
							//设置用户
							for (i=0; i<m_ServerAttribute.wChairCount; i++)
							{
								if (m_pUserItem[i]!=null)
								{
									m_pUserItem[i].cbUserStatus=GlobalDef.US_SIT;
									OnEventUserStatus(m_pUserItem[i],m_pUserItem[i].wChairID,false);
								}
							}

							return true;
						} 
						break;
					}
			};
			return false;
		}
		/**
		 * 道具信息
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		private function OnIPCProperty(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:*, wDataSize:uint):Boolean
		{
			switch(wSubCmdID){
				case IPC_DEF.IPC_SUB_PROPERTY_RECV:		//接收到道具信息
				{
					//根据道具使用信息里的作用用户ID得到其坐标，然后再发回框架
					var p:IPC_Property = pIPCBuffer as IPC_Property;
					p.userCoordinate = GetFaceCoordinateByUserID(p.userID);
					
					SendIPCChannelMessage(IPC_DEF.IPC_MAIN_PROPERTY,IPC_DEF.IPC_SUB_PROPERTY_RECV,p);
					return true;
				}
			}
			return false;
		}
		/**
		 * 用户进入
		 * 		通知界面层改变显示
		 * @param pUserData
		 * @param wChairID
		 * @param bLookonUser
		 * 
		 */
		protected function  OnEventUserEnter(pUserData:tagUserData,  wChairID:uint,  bLookonUser:Boolean):void
		{
		
			if (bLookonUser == false)
			{
				var wViewChairID:uint=this.SwitchViewChairID(wChairID);
				m_GameClientView.SetUserInfo(wViewChairID,pUserData);
				
				//if(wChairID == GetMeChairID())
					//m_GameClientView.SetNetSpeed(pUserData.wNetDelay);
			} 
		}
		/**
		 * 用户离开
		 * 		通知界面层改变显示
		 * @param pUserData
		 * @param wChairID
		 * @param bLookonUser
		 * 
		 */
		protected function  OnEventUserLeft(pUserData:tagUserData,  wChairID:uint,  bLookonUser:Boolean):void
		{
		
			if (bLookonUser == false)
			{
			
				var wViewChairID:uint=this.SwitchViewChairID(wChairID);
				m_GameClientView.SetUserInfo(wViewChairID,null);
			} 
		}
		//用户积分
		protected function  OnEventUserScore(pUserData:tagUserData,  wChairID:uint,  bLookonUser:Boolean):void
		{
		}
		/**
		 * 用户状态
		 * 		通知界面层改变显示
		 * @param pUserData
		 * @param wChairID
		 * @param bLookonUser
		 * 
		 */
		protected function  OnEventUserStatus(pUserData:tagUserData,  wChairID:uint,  bLookonUser:Boolean):void
		{
			if (bLookonUser == false)
			{
				var wViewChairID:uint=this.SwitchViewChairID(wChairID);
				m_GameClientView.SetUserStatus(wViewChairID,pUserData);
				//if(wChairID == GetMeChairID())
					//m_GameClientView.SetNetSpeed(pUserData.wNetDelay);
			} 
		}
		/**
		 * 接收到socket消息的处理 
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		private function OnIPCSocket(wMainCmdID:uint,
									wSubCmdID:uint,
									pBuffer:ByteArray,
									wDataSize:int):Boolean
		{
			//特殊处理
			var bHandle:Boolean=false;

			bHandle=OnEventSocket(wMainCmdID,wSubCmdID,pBuffer,wDataSize);//处理框架消息、游戏消息
			//默认处理
			if ((bHandle==false)&&(wMainCmdID== CMD_DEF_ROOM.MDM_GF_FRAME))
			{
				switch (wSubCmdID)
				{
					case CMD_DEF_ROOM.SUB_GF_OPTION ://游戏配置
						{
							var pOption:CMD_GF_Option=CMD_GF_Option.readData(pBuffer);
							m_bGameStatus=pOption.bGameStatus;
							//m_bAllowLookon=pOption.bAllowLookon?true:false; 
							if(GlobalDef.DEBUG)trace("in GameBaseClass OnIPCSocket:m_bGameStatus = " + m_bGameStatus);
							return true;
						}
					case CMD_DEF_ROOM.SUB_GF_SCENE ://游戏场景
						{
							return OnGameSceneMessage(m_bGameStatus,pBuffer,wDataSize);
						}
					case CMD_DEF_ROOM.SUB_GF_MESSAGE ://系统消息
						{
							return true;
						}
				};
				return true;
			}
			return bHandle;
		}
		//网络消息
		private function OnEventSocket(wMainCmdID:uint,
										wSubCmdID:uint,
										pBuffer:ByteArray,
										wDataSize:int):Boolean
		{
			
			switch (wMainCmdID)
			{
				case CMD_DEF_ROOM.MDM_GF_FRAME ://框架消息
				{
					return OnFrameMessage(wSubCmdID,pBuffer,wDataSize);
				}
				case CMD_DEF_ROOM.MDM_GF_GAME ://游戏消息
				{
					return OnGameMessage(wSubCmdID,pBuffer,wDataSize);
				}
			}

			return false;
		}
		
		private function GetExitFlags():Boolean
		{
			if (m_pMeUserItem==null)
			{
				return true;
			}
			if (m_pMeUserItem.cbUserStatus!=GlobalDef.US_PLAY)
			{
				return true;
			}
			
			return m_bInquire == true?false:true; 
			return true;
		}
		private function SendEventExitGameClient2(bAutoSitChairAgain:Boolean = false):void
		{
			if (m_clientContainer)
			{
				m_clientContainer.DestroyGameClass(this, bAutoSitChairAgain);
			} 
		}
		private function CloseChannelMessage( bNotifyServer:Boolean, bNotifySink:Boolean):void
		{
			//发送关闭消息
			if (bNotifyServer==true)
			{
				SendIPCChannelMessage(IPC_DEF.IPC_MIAN_IPC_KERNEL,IPC_DEF.IPC_SUB_IPC_CLIENT_CLOSE);
			}
		}
		//增加用户
		private function ActiveUserItem(pActiveUserData:tagUserData):Boolean
		{
			if (pActiveUserData.wTableID== GlobalDef.INVALID_TABLE ||
			m_ServerAttribute == null ||
			m_UserItemFactory == null)
			{
				return false;
			}
			if (pActiveUserData.wChairID>=m_ServerAttribute.wChairCount)
			{
				return false;
			}
			m_UserItemFactory.append(pActiveUserData);
			//设置变量
			var bLookonMode:Boolean=(pActiveUserData.cbUserStatus== GlobalDef.US_LOOKON);
			if (bLookonMode==false)
			{
				m_pUserItem[pActiveUserData.wChairID]=pActiveUserData;
			}
			else
			{
				/* if (m_UserItemLookon)
				{
					m_UserItemLookon.append(pActiveUserData);
				} */
			}

			//判断自己
			if (m_dwUserID==pActiveUserData.dwUserID)
			{
				//m_bLookonMode=bLookonMode;
				m_pMeUserItem=pActiveUserData;
				m_wTableID=m_pMeUserItem.wTableID;
				m_wChairID=m_pMeUserItem.wChairID;
			}

			//通知改变
			OnEventUserEnter(pActiveUserData,pActiveUserData.wChairID,bLookonMode);

			return true;
		}
		//删除用户
		private function DeleteUserItem(dwUserID:uint):Boolean
		{
			
			if (m_ServerAttribute == null ||
			m_UserItemFactory == null)
			{
				return false;
			}
			//游戏用户
			var pUserData:tagUserData=null;
			for (var i:uint=0; i<m_ServerAttribute.wChairCount; i++)
			{
				pUserData=m_pUserItem[i];
				if ((pUserData!=null)&&(pUserData.dwUserID==dwUserID))
				{
					//设置变量
					m_pUserItem[i]=null;
					m_UserItemFactory.remove(pUserData);

					//通知改变
					OnEventUserLeft(pUserData,pUserData.wChairID,false);

					return true;
				}
			}

			//旁观用户
			/* if (m_UserItemLookon && m_UserItemFactory)
			{
				for (var i:uint=0; i<m_UserItemLookon.size(); i++)
				{
					pUserData=m_UserItemLookon.get(i);
					if (pUserData.dwUserID==dwUserID)
					{
						//设置变量
						m_UserItemLookon.removeAt(i);
						m_UserItemFactory.remove(pUserData);

						//判断自己
						if (m_dwUserID==dwUserID)
						{
							m_pMeUserItem=null;
							m_wTableID=INVALID_TABLE;
							m_wChairID=INVALID_CHAIR;
						}
						
						//通知改变
						OnEventUserLeft(pUserData,
							  pUserData.UserStatus.wChairID,true);
						

						return true;
					}
				} 
			}*/

			return false;
		}
		//更新用户
		private function UpdateUserScore(dwUserID:uint, pUserScore:tagUserScore):Boolean
		{
			//寻找用户
			var pUserData:tagUserData=SearchUserItem(dwUserID);
			if (pUserData==null)
			{
				return false;
			}

			//设置数据

			//通知改变
			var bLookonUser:Boolean=(pUserData.cbUserStatus== GlobalDef.US_LOOKON);
		
			OnEventUserScore(pUserData,pUserData.wChairID,bLookonUser);
			return true;
		}
		private function UpdateUserItem(dwUserID:uint,cbUserStatus:uint):Boolean
		{
			//寻找用户
			var pUserData:tagUserData=SearchUserItem(dwUserID);
			if (pUserData==null)
			{
				return false;
			}

			//设置数据
			//pUserData.wNetDelay=wNetDelay;
			pUserData.cbUserStatus=cbUserStatus;
			
			//通知改变
			var bLookonUser:Boolean=(cbUserStatus==GlobalDef.US_LOOKON);
			OnEventUserStatus(pUserData,pUserData.wChairID,bLookonUser);
			return true;
		}
		//查找用户
		private function SearchUserItem(dwUserID:uint):tagUserData
		{
			if (m_UserItemFactory == null)
			{
				return null;
			}
			//变量定义
			var wIndex:uint=0;
			var pUserData:tagUserData=null;

			//寻找用户
			do
			{
				pUserData=m_UserItemFactory.get(wIndex++);
				if (pUserData==null)
				{
					break;
				}
				if (pUserData.dwUserID==dwUserID)
				{
					return pUserData;
				}
			} while (true);

			return null;
		}
		//切换椅子
		protected function SwitchViewChairID( wChairID:uint):uint
		{
			var pMeUserData:tagUserData = GetMeUserInfo();
			var pServerAttribute:TagServerAttribute = GetServerAttribute();
			if(pMeUserData == null || pServerAttribute == null)
			{
				return 0;
			}
			//转换椅子
			var wViewChairID:uint=(wChairID+pServerAttribute.wChairCount-pMeUserData.wChairID);
			switch (pServerAttribute.wChairCount)
			{
				case 2 :
					{
						wViewChairID+=1;
						break;
					};
				case 3 :
					{
						wViewChairID+=1;
						break;
					};
				case 4 :
					{
						wViewChairID+=2;
						break;
					};
				case 5 :
					{
						wViewChairID+=2;
						break;
					};
				case 6 :
					{
						wViewChairID+=3;
						break;
					};
				case 7 :
					{
						wViewChairID+=3;
						break;
					};
				case 8 :
					{
						wViewChairID+=4;
						break;
					}
			};
			return wViewChairID % pServerAttribute.wChairCount;
		}
		private function MessageCallBack(evt:CloseEvent):void
		{
			if(evt.detail == Alert.OK){
				SendEventExitGameClient2();
			}else if(evt.detail == Alert.CANCEL){
				return;
			}
		}
		//////////////////////////////////////////////////////////////////////////////
		//封装的发送消息方法
		//////////////////////////////////////////////////////////////////////////////
		/**
		 * 发送socket数据
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function SendSocketChannelMessage(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:ByteArray=null, wDataSize:uint=0):Boolean
		{
			if (m_clientContainer)
			{
				return m_clientContainer.OnIPCSocketMessage(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize);
			}
			else
			{
				return false;
			}
		}
		/**
		 * 发送信道数据 
		 * @param wMainCmdID
		 * @param wSubCmdID
		 * @param pIPCBuffer
		 * @param wDataSize
		 * @return 
		 * 
		 */
		protected function SendIPCChannelMessage(wMainCmdID:uint,
												  wSubCmdID:uint,
												  pIPCBuffer:* = null, 
												  wDataSize:uint = 0):Boolean
			{
				if (m_clientContainer)
				{
					return m_clientContainer.OnIPCChannelMessage(wMainCmdID,wSubCmdID,pIPCBuffer,wDataSize);
				}
				else
				{
					return false;
				}
			}
		//////////////////////////////////////////////////////////////////////////////
		//实现IGameClass接口
		//////////////////////////////////////////////////////////////////////////////
		/**
		 * 取出游戏资源 
		 * @return 
		 * 
		 */
		public function get assets():LoaderInfo
		{
			if (_assets != null)
			{
				return _assets as LoaderInfo;
			}
			return null;
		}

		/**
		 * 得到框架传来的框架引用
		 * @param value
		 */
		public function CreateGameClient(value:IGameClassContainer,assets:LoaderInfo=null):Boolean
		{
			m_clientContainer=value;
			if(assets){
				_assets=assets;
			}
			return isReady();
		}
		/**
		 * 销毁游戏客户端 
		 * 
		 */
		public function DestroyGameClient():void
		{
			if(m_clientContainer != null)
			{
				DestroyGameClass();
				m_clientContainer = null;
			}
		}
		/**
		 *  获取影片
		 * @return 
		 * 
		 */
		public function GetMovieClip():UIComponent
		{
			return this;
		}
		/**
		 * 获取游戏视图 
		 * @return 
		 * 
		 */
		public function GetGameView():IGameView
		{
			if (m_GameClientView == null)
			{
				return null;
			}
			else
			{
				return m_GameClientView  as  IGameView;
			}
		}
		/**
		 * 退出游戏 
		 * @param bAutoSitChairAgain
		 * 
		 */
		public function SendEventExitGameClient(bAutoSitChairAgain:Boolean = false):void
		{
			if(GetExitFlags() == false)
			{
				//弹出警告
				var messageBody:tagMessageBody = new tagMessageBody;
				messageBody.closeHandler = MessageCallBack;
				messageBody.type = "0";
				messageBody.text= StringDef.IDS_PLAYINGANDCANNTEXITGAME;
				
				var ipcMessage:IPC_Message = new IPC_Message;
				ipcMessage.bMessageCode = GlobalDef.SMT_EJECT;//弹出消息
				ipcMessage.oMessageBody = messageBody;
				
				SendIPCChannelMessage(IPC_DEF.IPC_MIAN_IPC_KERNEL,IPC_DEF.IPC_SUB_IPC_MESSAGE,ipcMessage);
				
				return;
			}
			SendEventExitGameClient2(bAutoSitChairAgain);
		}
		//////////////////////////////////////////////////////////////////////////////
		//实现IChannelMessage接口
		//////////////////////////////////////////////////////////////////////////////
		//处理信道消息
		public function OnIPCChannelMessage(wMainCmdID:uint, wSubCmdID:uint, pIPCBuffer:*, wDataSize:uint):Boolean
		{
			if (OnEventProcess(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize))
			{
				return true;
			}
			switch (wMainCmdID)
			{
				//配置信息
				case IPC_DEF.IPC_MAIN_CONFIG:
				{
					return OnIPCConfig(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize);
					break;
				}
				case IPC_DEF.IPC_MAIN_CONTROL:
				{
					return onIPCControl(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize);
					break;
				}
				case IPC_DEF.IPC_MAIN_USER:
				{
					//在这处理已有玩家和新入玩家
					return OnIPCUser(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize);
					break;
				}
				case IPC_DEF.IPC_MAIN_PROPERTY:		//道具信息
				{
					return OnIPCProperty(wMainCmdID, wSubCmdID, pIPCBuffer, wDataSize);
					break;
				}
			}
			return false;
		}
		//处理socket消息
		public function OnIPCSocketMessage(wMainCmdID:uint, wSubCmdID:uint, pBuffer:ByteArray, wDataSize:int):Boolean
		{
			var bSuccess:Boolean=OnIPCSocket(wMainCmdID,wSubCmdID,pBuffer,wDataSize);
			if (bSuccess==false)
			{
				m_bInquire=false;	
				SendEventExitGameClient();
				return false;
			}
			return true;
		}
		
		public function AddGameSound(strName:String,sound:Class):void
		{
			if(this.m_SoundResource == null || strName.length == 0 || sound == null)
				return;
			var player:SoundPlay = new SoundPlay;
			if(player.LoadLocalSoundData(sound))
			{
				m_SoundResource.insert(strName,player);
			}
		}
		
		public function PlayGameSound(strName:String,loop:Boolean = false):void
		{
			if(m_SoundResource == null){
				return;
			}	
			
			var player:SoundPlay = m_SoundResource.find(strName);
			if(player == null)
			{
				trace("PlayGameSound no find " + strName);
				return;
			}
			SoundManager.getInstance().playSound(player,loop);
		}
		
	}
}