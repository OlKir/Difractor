package controllers {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.Shape;
	import model.ImageLibrary;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class CanvasViewController extends EventDispatcher {
		
		public static const NO_IMAGE:int = -1;
		public static const FULL_IMAGE_ACCEPTED = "FULL_IMAGE_ACCEPTED";
		
		var canvasView:Sprite;
		var maskView:Sprite;
		
		var backgroundView:Sprite;
		var backgroundViewColor:Shape;
		var imageLibrary:ImageLibrary;
		
		var foregroundView:Sprite;
		var foregroundImage:Bitmap;
		var foregroundImageId:int;

		public function CanvasViewController(canvasView:Sprite,maskView:Sprite,imageLibrary:ImageLibrary) {
			this.canvasView = canvasView;
			this.maskView = maskView;
			this.canvasView.mask = this.maskView;
			
			this.imageLibrary = imageLibrary;
			this.imageLibrary.addEventListener(ImageLibrary.FULL_IMAGE_LOADED,placeFullImage);
			
			this.backgroundView = new Sprite();
			this.canvasView.addChild(this.backgroundView);
			this.backgroundViewColor = new Shape();
			this.backgroundView.addChild(this.backgroundViewColor);
			
			this.foregroundView = new Sprite();
			this.foregroundImageId = CanvasViewController.NO_IMAGE;
			this.canvasView.addChild(this.foregroundView);
		}
		
		public function setCanvasMask(maskRectangle:Rectangle):void
		{
			this.maskView.width = maskRectangle.width;
			this.maskView.height = maskRectangle.height;
		}
		
		function placeFullImage(e:Event):void
		{
			var foregroundImageBitmap:BitmapData = this.imageLibrary.getFullImageById(this.foregroundImageId);
			if (foregroundImageBitmap == null) {
				return;
			}
			this.foregroundImage = new Bitmap(foregroundImageBitmap);
			this.foregroundView.addChild(this.foregroundImage);
			dispatchEvent(new Event(CanvasViewController.FULL_IMAGE_ACCEPTED));
		}
		
		
		// ControlsViewController delegate
		
		public function setBackgroundColor(color:uint):void
		{
			var backgroundRect:Rectangle = new Rectangle(0,0,this.foregroundView.width,this.foregroundView.height);
			if (this.foregroundView.width == 0 || this.foregroundView.height == 0) {
				backgroundRect = new Rectangle(0,0,this.maskView.width,this.maskView.height);
			}
			this.backgroundViewColor.graphics.beginFill(color,1.0);
			this.backgroundViewColor.graphics.drawRect(0,0,backgroundRect.width,backgroundRect.height);
			this.backgroundViewColor.graphics.endFill();
		}
		
		public function setForegroundImage(objectId:int):void
		{
			if (this.foregroundImage != null) {
				this.foregroundView.removeChild(this.foregroundImage);
				this.foregroundImage = null;
			}
			
			var oldId:int = CanvasViewController.NO_IMAGE;
			if (this.foregroundImageId != CanvasViewController.NO_IMAGE) {
				oldId = this.foregroundImageId;
			}
			this.foregroundImageId = objectId;
			this.imageLibrary.loadFullImageById(this.foregroundImageId,oldId);
		}
		
		public function setRelativeScale(relative:Boolean):void
		{
			if (! relative) {
				this.foregroundImage.scaleX = 1.0;
				this.foregroundImage.scaleY = 1.0;
				return;
			}
			var oldWidth:Number = this.foregroundImage.width;
			var oldHeight:Number = this.foregroundImage.height;
			this.foregroundImage.width = this.maskView.width;
			this.foregroundImage.height = oldHeight * this.foregroundImage.width / oldWidth;
			
		}
		


	}
	
}
