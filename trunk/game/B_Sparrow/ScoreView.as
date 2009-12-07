package B_Sparrow
{
	import B_Land.common.MaterialLib;
	
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.events.CloseEvent;

	public class ScoreView extends TitleWindow
	{
		private var _showSparrow:OverShowSparrow;
		private var closeButton:Button=new Button();
		private var _fanType:Array=new Array();
		private var _fanLabel:TextArea=new TextArea();

		private var _userName0:Label=new Label();
		private var _userName1:Label=new Label();

		private var _user0Score:Label=new Label();
		private var _user1Score:Label=new Label();

		private var _user0Fan:Label=new Label();
		private var _user1Fan:Label=new Label();

		public function ScoreView(value:OverShowSparrow)
		{
			super();
			_showSparrow=value;

			init();
			this.width=450;
			this.height=325;			
			this.setStyle("closeButtonSkin", gameframe_close_btn);
			this.setStyle("closeButtonDisabledSkin", null);
			this.setStyle("closeButtonDownSkin", null);
			this.setStyle("closeButtonOverSkin", null);
			this.setStyle("closeButtonUpSkin", null);
			this.setStyle("borderSkin", MaterialLib.getInstance().getClass("B_sparrow_ScoreView"));
			
			closeButton.setStyle("skin",MaterialLib.getInstance().getClass("B_Sparrow_jiesuan_Btn"));
			this.addEventListener(CloseEvent.CLOSE, onClose);
			this.layout="absolute";
		}

		/**
		 * 传入数据是否显示数据框
		 * @param b
		 *
		 */
		public function showWindow(b:Boolean):void
		{
			this.visible=b;
			if (!b)
			{
				cleanData();
			}
		}

		private function init():void
		{
			_showSparrow.y=70;
			_showSparrow.x=32;
			addChild(_showSparrow);

			closeButton.addEventListener(MouseEvent.CLICK, onCloseBtn, false, 0, true);
			addChild(closeButton);
			addChild(_fanLabel);
			_fanLabel.x= 30;
			_fanLabel.y=120;
			_fanLabel.width= 400;
			_fanLabel.wordWrap = true;
			_fanLabel.selectable = false;
			_fanLabel.setStyle("backgroundAlpha",0);
			_fanLabel.setStyle("borderStyle","none");
			closeButton.x=200;
			closeButton.y=295;

			addChild(_userName0);
			addChild(_userName1);
			
			_userName0.x = 40;
			_userName0.y = 200;
			
			_userName1.x = 40;
			_userName1.y = 230;
			
			_user0Score.x = 350;
			_user0Score.y = 200;
			_user1Score.x = 350;
			_user1Score.y = 230
			
			_user0Fan.x = 200;
			_user0Fan.y = 200;
			
			_user1Fan.x = 200;
			_user1Fan.y = 230;
			
			addChild(_user0Score);
			addChild(_user1Score);

			addChild(_user0Fan);
			addChild(_user1Fan);

		}

		/**
		 *	关闭 提示窗口
		 * @param evt
		 *
		 */
		private function onClose(evt:CloseEvent):void
		{
			this.visible=false;

		}

		/**
		 * 设置结束牌
		 * @param value 结束手中的牌
		 * @param count 结束拍的的个数
		 * @param centerValue 结束的中心牌
		 *
		 */
		public function setSparrowData(value:Array, count:int, centerValue:uint):void
		{
			_showSparrow.SetSparrowData(value, count);
			_showSparrow.setCenterSparrow(centerValue);

		}

		public function setFanType(value:Array):void
		{
			_fanType=value;
			for each (var i:String in _fanType)
			{
				_fanLabel.text+=i.toString() + "  ";
			}
		}

		private function onCloseBtn(evt:MouseEvent):void
		{
			this.visible=false;
			cleanData();
		}

		/**
		 *	设置
		 * @param value
		 *
		 */
		public function setUserScore(value:Array):void
		{
			for each (var i:Object in value)
			{
				if (_userName0.text == "")
				{
					_userName0.text=i["userName"];
					_user0Fan.text =i["fan"];
					_user0Score.text=i["score"];
				}
				else
				{
					_userName1.text=i["userName"];
					_user1Fan.text = i["fan"];
					_user1Score.text=i["score"];
				}

			}
		}

		private function cleanData():void
		{
			_showSparrow.SetSparrowData(null, 0);
			_showSparrow.setCenterSparrow(0);
			_fanLabel.text="";
			_userName0.text="";
			_user0Score.text="";
			_userName1.text="";
			_user1Score.text="";
			
			_user0Fan.text = "";
			_user1Fan.text = "";

		}
	}
}