package controllers {
	import flash.display.Sprite;
	import views.ControlsView;
	import flash.events.Event;
	import flash.filesystem.File;
	import model.ImageLibrary;
	
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
		}
		
		public function updateDisplay()
		{
			this.controlsView.setDefaultParameters();
		}
		

		
		
		
		function folder_selected(e:Event):void
		{
			this.controlsView.libraryPath.text = File(e.currentTarget).nativePath;
			this.imageLibrary.reloadLibrary(File(e.currentTarget),this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight);
			
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
			this.controlsView.libraryGrid.removeAll();
			this.imageLibrary.reloadLibrary(null,this.controlsView.libraryGrid.columnWidth,this.controlsView.libraryGrid.rowHeight,true);
		}
		
	}
	
}
