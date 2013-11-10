package model {
	
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.BitmapData;
	
	public class ImageLibrary extends EventDispatcher  {
		
		public static const LIBRARY_READY = "LIBRARY_READY";
		public static const FULL_IMAGE_LOADED = "FULL_IMAGE_LOADED";

		public var images:Vector.<ImageMedia>;
		
		
		const CACHE_FOLDER_NAME = "temp";
		const OUTPUT_FOLDER_NAME = "output";
		
		var loadingCheckTimer:Timer;
		var updateCache:Boolean;
		var libraryFolder:File;
		var cacheFolder:File;


		public function ImageLibrary() {
			this.loadingCheckTimer = new Timer(1000,0);
			this.loadingCheckTimer.addEventListener(TimerEvent.TIMER,checkLoading);
		}
		
		public function reloadLibrary(libraryFolder:File,thumbnailWidth:Number,thumbnailHeight:Number,updateCache:Boolean = false):Boolean
		{
			this.images = new Vector.<ImageMedia>();
			
			if (libraryFolder == null && this.libraryFolder == null) {
				return false;
			}
			
			if (libraryFolder != null) {
				this.libraryFolder = libraryFolder;
			}
			
			if (! this.libraryFolder.isDirectory) {
				return false;
			}
			
			this.updateCache = updateCache;
			this.cacheFolder = this.libraryFolder.resolvePath(CACHE_FOLDER_NAME);
			
			var imageMedia:ImageMedia;
			var files:Array = this.libraryFolder.getDirectoryListing();
			var i:int = 0;
			for each (var file:File in files) {
				if (file.isDirectory) {
					continue;
				}
				
				var fileExtension:String = file.extension.toLocaleLowerCase();
				if (fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg") {
					imageMedia = new ImageMedia(i,file,thumbnailWidth,thumbnailHeight);
					if (this.isThumbnailExists(imageMedia) && (! this.updateCache)) {
						imageMedia.loadThumbnailFromCachedFile(this.cacheFolder.resolvePath(imageMedia.thumbnailName));
					} else {
						imageMedia.loadThumbnailFromCachedFile(null);
					}
					
					this.images.push(imageMedia);
					i++;
				}
			}
			
			this.loadingCheckTimer.start();
			
			return true;
		}
		
		public function saveImageWithName(imageName:String,fileData:BitmapData):void
		{
			var fileName:String = imageName.toLocaleLowerCase();
			if (imageName.substr(-4,4) != ".png") {
				fileName += ".png";
			}
			var outputFile:File = this.libraryFolder.resolvePath(OUTPUT_FOLDER_NAME);
			outputFile = outputFile.resolvePath(fileName);
			ImageMedia.saveDataToPNG(fileData,outputFile);
		}
		
		public function newMediaName(objectId:int):String
		{
			var mediaName:String = "untitled.png";
			for each (var image:ImageMedia in this.images) {
				if (image.objId == objectId) {
					mediaName = image.fileLink.name;
					var mediaExtension:String = image.fileLink.extension;
					mediaName = mediaName.substr(0,mediaName.length - mediaExtension.length - 1) + "_.png";
				}
			}
			return mediaName;
		}
		
		public function thumbnailPath(image:ImageMedia):String
		{
			return this.cacheFolder.nativePath + File.separator + image.thumbnailName;
		}
		
		public function getThumbnailById(objectId:int):BitmapData
		{
			for each (var image:ImageMedia in this.images) {
				if (image.objId == objectId) {
					return image.mediaThumbnail;
				}
			}
			return null;
		}
		
		// loadFullImageById should preload image first
		public function getFullImageById(objectId:int):BitmapData
		{
			for each (var image:ImageMedia in this.images) {
				if (image.objId == objectId) {
					if (image.mediaSource == null) {
						trace("ERROR: You should load full image first with loadFullImageById!!!");
					}
					return image.mediaSource;
				}
			}
			return null;
		}
		
		// oldObjectId can be CanvasViewController.NO_IMAGE
		public function loadFullImageById(objectId:int,oldObjectId:int):void
		{
			for each (var image:ImageMedia in this.images) {

				if (image.objId == objectId) {
					image.loadImageCompletely();
					image.addEventListener(ImageMedia.FULL_IMAGE_READY,returnFullImage);
				}
				
				if (image.objId == oldObjectId) {
					image.unloadSourceImage();
				}
			}
		}
		

		
		function returnFullImage(e:Event):void
		{
			dispatchEvent(new Event(ImageLibrary.FULL_IMAGE_LOADED));
		}
		
		function checkLoading(e:TimerEvent):void
		{
			var allLoadComplite:Boolean = true;
			for each (var image:ImageMedia in this.images) {
				if (! image.thumbnailLoaded) {
					allLoadComplite = false;
					break;
				} else {
					this.checkThumbnailCache(image);
				}
			}
			if (allLoadComplite) {
				this.loadingCheckTimer.reset();
				dispatchEvent(new Event(LIBRARY_READY));
			}
		}
		
		function checkThumbnailCache(image:ImageMedia):void
		{
		  
		  if (image.thumbnailCached) {
			  return;
		  }
		  
		  if (this.updateCache) {
			  image.cacheThumbnail(this.cacheFolder);
			  return;
		  }
		  
		  if (! this.isThumbnailExists(image)) {
			  image.cacheThumbnail(this.cacheFolder);
		  }
		  
		}
		
		function isThumbnailExists(image:ImageMedia):Boolean
		{
		  var thumbnailFile:File = this.cacheFolder.resolvePath(image.thumbnailName);
		  if (thumbnailFile.exists) {
			 return true;
		  }
		  return false;
		}

	}
	
}
