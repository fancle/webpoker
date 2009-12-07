package chair
{
	import Application.utils.GameUtil;
	
	import common.data.CommonEvent;
	import common.data.StringDef;
	import common.data.gameEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Label;

	public class LandLordTableView extends Canvas implements ITableView
	{
		public function LandLordTableView()
		{
			//TODO: implement function
			super();
			createView();
			placeView();
		}

		private var _childs:Array=[];
		private var _label:Label=new Label();
		private const _positions:Array=[{id: "seat1", _x: "5", _y: "15"}, {id: "seat2", _x: "94", _y: "15"}, {id: "seat3", _x: "50", _y: "70"}, {id: "table", _x: "23", _y: "0"}, {id: "label", _x: "48", _y: "95"}];

		private var _seat1:LandLordSeat;
		private var _seat2:LandLordSeat;
		private var _seat3:LandLordSeat;

		private var _table:LandLordTable;
		private var _tableId:int;		
		
		//	Check table players.
		public function checkIsFull():void
		{
			var i:uint=0;
			var len:uint=_positions.length - 2;

			while (i < len)
			{
				if (!_childs[i].isSit)
				{
					_table.isFull=false;
					return;
				}
				i++;
			}
			
		}

		public function get tableId():int
		{
			return _tableId;
		}

		public function set tableId(value:int):void
		{

			_tableId=value;
			//桌子号和
			_label.text=GameUtil.replaceText(StringDef.TABLE_ID, {num: (value+1)});
			callLater(setWidth);
			setId(); //设置id;
			
		}

		private function createView():void
		{
			_seat1=new LandLordSeat();
			_seat2=new LandLordSeat();
			_seat3=new LandLordSeat();

			_table=new LandLordTable();

			addChild(_table);
			addChild(_seat1);
			addChild(_seat2);
			addChild(_seat3);


			addChild(_label);

			_childs.push(_seat1);
			_childs.push(_seat2);
			_childs.push(_seat3);

			_childs.push(_table);



		}

		/**
		 * 桌子号 椅子的配置
		 */
		public function setId():void
		{
			for(var index:int=0;index<3;index++){
	     		 (_childs[index] as LandLordSeat).chairId = index;
	     		 (_childs[index] as LandLordSeat).tableId = _tableId;
				
			}
		}
		
	
		/**
		 * 
		 * @param value 用户id
		 * @param head  头像信息
		 * @param username	用户名
		 */
		public function setSitDownId(value:int,head:BitmapData,username:String,userId:int):void{
			 if(value<3){	
			 	
			 	  (_childs[value] as IChairView).isSit = true;
			 	  var headPic:Bitmap = new Bitmap(head);
			 	  (_childs[value] as IChairView).setHead(headPic,username,userId);
			 	  
			 	  
			 }
		}
		/**
		 * 
		 * @param value 椅子id
		 */
		public function setStandUp(value:int):void{
			if(value<3){
				 (_childs[value] as IChairView).isSit = false;
				 (_childs[value] as IChairView).clearHead();
			 	  
			}
		}
		private function onClickHandler(event:MouseEvent):void
		{   
			var _seat:LandLordSeat=event.currentTarget as LandLordSeat;
			if(_seat.isSit==false){
				var obj:Object = {tableId:(event.currentTarget as LandLordSeat).tableId,chairId:(event.currentTarget as LandLordSeat).chairId};
				CommonEvent.getInstance().dispatchEvent(new gameEvent(gameEvent.USER_POS,obj));
			}else{	
				var objId:Object = {userId:(event.currentTarget as LandLordSeat).userId,mouseX:(event.stageX),mouseY:(event.stageY)};
				CommonEvent.getInstance().dispatchEvent(new gameEvent(gameEvent.USER_ID,objId));
			}
			event.stopImmediatePropagation();

		}
		
		private function placeView():void
		{
			var i:uint=0;
			var len:uint=_positions.length - 1;

			while (i < len)
			{
				_childs[i].x=_positions[i]["_x"];
				_childs[i].y=_positions[i]["_y"];

				_childs[i++].addEventListener(MouseEvent.CLICK, onClickHandler);
			}

		}
		/**
		 * 
		 * @param value 给定游戏是否正在进行中
		 */
		public function set playStatus(value:Boolean):void{
			_table.isFull=value;
		}
		private function setWidth():void
		{
			_label.x=(this.width - _label.textWidth) / 2+5;
			_label.y=_positions[4]["_y"];

		}
		public function dispose():void{
			this.removeAllChildren();
			
		}
		

		
	}
}