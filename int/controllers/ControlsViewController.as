package controllers {
	import flash.display.Sprite;
	import views.ControlsView;
	import flash.events.Event;
	import flash.filesystem.File;
	import model.ImageLibrary;
	import model.UserSettings;
	import views.ColorPickerView;
	
	public class ControlsViewController {
		
		const CONTROL_PANEL_WIDTH:Number = 342;
		const CONTROL_PANEL_PADDING:Number = 10;
		
		var controlsView:ControlsView;
		var imageLibrary:ImageLibrary;
		
		var fader:Sprite;
		var colorPicker:ColorPickerView;

		public function ControlsViewController(controlsView:Sprite, imageLibrary:ImageLibrary)
		{
			this.imageLibrary = imageLibrary;
			this.imageLibrary.addEventListener(ImageLibrary.LIBRARY_READY,updateLibraryGrid);
			
			
			this.controlsView = controlsView as ControlsView;
			this.controlsView.linkUIElements();
			this.controlsView.delegate = this;
			this.controlsView.enableImageControls(false);
			
			this.fader = this.controlsView.getChildByName("controls_fader_") as Sprite;
			this.fader.visible = false;
			
			this.colorPicker = this.controlsView.getChildByName("color_picker_") as ColorPickerView;
			this.colorPicker.linkUIElements();
			this.colorPicker.visible = false;
			this.colorPicker.delegate = this;
			
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
		
		public function selectColorButtonClicked():void
		{
			this.fader.visible = true;
			this.fader.x = 0;
			
			this.colorPicker.visible = true;
			this.colorPicker.x = -CONTROL_PANEL_WIDTH/2;
		}
		
		// ColorPickerView delegate methods
		
		public function pickerViewClosed():void
		{
			this.fader.visible = false;			
			this.colorPicker.visible = false;
		}
		
	}
	
}
