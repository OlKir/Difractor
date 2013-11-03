package model {
	
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ImageLibrary extends EventDispatcher  {
		
		public static const LIBRARY_READY = "LIBRARY_READY";
		
		public var images:Vector.<ImageMedia>;
				
		var loadingCheckTimer:Timer;


		public function ImageLibrary() {
			this.loadingCheckTimer = new Timer(1000,0);
			this.loadingCheckTimer.addEventListener(TimerEvent.TIMER,checkLoading);
		}
		
		public function reloadLibrary(libraryFolder:File,thumbnailWidth:Number,thumbnailHeight:Number):Boolean
		{
			this.images = new Vector.<ImageMedia>();
			
			var loadError:Boolean = false;
			if (! libraryFolder.isDirectory) {
				return false;
			}
			
			var imageMedia:ImageMedia;
			var files:Array = libraryFolder.getDirectoryListing();
			var i:int = 0;
			for each (var file:File in files) {
				var fileExtension:String = file.extension.toLocaleLowerCase();
				if (fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg") {
					imageMedia = new ImageMedia(i,file.name,file,thumbnailWidth,thumbnailHeight);
					this.images.push(imageMedia);
					i++;
				}
			}
			
			this.loadingCheckTimer.start();
			
			return loadError;
		}
		
		private function checkLoading(e:TimerEvent):void
		{
			var allLoadComplite:Boolean = true;
			for each (var image:ImageMedia in this.images) {
				if (! image.thumbnailLoaded) {
					allLoadComplite = false;
					break;
				}
			}
			if (allLoadComplite) {
				this.loadingCheckTimer.reset();
				dispatchEvent(new Event(LIBRARY_READY));
			}
		}

	}
	
}
