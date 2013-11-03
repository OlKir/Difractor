package views {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.controls.RadioButton;
	import fl.controls.TextInput;
	import fl.controls.Button;
	import fl.controls.TileList;
	import controllers.ControlsViewController;

	public class ControlsView extends Sprite {
		
		public var delegate:ControlsViewController;
		
		// GUI elements
		var currentScaleRB:RadioButton;
		var realScaleRB:RadioButton;
		
		var horOffset:TextInput;
		var horWidth:TextInput;
		var horStep:TextInput;
		
		var browseBTN:Button;
		public var libraryPath:TextInput;
		public var libraryGrid:TileList;
		
		public function ControlsView() {
			
		}
		
		public function linkUIElements():void
		{
			this.currentScaleRB = this.getChildByName("current_scale_rb_") as RadioButton;
			this.realScaleRB = this.getChildByName("real_scale_rb_") as RadioButton;
			
			this.browseBTN = this.getChildByName("browse_btn_") as Button;
			this.browseBTN.addEventListener(MouseEvent.MOUSE_UP,browseButtonDidClicked);
			this.libraryPath = this.getChildByName("library_path_") as TextInput;
			
			this.libraryGrid = this.getChildByName("library_grid_") as TileList;

		}
		
		public function setDefaultParameters():void
		{
			this.currentScaleRB.label = "0%";
			this.currentScaleRB.enabled = false;
			
			this.realScaleRB.enabled = false;
		}
		
		function browseButtonDidClicked(e:MouseEvent):void
		{
			this.delegate.browseButtonClicked();
		}

	}
	
}
