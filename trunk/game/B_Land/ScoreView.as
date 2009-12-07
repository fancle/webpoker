package B_Land
{
	import Application.utils.Memory;
	
	import B_Land.common.MaterialLib;
	
	import mx.containers.TitleWindow;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;

	public class ScoreView extends TitleWindow
	{
		protected var m_fScore:Array = new Array();
		private var _dataGrid:DataGrid = new DataGrid;
		public function ScoreView()
		{
			super();
			init();
			this.width = 333.9;
			this.height = 202.5;
			this.showCloseButton = true;
			//this.setStyle("borderSkin",MaterialLib.getInstance().getClass("ScoreView_Lost"));
			this.setStyle("closeButtonSkin",gameframe_close_btn);
			this.setStyle("closeButtonDisabledSkin",null);
			this.setStyle("closeButtonDownSkin",null);
			this.setStyle("closeButtonOverSkin",null);
			this.setStyle("closeButtonUpSkin",null);
			this.layout = "absolute";
			this.addChild(_dataGrid);
			this.addEventListener(CloseEvent.CLOSE,onClose);
			
		}
		private function init():void{
			_dataGrid.width = 317;
			_dataGrid.height = 105;
			_dataGrid.x = 10;
			_dataGrid.y = 27;
			_dataGrid.columnCount = 2;
			

			var columName:DataGridColumn = new DataGridColumn("玩家");
				columName.dataField = "userName";
			var columScore:DataGridColumn = new DataGridColumn("得分");
				columScore.dataField = "fScore";
	
			_dataGrid.columns = [columName,columScore];
			
			_dataGrid.styleName = "bland";
			_dataGrid.rowCount = 3;
			
			
		
		}

		/**
		 * 设置显示并决定显示风格
		 * @param b 是否显示
		 * @param winB 是否显示胜利风格
		 * 
		 */
		public function ShowWindow(b:Boolean,winB:Boolean = true):void{
			if(winB){
				this.setStyle("borderSkin",MaterialLib.getInstance().getClass("ScoreView_Win"));
			}else{
				this.setStyle("borderSkin",MaterialLib.getInstance().getClass("ScoreView_Lost"));
			}
			this.visible = b;
			 m_fScore = [];
			
		}
				/**
		 *  设置显示数据
		 * @param wChairID 椅子号
		 * @param fScore 分数
		 * 
		 */
		public function SetGameScore(userName:String, fScore:Number):void{
			var obj:Object= new Object();
			obj["userName"] = userName.toString();
			obj["fScore"] = fScore.toString();
			m_fScore.push(obj);		
			updataView();
		}

				//重置积分
		public function  ResetScore():void
		{
			//设置数据
			Memory.ZeroArray(m_fScore, Number(0));
		}
		//更行数据
		private function updataView():void{
			if(m_fScore.length==3){
				_dataGrid.dataProvider = m_fScore;
			}
			
		}
		/**
		 *关闭按钮 
		 * @param evt
		 * 
		 */
		private function onClose(evt:CloseEvent):void{
			 m_fScore = [];
			 this.visible = false;
			 //触发可能要准备的接口
		}

	}
}