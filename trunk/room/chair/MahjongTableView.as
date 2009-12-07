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

	public class MahjongTableView extends Canvas implements ITableView
	{
		private const _positions:Array = [{id:"seat1",_x:"17",_y:"15"},
										{id:"seat1",_x:"139",_y:"15"},
										{id:"table",_x:"65",_y:"0"},
										{id: "label", _x: "65", _y: "70"}];
		
		private var _childs:Array = [];
		private var _label:Label = new Label();
		private var _seat1:MahjongSeat;
		private var _seat2:MahjongSeat;
		
		private var _table:MahjongTable;
		private var _tableId:int;
		
		public function MahjongTableView()
		{
			//TODO: implement function
			super();
			creatView();
			placeView();
		}
		
		// Create table
		public function creatView():void
		{
			_seat1 = new MahjongSeat();
			_seat2 = new MahjongSeat();
			
			_table = new MahjongTable();
			
			addChild(_seat1);
			addChild(_seat2);
			
			addChild(_table);
			addChild(_label);
			
			_childs.push(_seat1);
			_childs.push(_seat2);
			_childs.push(_table);
		}
		public function set tableId(value:int):void{
			_tableId=value;
			_label.text=GameUtil.replaceText(StringDef.TABLE_ID, {num: (value+1)});
			callLater(setWidth);
			setId(); //设置id;
		}
		private function setWidth():void
		{
			_label.x=(this.width - _label.textWidth) / 2+10;
			_label.y=_positions[3]["_y"];

		}
		/**
		 * 桌子号 椅子的配置
		 */
		public function setId():void
		{
			for(var index:int=0;index<2;index++){
	     		 (_childs[index] as MahjongSeat).chairId = index;
	     		 (_childs[index] as MahjongSeat).tableId = _tableId;
				
			}
		}
		public function get tableId():int{
			 return _tableId;
		}
		/**
		 * 
		 * 设置座位的坐下状态  这个有问题需要重新写接口
		 */
		public function setSitDownId(value:int,head:BitmapData,username:String,userId:int):void{
			 if(value<2){	
			 	
			 	  (_childs[value] as IChairView).isSit = true;
			 	  var headPic:Bitmap = new Bitmap(head);
			 	  (_childs[value] as IChairView).setHead(headPic,username,userId);
			 	  
			 	  
			 }
		}	
		/**
		 * 
		 * 设置座站起来
		 */
		public function setStandUp(value:int):void{
			if(value<2){
				 (_childs[value] as IChairView).isSit = false;
				 (_childs[value] as IChairView).clearHead();
			 	  
			}
		}
		// Arrange tables and chairs 
		public function placeView():void
		{
			var i:uint = 0;
			var len:uint = _positions.length-1;
	
			while( i < len)
			{
				_childs[i].x = _positions[i]["_x"];
				_childs[i].y = _positions[i]["_y"];			
				_childs[i++].addEventListener(MouseEvent.CLICK,onClickHandler);
			}
		}
		
		//	Check table players.
		public function checkIsFull():void
		{
			var i:uint = 0;
			var len:uint = _positions.length - 1;
			
			while(i < len)
			{
				if(!_childs[i].isSit)
				{
					_table.isFull = false;
					return;	
				}
				i++;
			}
			_table.isFull = true;
		}
		/**
		 * 
		 * @param value 给定游戏是否正在进行中
		 */
		public function set playStatus(value:Boolean):void{
			_table.isFull=value;
		}
		private function onClickHandler(event:MouseEvent):void
		{
			var _seat:MahjongSeat=event.currentTarget as MahjongSeat;
			if(_seat.isSit==false){
				var obj:Object = {tableId:(event.currentTarget as MahjongSeat).tableId,chairId:(event.currentTarget as MahjongSeat).chairId};
				CommonEvent.getInstance().dispatchEvent(new gameEvent(gameEvent.USER_POS,obj));
			}else{	
				var objId:Object = {userId:(event.currentTarget as MahjongSeat).userId,mouseX:(event.stageX),mouseY:(event.stageY)};
				CommonEvent.getInstance().dispatchEvent(new gameEvent(gameEvent.USER_ID,objId));
			}
			event.stopImmediatePropagation();
		}

		public function dispose():void{
				this.removeAllChildren();
		}
	}
}