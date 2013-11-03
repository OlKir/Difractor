package views {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.controls.RadioButton;
	import fl.controls.TextInput;
	import fl.controls.Button;
	import fl.controls.TileList;
	import controllers.ControlsViewController;
	import fl.core.UIComponent;

	public class ControlsView extends Sprite {
		
		public var delegate:ControlsViewController;
		public var libraryPath:TextInput;
		public var libraryGrid:TileList;
		public var enabled:Boolean;
		
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
		
		var imageControls:Vector.<UIComponent>;
	
		public function ControlsView() {
			this.enabled = false;
		}
		
		public function linkUIElements():void
		{
			this.currentScaleRB = this.getChildByName("current_scale_rb_") as RadioButton;
			this.realScaleRB = this.getChildByName("real_scale_rb_") as RadioButton;
			
			this.horOffset =  this.getChildByName("hor_offset_") as TextInput;
			this.horStep =  this.getChildByName("hor_step_") as TextInput;
			this.horWidth =  this.getChildByName("hor_width_") as TextInput;
			
			this.applyHorisontalBTN = this.getChildByName("apply_horisontal_btn_") as Button;
			this.applyVerticalBTN = this.getChildByName("apply_vertical_btn_") as Button;

			this.selectColorBTN = this.getChildByName("select_color_btn_") as Sprite;
			this.selectColorBTN.addEventListener(MouseEvent.CLICK,selectColorButtonDidClicked);
			
			this.saveImageBTN = this.getChildByName("save_image_btn_") as Button;
			
			this.browseBTN = this.getChildByName("browse_btn_") as Button;
			this.browseBTN.addEventListener(MouseEvent.MOUSE_UP,browseButtonDidClicked);
			this.libraryPath = this.getChildByName("library_path_") as TextInput;
			this.updateBTN = this.getChildByName("update_btn_") as Button;
			this.updateBTN.addEventListener(MouseEvent.MOUSE_UP,updateButtonDidClicked);
			
			this.libraryGrid = this.getChildByName("library_grid_") as TileList;
			
			this.imageControls = new <UIComponent>[this.currentScaleRB,this.realScaleRB,this.applyHorisontalBTN,this.saveImageBTN];
			
			this.enabled = true;
		}
		
		public function setDefaultParameters():void
		{
			this.currentScaleRB.label = "0%";
			this.horOffset.text = "";
			this.horStep.text = "";
			this.horWidth.text = "";
			
		}
		
		public function enableImageControls(switchState:Boolean):void
		{
			for each (var control:UIComponent in this.imageControls) {
				control.enabled = switchState;
			}
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

	}
	
}
