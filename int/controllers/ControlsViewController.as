package controllers {
	import flash.display.Sprite;
	import views.ControlsView;
	import flash.events.Event;
	import flash.filesystem.File;
	import model.ImageLibrary;
	import model.UserSettings;
	import views.ColorPickerView;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	public class ControlsViewController {
		
		public static const EMPTY_COLOR:uint = 0xff000000;
		
		public var delegate:CanvasViewController;
		
		const CONTROL_PANEL_WIDTH:Number = 342;
		const CONTROL_PANEL_PADDING:Number = 10;
		
		var controlsView:ControlsView;
		var imageLibrary:ImageLibrary;
		
		var fader:Sprite;
		var colorPicker:ColorPickerView;
		
		var selectedPhoto:Bitmap;
		var selectedPhotoId:int;
		var selectedPhotoCursor:Sprite;

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
		
		public function unlockImageControls():void
		{
			this.controlsView.enableImageControls(true);
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
		
		function dropPhoto(e:MouseEvent):void
		{
			this.selectedPhotoCursor.stopDrag();
			this.controlsView.removeChild(this.selectedPhotoCursor);
			var targetPoint:Point = new Point(this.selectedPhotoCursor.x,this.selectedPhotoCursor.y);
			if (this.controlsView.pointInForegroundControl(targetPoint)) {
				this.controlsView.setForegroundImage(this.selectedPhoto.bitmapData);
				this.setArtworkNameFor(this.selectedPhotoId);
				this.delegate.setForegroundImage(this.selectedPhotoId);
			}
			if (this.controlsView.pointInBackgroundControl(targetPoint)) {
				this.controlsView.setBackgroundImage(this.selectedPhoto.bitmapData);
				this.delegate.setBackgroundImage(this.selectedPhotoId);
			}
			this.selectedPhoto = null;
			this.selectedPhotoCursor = null;
		}
		
		function setArtworkNameFor(objectId:int):void
		{
			var fileName:String = this.imageLibrary.newMediaName(objectId);
			this.controlsView.fileName.text = fileName;
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
			this.colorPicker.choosenColor = EMPTY_COLOR;
		}
		
		public function photoPicked(objectId:int):void
		{
			this.selectedPhoto = new Bitmap(this.imageLibrary.getThumbnailById(objectId));
			if (this.selectedPhoto == null) {
				return;
			}
			this.selectedPhotoCursor = new Sprite();
			this.selectedPhotoId = objectId;

			this.selectedPhotoCursor.addChild(selectedPhoto);
			this.selectedPhoto.x = - this.selectedPhotoCursor.width/2;
			this.selectedPhoto.y = - this.selectedPhotoCursor.height/2;
			
			this.selectedPhotoCursor.x = this.controlsView.mouseX;
			this.selectedPhotoCursor.y = this.controlsView.mouseY;
			this.selectedPhotoCursor.addEventListener(MouseEvent.MOUSE_UP,dropPhoto);
			this.controlsView.addChild(this.selectedPhotoCursor);
			this.selectedPhotoCursor.startDrag();
		}
		
		public function setRelativeScale(relative:Boolean):void
		{
			if (this.delegate == null) {
				return;
			}
			this.delegate.setRelativeScale(relative);
		}
		
		public function applyHorisontalSlices(sliceOffsetString:String,sliceWidthString:String,sliceStepString:String):void
		{
			var sliceOffset:int = int(sliceOffsetString);
			var sliceWidth:int = int(sliceWidthString);
			var sliceStep:int = int(sliceStepString);
			if (sliceWidth == 0 || sliceStep == 0) {
				sliceWidth = CanvasViewController.NOT_DEFINED;
			}
			this.delegate.applyHorisontalSlicing(sliceOffset,sliceWidth,sliceStep);
		}
		
		public function saveImage(imageName:String):void
		{
			this.delegate.saveCurrentImageWithName(imageName);
		}
		
		public function changeAlterationTo(alteration:Boolean):void
		{
			this.delegate.applyAlteration(alteration);
		}
		
		// ColorPickerView delegate methods
		
		public function pickerViewClosed():void
		{
			this.fader.visible = false;			
			this.colorPicker.visible = false;
			this.pickerViewUpdatedColor();
		}
		
		public function pickerViewUpdatedColor():void
		{
			if (this.colorPicker.choosenColor != EMPTY_COLOR) {
				this.controlsView.updateBackgroundColor(this.colorPicker.choosenColor);
				this.delegate.setBackgroundColor(this.colorPicker.choosenColor);
			}
		}
		
	}
	
}
