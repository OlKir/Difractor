package controllers {
	import flash.display.Sprite;
	import views.ControlsView;
	import flash.events.Event;
	import flash.filesystem.File;
	import model.ImageLibrary;
	
	public class ControlsViewController {
		
		var controlsView:ControlsView;
		var imageLibrary:ImageLibrary;

		public function ControlsViewController(controlsView:Sprite, imageLibrary:ImageLibrary)
		{
			this.imageLibrary = imageLibrary;
			this.imageLibrary.addEventListener(ImageLibrary.LIBRARY_READY,updateLibraryGrid);
			
			
			this.controlsView = controlsView as ControlsView;
			this.controlsView.linkUIElements();
			this.controlsView.delegate = this;
		}
		
		public function updateDisplay()
		{
			this.controlsView.setDefaultParameters();
		}
		
		// ControlsView delegate methods
		
		public function browseButtonClicked():void
		{
			 var file = new File();
             file.addEventListener(Event.SELECT, folder_selected);
             file.browseForDirectory("Please select a folder...");
		}
		
		
		
		function folder_selected(e:Event):void
		{
			this.controlsView.libraryPath.text = File(e.currentTarget).nativePath;
			this.imageLibrary.reloadLibrary(File(e.currentTarget),this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight);
			
		}
		
		function updateLibraryGrid(e:Event):void
		{
			trace("Images loaded: ",this.imageLibrary.images.length);
			for each (var imageMedia in this.imageLibrary.images) {
				this.controlsView.libraryGrid.addItem({source:imageMedia.mediaPath});
			}
			this.controlsView.libraryGrid.addItem({source:"D://test/tripwolf_office_full.bmp"});
		}
		
	}
	
}
