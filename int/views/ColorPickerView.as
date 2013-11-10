package views {
	
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import controllers.ControlsViewController;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	public class ColorPickerView extends Sprite {
		
		public var delegate:ControlsViewController;
		
		var redInput:TextInput;
		var greenInput:TextInput;
		var blueInput:TextInput;
		
		var closeBTN:Button;
		
		var colorPalette:Sprite;
		
		var pickerCursor:PickerCursor;
		
		var _choosenColor:uint;
		
		public function ColorPickerView() {
			// constructor code
		}
		
		public function set choosenColor(targetColor:uint):void
		{
			this._choosenColor = targetColor;
			if (this.choosenColor == ControlsViewController.EMPTY_COLOR) {
				this.redInput.text = "";
				this.greenInput.text = "";
				this.blueInput.text = "";
				return;
			}
			this.redInput.text = (this.choosenColor  >> 16 & 0xff).toString();
			this.greenInput.text = (this.choosenColor >> 8 & 0xff).toString();
			this.blueInput.text = (this.choosenColor & 0xff).toString();
			
		}
		
		public function get choosenColor():uint
		{
			return this._choosenColor;
		}
		
		public function linkUIElements():void
		{
			this.redInput = this.getChildByName("red_input_") as TextInput;
			this.greenInput = this.getChildByName("green_input_") as TextInput;
			this.blueInput = this.getChildByName("blue_input_") as TextInput;
			
			this.closeBTN = this.getChildByName("close_btn_") as Button;
			this.closeBTN.addEventListener(MouseEvent.CLICK,closeButtonDidClicked);
			
			this.colorPalette = this.getChildByName("color_palette_") as Sprite;
			this.colorPalette.addEventListener(MouseEvent.MOUSE_OVER,showPickerCursor);
			this.colorPalette.addEventListener(MouseEvent.MOUSE_OUT,hidePickerCursor);
			this.colorPalette.addEventListener(MouseEvent.MOUSE_MOVE,movePickerCursor);
			this.colorPalette.addEventListener(MouseEvent.CLICK,pickColor);
		}
	
		function closeButtonDidClicked(e:MouseEvent):void
		{
			this.createOutputColor();
			this.delegate.pickerViewClosed();
		}
		
		function createOutputColor():void
		{
			if (this.redInput.text.length > 0 && this.greenInput.text.length > 0 && this.blueInput.text.length) {
				var red:uint = parseInt(this.redInput.text);
				var green:uint = parseInt(this.greenInput.text);
				var blue:uint = parseInt(this.blueInput.text);
				if (red > 255) red = 255;
				if (green > 255) green = 255;
				if (blue > 255) blue = 255;
				
				this._choosenColor = red << 16 | green << 8 | blue;
			}
		}
		
		function movePickerCursor(e:MouseEvent):void
		{
			if (this.pickerCursor == null) {
				return;
			}
			
			this.pickerCursor.x = e.localX + this.colorPalette.x;
			this.pickerCursor.y = e.localY + this.colorPalette.y;

		}
		
		function pickColor(e:MouseEvent):void
		{
			var paletteData:BitmapData = new BitmapData(this.colorPalette.width,this.colorPalette.height,true,0xffffffff);
			this.pickerCursor.visible = false;
			paletteData.draw(this.colorPalette);
			this.pickerCursor.visible = true;
			this.choosenColor = paletteData.getPixel32(e.localX,e.localY);
			
			this.createOutputColor();
			this.delegate.pickerViewUpdatedColor();
		}
		
		function showPickerCursor(e:MouseEvent):void
		{
			if (this.pickerCursor == null) {
				this.pickerCursor = new PickerCursor();
				this.pickerCursor.mouseEnabled = false;
				this.pickerCursor.blendMode = BlendMode.DIFFERENCE;
				this.pickerCursor.x = e.localX + this.colorPalette.x;
			    this.pickerCursor.y = e.localY + this.colorPalette.y;
				this.addChild(this.pickerCursor);

				Mouse.hide();
			} 
		}
		
		function hidePickerCursor(e:MouseEvent):void
		{
			if (this.pickerCursor != null) {
				this.removeChild(this.pickerCursor);
				this.pickerCursor = null;
				Mouse.show();
			}
		}

	}
	
}
