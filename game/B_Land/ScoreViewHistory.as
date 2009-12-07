package B_Land
{
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;

	public class ScoreViewHistory extends DataGrid
	{
		private var m_fScore:ArrayCollection = new ArrayCollection();
		public function ScoreViewHistory()
		{
			super();
			init();
		}
		private function init():void{
			this.styleName = "BlandHistory";
			this.width = 172;
			var columName:DataGridColumn = new DataGridColumn("玩家");
				columName.dataField = "userName";
			var lastColumScore:DataGridColumn = new DataGridColumn("上一局");
				lastColumScore.dataField = "lastScore";
			var totalColumScore:DataGridColumn = new DataGridColumn("历史积分");
				totalColumScore.dataField = "historyScore";
			this.columns = [columName,lastColumScore,totalColumScore];
			this.rowCount = 3;
			this.verticalScrollPolicy = "off";
			this.horizontalScrollPolicy ="off";
		}
		public function SetGameScore(userName:String,fScore:Number,collectScore:Number):void{
			if(m_fScore.length==3)m_fScore.removeAll();
			var obj:Object= new Object();
			if(userName==""){
				obj["userName"] = userName.toString();
				obj["lastScore"] = "";
				obj["historyScore"] = "";
			}else{
				obj["userName"] = userName.toString();
				obj["lastScore"] = fScore.toString();
				obj["historyScore"] = collectScore.toString();
			}

		 	m_fScore.addItem(obj);	
			updataView();
		}
		private function updataView():void{
			if(m_fScore.length==3){
				this.dataProvider = m_fScore;
			}
		}

	}
}