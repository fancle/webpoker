package
{
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	import org.gif.player.GIFPlayer;

	public class RichCanvas extends Canvas
	{
		//private static const testText:String = "测试表情|Ωaz|Ωac|第一个测试|Ωad|文本测试表情测试表情测试表情测试表情测试表情测试表情测试表情测试表情测试表情测|Ωac|";
		private var _emotionHolder:EmotionHolder;
		
		//	表情配置文件
		private var _emotionXML:XML;
		
		 // 文本TextFormat
		private var _textFormat:TextFormat;
		
		//	消息队列
		private var _msgQueue:Array;

		//	总行数
		private var _rows:int = 0;
		
		//	总列数
		private var _columns:int = 0;
		
		//	当前编辑行
		private var _currentRows:int = 0;
		
		//	行高
		private var _rowHeight:int = 25;
		
		//	当前单条消息内容列表
		private var _blocks:Array;
		
		//	UIBlock存储显示页面消息条数
		private var _uiBlocks:Array;
		
		private var _preEndX:Number = 0;
		
		private var _preEndY:Number = 0;
		
		private var _fontWidth:Number = 13;
		
		private static const vSpace:int = 2;
		private static const hSpace:int = 2;
		
		public function RichCanvas()
		{
			super();
			//this.setStyle("backgroundColor","0xFFCCFF");
			_uiBlocks = [];
			
			_emotionHolder = new EmotionHolder();
			_emotionXML = EmotionHolder.getData();	
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "on";
			_textFormat = new TextFormat();
			_textFormat.size = 13;
			_textFormat.color = "0xFF0000";
		}
		
		// Text to Array for display
		private function parseText(_text:String):Array
		{
			return _text.split("|") as Array;
		}
		
		//	对外公开的聊天文本接口
		public function dispalyMsg(_msg:String):void
		{
			_blocks = parseText(_msg);
			displayText(_blocks);
		}
		
		//	显示一个消息文本数组；
		private function displayText(_array:Array):void
		{
			for(var i:int = 0; i < _blocks.length; i++)
			{
				//trace("_blocks[i]======"+i+"=========>>>"+_blocks[i]);
				appendMsg(_blocks[i]);
			}
		}
		
		//	添加消息到输出
		private function appendMsg(_string:String):void
		{
			var _UIComponent:UIComponent;
			var _classRef:Class = this.isEmotion(_string);
			
			if(_classRef != null)
			{
				//trace("GIFPLAYER-------------------------------->>");
				var _gifPlayer:GIFPlayer = new GIFPlayer();
				_gifPlayer.loadBytes(new _classRef() as ByteArray);
				_UIComponent = new Image();
				_UIComponent.name = "image";
				_UIComponent.width = 26;
				_UIComponent.addChild(_gifPlayer);
			}
			else
			{
				trace("Label-------------------------------->>");
				_UIComponent = new Label();
				_UIComponent.name = "label";
				(_UIComponent as Label).text = 	_string;
				this.setTextforma(_UIComponent);	
			}
			
			PreTypesetting(_UIComponent);
		}
		
		protected function typesetting(_UIText:UIComponent):void
		{
			
		}
		
		protected function automaticTypesetting():void
		{
			
		}
		
		private function PreTypesetting(_UIText:UIComponent):void
		{
			if(checkWidth(_UIText))
			{
				//trace("TRUE------------------------------------>>");
				_UIText.x = _preEndX;
				_UIText.y = _preEndY;
				this.addChild(_UIText);
				this._uiBlocks.push(_UIText);
				_preEndX = _UIText.x + _UIText.width;
			}
			else
			{
				trace("FALSE------------------------------------>>");
				validateEdge(_UIText);
				return;	
			}
			
			//trace("_UIText--------->>WIDTH=====>>::"+_UIText.width+"===HEIGHT===>>::"+_UIText.height);
			//trace("_UIText----------->>XX=====>>::"+_UIText.x+"===YY==>>::"+_UIText.y);
		}
		
		private function validateEdge(_UIText:UIComponent):void
		{
			if(_UIText.name == "image")
			{
				doEnter();
				PreTypesetting(_UIText);
			}
			else
			{
				//var _subText:Array = 
				splitLabel(_UIText);
			}
		}
		
		//	验证添加文本宽度是否适合,如果不适合当前行尺寸
		private function checkWidth(_UIText:UIComponent,_newRow:Boolean = false):Boolean
		{
			addChild(_UIText);
			this.validateNow();
			
			//trace("_UIText------XXXX--->>::"+_UIText.x+"=======YYYY========>>::"+_UIText.y);
			//trace("_UIText--------WIDTH--->>::"+_UIText.width+"=======HEIGHT========>>::"+_UIText.height);
			
			
			_UIText.x = _preEndX;
			
			//if(_UIText.x + _UIText.width >  textWidth)
			if(_UIText.x + _UIText.width >textWidth)
			{
				this.removeChild(_UIText);
				return false;
			}
			else
			{
				this.removeChild(_UIText);
				return true;	
			}
			return false;
		}
		
		private function doEnter():void
		{
			this._currentRows++;
			this._rows++;	
			this._preEndX = 0;
			this._preEndY = _currentRows * 25;
		}
		
		
		public function splitLabel(_uiLabel:UIComponent):void
		{
			/* trace("splitLabel========0000000000========================>>");
			trace((_uiLabel as Label).text); */
			
			//var _count:int = int((textWidth- _preEndX)/(fontWidth));
			var _count:int = int((this.width- _preEndX)/(fontWidth));
			var _len:int = ((_uiLabel as Label).text).length;
			
			var _text1:String = (_uiLabel as Label).text.substr(0,_count);
			var _text2:String = (_uiLabel as Label).text.substring(_count,_len); 
			
			/* trace("qieduan===============================>>::"+int((textWidth- _preEndX)/(fontWidth)));		
			trace("----------------^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---------------------->>>");
			trace(_text1);
			trace("----------------^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---------------------->>>");
			trace(_text2);
			trace("----------------^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---------------------->>>"); */
			var _firstLabel:Label = new Label();

			_firstLabel.text = _text1;
			_firstLabel.name = "label";
			this.setTextforma(_firstLabel);
			this.PreTypesetting(_firstLabel);
			//trace("_firstLabel======111===========>>:"+_firstLabel.text);
			
			this.doEnter();
			
			var _sndLable:Label = new Label();
			_sndLable.text = _text2;
			/* if(_sndLable.text == _firstLabel.text)
			{
				trace("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
				return;
			} */
			_sndLable.name = "label";
			this.setTextforma(_sndLable);
			this.PreTypesetting(_sndLable);
			//trace("_sndLable=======222==========>>:"+_sndLable.text);	
		}
		
		//	刷新文本消息显示(刷新历史消息)
		public function update():void
		{
			
		}
		
		//	清楚文本消息
		public function clear():void
		{
			
				this._preEndX = 0;
				this._preEndY = 0;
				this._rows = 0;
				this._currentRows = 0;
				_uiBlocks = [];
				this.removeAllChildren();

		}
		
		//	检测显示对象是文本OR表情
		private function isEmotion(_string:String):Class
		{
			var _xmlList:XMLList = _emotionXML.emotion;
			
			if(_string.charAt(0) != "/")
			{
				return null;
			}
			
			for(var i:int = 0; i < _xmlList.length(); i++)
			{
				if(_xmlList[i].@name == _string)
				{
					return _emotionHolder[_xmlList[i].@classname] as Class;
				}
			}
			
			return null;
		}
		
		//	设置RichField的TextFormat
		private function setTextforma(target:UIComponent = null,_tf:TextFormat = null):void
		{
			if(target == null)
			{
				return;
			}
			
			if(_tf == null)
			{
				(target as Label).setStyle("fontSize",13);
				(target as Label).setStyle("color","0xFF0000");
				(target as Label).height = 24;	
				_fontWidth = 13;
			}
			else
			{
				(target as Label).setStyle("fontSize",_tf.size);
				(target as Label).setStyle("color",_tf.color);
				(target as Label).height = 24;	
				_fontWidth =Number(_tf.size);
			}
		}
		
		
		private function get textWidth():Number
		{
			return this.width - 14;
			//return this.width ;
		}
		
		private function testArray(_aray:Array):void
		{
			for(var i:int = 0; i < _aray.length; i++)
			{
				//trace(i+"=-=========["+i+"]================>>>::"+_aray[i]);
			}
		}
		
		private function get fontWidth():Number
		{
			return _fontWidth + 4;			
		}
	}
	
}