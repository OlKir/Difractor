package views {
	
	import flash.display.Sprite;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import controllers.ControlsViewController;
	import flash.events.MouseEvent;
	import flash.events.Event;

	
	public class ColorPickerView extends Sprite {
		
		public var delegate:ControlsViewController;
		
		var redInput:TextInput;
		var greenInput:TextInput;
		var blueInput:TextInput;
		
		var closeBTN:Button;

		public function ColorPickerView() {
			// constructor code
		}
		
		public function linkUIElements():void
		{
			this.redInput = this.getChildByName("red_input_") as TextInput;
			this.redInput = this.getChildByName("green_input_") as TextInput;
			this.redInput = this.getChildByName("blue_input_") as TextInput;
			
			this.closeBTN = this.getChildByName("close_btn_") as Button;
			this.closeBTN.addEventListener(MouseEvent.CLICK,closeButtonDidClicked);
		}
		
		function closeButtonDidClicked(e:MouseEvent):void
		{
			this.delegate.pickerViewClosed();
		}

	}
	
}
