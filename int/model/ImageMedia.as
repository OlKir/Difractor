package model {

	
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.events.ProgressEvent;	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;



	public class ImageMedia extends EventDispatcher {
		
		public static const FULL_IMAGE_READY = "FULLIMAGE_READY";
	
		public var mediaThumbnail:BitmapData;
		public var mediaSource:BitmapData;
		public var mediaPath:String;
		
		public var objId:int;

		public var thumbnailLoaded:Boolean;
		public var thumbnailCached:Boolean;
		public var sourceLoaded:Boolean;
		public var thumbnailName:String;
		
		var mediaLoader:Loader = null;
		var fileLink:File;
		var thumbnailWidth:Number;
		var thumbnailHeight:Number;
		var sourceLoading:Boolean;
		var cacheLoading:Boolean;
		

		public function ImageMedia(sourceObjId:int,fileLink:File,thumbnailWidth:Number,thumbnailHeight:Number) {
			this.thumbnailName = fileLink.name.substr(0,fileLink.name.length - 4) + ".png";
			
			this.fileLink = fileLink;
			this.mediaPath = fileLink.nativePath;
			this.objId = sourceObjId;
			this.thumbnailWidth = thumbnailWidth;
			this.thumbnailHeight = thumbnailHeight;
			
			this.thumbnailLoaded = false;
			this.thumbnailCached = false;
			this.sourceLoaded = false;
		}
		
		public function cacheThumbnail(cacheFolder:File):void
		{
			var pngData = PNGEncoder.encode(this.mediaThumbnail);
			
			var resultFile:File = cacheFolder.resolvePath(this.thumbnailName);
			var fileStream:FileStream = new FileStream();
			fileStream.open(resultFile, FileMode.WRITE);
			fileStream.writeBytes(pngData);
			fileStream.close();
			
		}
		
		public function loadThumbnailFromCachedFile(cachedFile:File = null):void
		{
			this.sourceLoading = false;
			this.cacheLoading = true;
			
			if (cachedFile != null) {
				this.startMediaLoad(cachedFile.url);
				return;
			}
			
			this.cacheLoading = false;
			this.startMediaLoad(this.fileLink.url);
		}
		
		
		public function loadImageCompletely():void
		{
			this.sourceLoading = true;
			this.startMediaLoad(this.fileLink.url);
		}
		
		public function unloadSourceImage():void
		{
			this.mediaSource.dispose();
			this.mediaSource = null;
			this.mediaLoader.unloadAndStop();
			this.mediaLoader = null;
		}
		
		private function startMediaLoad(url:String):void
		{
			this.mediaLoader = new Loader();
			this.mediaLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, contentReady, false, 0, true);
			this.mediaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this.mediaLoader.addEventListener(Event.UNLOAD, unLoadHandler);
			
			try {
				var mediaUrlRequest:URLRequest  = new URLRequest(url);
				this.mediaLoader.load(mediaUrlRequest);
			} catch (e:Error) {
				trace("File could not be loaded!");
			}
		}
		
		private function contentReady(e:Event):void {
			var mediaContent:Bitmap = null;
			if (this.sourceLoading) {
				this.sourceLoading = false;
				mediaContent = Bitmap(mediaLoader.content);
				this.mediaSource = mediaContent.bitmapData;
				dispatchEvent(new Event(FULL_IMAGE_READY));
				return;
			}
			
			mediaContent = Bitmap(mediaLoader.content);
			mediaContent.smoothing = true;
			if (this.cacheLoading) {
				this.mediaThumbnail = mediaContent.bitmapData.clone();
			} else {
				var thumbnailFromBitmapData : Bitmap = BitmapResampler.getResampledBitmap(mediaContent,this.thumbnailWidth,this.thumbnailHeight);
				this.mediaThumbnail = thumbnailFromBitmapData.bitmapData;
			}
						
			this.mediaLoader.unloadAndStop();
			this.mediaLoader = null;
			this.thumbnailLoaded = true;		
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
			dispatchEvent(new Event("IMG_RELOAD"));
        }

		private function unLoadHandler(event:Event):void {
            trace("unLoadHandler: " + event);
        }

		
//		public function resample():void {
//			var tarY:Number = Math.round(mediaContent.height*320/mediaContent.width);
//			var bmpFromBitmapData : Bitmap = BitmapResampler.getResampledBitmap(mediaContent,320,tarY);
//			var jpgEncoder:JPGEncoder = new JPGEncoder(95);
//			jpgData = jpgEncoder.encode(bmpFromBitmapData.bitmapData);
//			dispatchEvent(new Event("IMG_ENCODED"));
//			
//		}


	}
}