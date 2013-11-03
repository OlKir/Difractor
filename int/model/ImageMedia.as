package model {

	
	import flash.filesystem.File;
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



	public class ImageMedia extends EventDispatcher {
	
		public var mediaThumbnail:BitmapData;
		public var mediaSource:BitmapData;
		public var mediaPath:String;
		
		public var objId:int;

		public var thumbnailLoaded:Boolean;
		public var sourceLoaded:Boolean;
		
		var mediaLoader:Loader = null;
		var fileName:String;
		var fileLink:File;
		var thumbnailWidth:Number;
		var thumbnailHeight:Number;
		var sourceLoading:Boolean;
		

		public function ImageMedia(sourceObjId:int,fileName:String,fileLink:File,thumbnailWidth:Number,thumbnailHeight:Number) {
			this.fileName = fileName;
			this.fileLink = fileLink;
			this.mediaPath = fileLink.nativePath;
			this.objId = sourceObjId;
			this.thumbnailWidth = thumbnailWidth;
			this.thumbnailHeight = thumbnailHeight;
			
			this.thumbnailLoaded = true;
			this.sourceLoaded = false;
			
			//this.sourceLoading = false;
			//this.startMediaLoad();

		}
		
		public function loadImageCompletely():void
		{
			this.sourceLoading = true;
			this.startMediaLoad();
		}
		
		public function unloadSourceImage():void
		{
			this.mediaSource = null;
			this.mediaLoader.unloadAndStop();
			this.mediaLoader = null;
		}
		
		private function startMediaLoad():void
		{
			this.mediaLoader = new Loader();
			this.mediaLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, contentReady, false, 0, true);
			this.mediaLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this.mediaLoader.addEventListener(Event.UNLOAD, unLoadHandler);
			
			try {
				var mediaUrlRequest:URLRequest  = new URLRequest(this.fileLink.url);
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
				this.sourceLoaded = true;
				return;
			}
			
			mediaContent = Bitmap(mediaLoader.content);
			mediaContent.smoothing = true;
			var thumbnailFromBitmapData : Bitmap = BitmapResampler.getResampledBitmap(mediaContent,this.thumbnailWidth,this.thumbnailHeight);
			this.mediaThumbnail = thumbnailFromBitmapData.bitmapData;
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