package {
	import flash.system.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class MemoryLeakController extends MovieClip {
		var indicator:TextField = new TextField();
		var timer:Timer=new Timer(500);

		public function MemoryLeakController() {
			indicator.x=100;
			indicator.y=50;
			indicator.text="universal  memory leak controller";
			indicator.scaleX=2;
			indicator.scaleY=2;
			indicator.textColor=0x000000;
			indicator.width=300;
		
			var format:TextFormat = new TextFormat();
			format.font="Helvetica";
			format.color=0x777777;
			format.size=10;

			indicator.defaultTextFormat=format;
			this.addChild(indicator);
			trace("created");
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}

		private function onTimer(e:TimerEvent) {
			indicator.text = "Used: " + (System.totalMemory/1024).toString() + " Kb";
		}

	}

}