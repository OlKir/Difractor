package model {
	
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ImageLibrary extends EventDispatcher  {
		
		public static const LIBRARY_READY = "LIBRARY_READY";
		
		public var images:Vector.<ImageMedia>;
		
		
		const CACHE_FOLDER_NAME = "temp";
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
		
		public function thumbnailPath(image:ImageMedia):String
		{
			return this.cacheFolder.nativePath + File.separator + image.thumbnailName;
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
