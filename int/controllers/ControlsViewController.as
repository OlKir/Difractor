package controllers {
	import flash.display.Sprite;
	import views.ControlsView;
	import flash.events.Event;
	import flash.filesystem.File;
	import model.ImageLibrary;
	import model.UserSettings;
	
	public class ControlsViewController {
		
		const MAX_IMAGES_WITHOUT_SCROLLING:int = 15;
		
		var controlsView:ControlsView;
		var imageLibrary:ImageLibrary;

		public function ControlsViewController(controlsView:Sprite, imageLibrary:ImageLibrary)
		{
			this.imageLibrary = imageLibrary;
			this.imageLibrary.addEventListener(ImageLibrary.LIBRARY_READY,updateLibraryGrid);
			
			
			this.controlsView = controlsView as ControlsView;
			this.controlsView.linkUIElements();
			this.controlsView.delegate = this;
			this.controlsView.enableImageControls(false);
			
			var imageLibraryPath:String = UserSettings.loadWorkingPath();
			if (imageLibraryPath != null) {
				this.controlsView.enabled = false;
				this.controlsView.libraryPath.text = imageLibraryPath;
				var imageLibraryFolder:File = new File(imageLibraryPath);
				this.imageLibrary.reloadLibrary(imageLibraryFolder,this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight);
			}
		}
		
		public function updateDisplay()
		{
			this.controlsView.setDefaultParameters();
		}
		
		function folder_selected(e:Event):void
		{
			this.controlsView.enabled = false;
			this.controlsView.libraryPath.text = File(e.currentTarget).nativePath;
			if (this.imageLibrary.reloadLibrary(File(e.currentTarget),this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight)) {
				UserSettings.saveWorkingPath(File(e.currentTarget).nativePath);
			}
			
		}
		
		function updateLibraryGrid(e:Event):void
		{
			trace("Images loaded: ",this.imageLibrary.images.length);
			
			this.controlsView.libraryGrid.removeAll();

			for each (var imageMedia in this.imageLibrary.images) {
				this.controlsView.libraryGrid.addItem({objectId:imageMedia.objId,source:this.imageLibrary.thumbnailPath(imageMedia)});
			}
			if (this.imageLibrary.images.length > MAX_IMAGES_WITHOUT_SCROLLING) {
				this.controlsView.libraryGrid.width = 322;
			}
			this.controlsView.enabled = true;
		}
		
		// ControlsView delegate methods
		
		public function browseButtonClicked():void
		{
			 var file = new File();
             file.addEventListener(Event.SELECT, folder_selected);
             file.browseForDirectory("Please select a folder...");
		}
		
		public function updateButtonClicked():void
		{
			this.controlsView.enabled = false;
			this.controlsView.libraryGrid.removeAll();
			this.imageLibrary.reloadLibrary(null,this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight,true);
		}
		
	}
	
}
