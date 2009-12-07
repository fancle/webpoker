package Application.view.mediator.gameframe
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.flash.UIMovieClip;
	
	public class PropsAction extends UIComponent
	{
		private var poshui:poshui_action = new poshui_action();
		private var zhuan:zhuan_action = new zhuan_action();
		private var hua:hua_action = new hua_action();
		private var guzhang:guzhang_action = new guzhang_action();
		public function PropsAction()
		{
			
		}
		public function playAction(playName:int,localX:Number,localY:Number):void{
			switch(playName){
				case 500: //掌声
					this.addChild(guzhang);
					guzhang.gotoAndPlay(1);
					guzhang.addEventListener("props_action_stop",actionStop,false,0,true);
					break;
				case 502: //红玫瑰
					this.addChild(hua);
					hua.gotoAndPlay(1);
					hua.addEventListener("props_action_stop",actionStop,false,0,true);
					break;
				case 508: //泼水
					this.addChild(poshui);
					poshui.gotoAndPlay(1);
					poshui.addEventListener("props_action_stop",actionStop,false,0,true);
					break;
				case 509: //砖头
					this.addChild(zhuan);
					zhuan.gotoAndPlay(1);
					zhuan.addEventListener("props_action_stop",actionStop,false,0,true);
					break;				
			}
		
		

			if(localX>=400){
				this.scaleX = -1;
				this.x = localX-50;
			}else{
				this.x = localX + 20;
			}
					
			this.y = localY;

		
		}
		private function actionStop(evt:Event):void{
			(evt.target as UIMovieClip).removeEventListener("props_action_stop",actionStop);			
			this.removeChild((evt.target) as UIMovieClip);
		}

	}
}