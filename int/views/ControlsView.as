package views {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.controls.RadioButton;
	import fl.controls.TextInput;
	import fl.controls.Button;
	import fl.controls.TileList;
	import controllers.ControlsViewController;
	import fl.core.UIComponent;
	import flash.display.Shape;
	import fl.events.ListEvent;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;

	public class ControlsView extends Sprite {
		
		public var delegate:ControlsViewController;
		public var libraryPath:TextInput;
		public var libraryGrid:TileList;
		public var enabled:Boolean;
		public var fileName:TextInput;
		
		var preselectedPhotoIndex:int;
		
		// GUI elements
		var currentScaleRB:RadioButton;
		var realScaleRB:RadioButton;
		
		var horOffset:TextInput;
		var horWidth:TextInput;
		var horStep:TextInput;
		var applyHorisontalBTN:Button;
		
		var applyVerticalBTN:Button;
		
		
		var saveImageBTN:Button;
		
		var browseBTN:Button;
		var updateBTN:Button;
		
		var selectColorBTN:Sprite;
		var selectedForeground:Sprite;
		var selectedForegroundImage:Bitmap;
		var selectedBackground:Sprite;
		var selectedBackgroundColorExample:Shape;
		
 
		
		var imageControls:Vector.<UIComponent>;
	
		public function ControlsView() {
			this.enabled = false;
		}
		
		public function linkUIElements():void
		{
			this.currentScaleRB = this.getChildByName("current_scale_rb_") as RadioButton;
			this.currentScaleRB.addEventListener(Event.CHANGE,scaleDidChanged);
			this.realScaleRB = this.getChildByName("real_scale_rb_") as RadioButton;
			this.realScaleRB.addEventListener(Event.CHANGE,scaleDidChanged);
			
			this.horOffset =  this.getChildByName("hor_offset_") as TextInput;
			this.horStep =  this.getChildByName("hor_step_") as TextInput;
			this.horWidth =  this.getChildByName("hor_width_") as TextInput;
			
			this.applyHorisontalBTN = this.getChildByName("apply_horisontal_btn_") as Button;
			this.applyVerticalBTN = this.getChildByName("apply_vertical_btn_") as Button;

			this.selectColorBTN = this.getChildByName("select_color_btn_") as Sprite;
			this.selectColorBTN.addEventListener(MouseEvent.CLICK,selectColorButtonDidClicked);
			this.selectedForeground = this.getChildByName("selected_foreground_") as Sprite;
			this.selectedBackground = this.getChildByName("selected_background_") as Sprite;
			this.selectedBackgroundColorExample = new Shape();
			this.selectedBackground.addChild(this.selectedBackgroundColorExample);
			
			this.fileName = this.getChildByName("file_name_") as TextInput;
			this.saveImageBTN = this.getChildByName("save_image_btn_") as Button;
			
			this.browseBTN = this.getChildByName("browse_btn_") as Button;
			this.browseBTN.addEventListener(MouseEvent.MOUSE_UP,browseButtonDidClicked);
			this.libraryPath = this.getChildByName("library_path_") as TextInput;
			this.updateBTN = this.getChildByName("update_btn_") as Button;
			this.updateBTN.addEventListener(MouseEvent.MOUSE_UP,updateButtonDidClicked);
			
			this.libraryGrid = this.getChildByName("library_grid_") as TileList;
			this.libraryGrid.addEventListener(ListEvent.ITEM_ROLL_OVER,preselectPhoto);
			this.libraryGrid.addEventListener(MouseEvent.MOUSE_DOWN,selectPhoto);
			
			this.imageControls = new <UIComponent>[this.currentScaleRB,this.realScaleRB,this.applyHorisontalBTN,this.saveImageBTN];
			
			this.enabled = true;
		}
		
		public function setDefaultParameters():void
		{
			this.horOffset.text = "";
			this.horStep.text = "";
			this.horWidth.text = "";
			
		}
		
		public function enableImageControls(switchState:Boolean):void
		{
			for each (var control:UIComponent in this.imageControls) {
				control.enabled = switchState;
			}
			this.realScaleRB.selected = true;
		}
		
		public function updateBackgroundColor(color:uint):void
		{
			this.selectedBackgroundColorExample.graphics.beginFill(color,1.0);
			this.selectedBackgroundColorExample.graphics.drawRect(0,0,this.selectedBackground.width,this.selectedBackground.height);
			this.selectedBackgroundColorExample.graphics.endFill();
		}
		
		public function pointInForegroundControl(targetPoint:Point):Boolean
		{
			if (this.selectedForeground.getBounds(this).containsPoint(targetPoint)) {
				return true;
			}
			return false;
		}
		
		public function setForegroundImage(imageBitmap:BitmapData):void
		{
			if (this.selectedForegroundImage != null) {
				this.selectedForeground.removeChild(this.selectedForegroundImage);
				this.selectedForegroundImage = null;
			}
			this.selectedForegroundImage = new Bitmap(imageBitmap);
			this.selectedForeground.addChild(this.selectedForegroundImage);
		}
		
		function browseButtonDidClicked(e:MouseEvent):void
		{
			if (! this.enabled) {
				return;
			}
			this.delegate.browseButtonClicked();
		}
		
		function updateButtonDidClicked(e:MouseEvent):void
		{
			if (! this.enabled) {
				return;
			}
			this.delegate.updateButtonClicked();
		}
		
		function selectColorButtonDidClicked(e:MouseEvent):void
		{
			if (! this.enabled) {
				return;
			}
			this.delegate.selectColorButtonClicked();
		}
		
		function preselectPhoto(e:ListEvent):void
		{
			this.preselectedPhotoIndex = e.index;
		}
		
		function selectPhoto(e:MouseEvent):void
		{
			this.delegate.photoPicked(this.libraryGrid.getItemAt(this.preselectedPhotoIndex).objectId);
		}
		
		function scaleDidChanged(e:Event):void
		{
			if (e.target == this.currentScaleRB && this.currentScaleRB.selected) {
				this.delegate.setRelativeScale(true);
				return;
			}
			this.delegate.setRelativeScale(false);
		}

	}
	
}
