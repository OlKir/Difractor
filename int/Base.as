package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import controllers.ControlsViewController;
	import model.ImageLibrary;
	
	public class Base extends MovieClip {
		
		var controlsViewController:ControlsViewController;
		var imageLibrary:ImageLibrary;
		
		public function Base() {
			this.imageLibrary = new ImageLibrary();
			
			this.controlsViewController = new ControlsViewController(this.getChildByName("control_panel_") as Sprite,this.imageLibrary);
			this.controlsViewController.updateDisplay();
			
			
		}
	}
	
}
