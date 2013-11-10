package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import controllers.ControlsViewController;
	import controllers.CanvasViewController;
	import model.ImageLibrary;
	import flash.events.Event;
	
	public class Base extends MovieClip {
		
		var controlsViewController:ControlsViewController;
		var imageLibrary:ImageLibrary;
		var canvasViewController:CanvasViewController;
		
		var firstPhotoSelected:Boolean;
		
		public function Base() {
			this.imageLibrary = new ImageLibrary();
			
			this.canvasViewController = new CanvasViewController(this.getChildByName("canvas_") as Sprite,this.getChildByName("canvas_mask_") as Sprite,this.imageLibrary);
			this.canvasViewController.addEventListener(CanvasViewController.FULL_IMAGE_ACCEPTED,unlockControls);
			
			this.controlsViewController = new ControlsViewController(this.getChildByName("control_panel_") as Sprite,this.imageLibrary);
			this.controlsViewController.delegate = this.canvasViewController;
			this.controlsViewController.updateDisplay();
		}
		
		function unlockControls(e:Event):void
		{
			if (this.firstPhotoSelected) {
				return;
			}
			this.firstPhotoSelected = true;
			this.controlsViewController.unlockImageControls();
		}
	}
	
}
