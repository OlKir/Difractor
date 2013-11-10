package controllers {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.Shape;
	import model.ImageLibrary;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class CanvasViewController extends EventDispatcher {
		
		public static const NOT_DEFINED:int = -1;
		public static const FULL_IMAGE_ACCEPTED = "FULL_IMAGE_ACCEPTED";
		
		var canvasView:Sprite;
		var maskView:Sprite;
		
		var backgroundView:Sprite;
		var backgroundViewColor:Shape;
		var imageLibrary:ImageLibrary;
		
		var foregroundView:Sprite;
		var foregroundImage:Bitmap;
		var foregroundImageId:int;
		
		var foregroundImageSourceBitmap:BitmapData;
		
		var scaleRelative:Boolean;
		
		var horisontalOffset:int;
		var horisontalWidth:int;
		var horisontalStep:int;
		
		var backgroundImageColor:uint;

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
			this.foregroundImageId = CanvasViewController.NOT_DEFINED;
			this.canvasView.addChild(this.foregroundView);
			
			this.horisontalOffset = CanvasViewController.NOT_DEFINED;
			this.horisontalWidth = CanvasViewController.NOT_DEFINED;
			this.horisontalStep = CanvasViewController.NOT_DEFINED;
			
			this.scaleRelative = false;
		}
		
		public function setCanvasMask(maskRectangle:Rectangle):void
		{
			this.maskView.width = maskRectangle.width;
			this.maskView.height = maskRectangle.height;
		}
		
		function updateBackgroundColor():void
		{
			var backgroundRect:Rectangle = new Rectangle(0,0,this.foregroundView.width,this.foregroundView.height);
			if (this.foregroundView.width == 0 || this.foregroundView.height == 0) {
				backgroundRect = new Rectangle(0,0,this.maskView.width,this.maskView.height);
			}
			this.backgroundViewColor.graphics.clear();
			this.backgroundViewColor.graphics.beginFill(this.backgroundImageColor,1.0);
			this.backgroundViewColor.graphics.drawRect(0,0,backgroundRect.width,backgroundRect.height);
			this.backgroundViewColor.graphics.endFill();
		}
		
		function placeFullImage(e:Event):void
		{
			this.foregroundImageSourceBitmap = this.imageLibrary.getFullImageById(this.foregroundImageId);
			if (this.foregroundImageSourceBitmap == null) {
				return;
			}
			this.foregroundImage = new Bitmap(this.foregroundImageSourceBitmap.clone());
			this.foregroundView.addChild(this.foregroundImage);
			dispatchEvent(new Event(CanvasViewController.FULL_IMAGE_ACCEPTED));
			this.updateHorisontalSlices();
			this.updateScale();
			this.updateBackgroundColor();
		}
		
		function updateHorisontalSlices():void
		{
			if (this.horisontalOffset == CanvasViewController.NOT_DEFINED || this.horisontalWidth == CanvasViewController.NOT_DEFINED || this.horisontalStep == CanvasViewController.NOT_DEFINED) {
				this.foregroundImage.bitmapData = this.foregroundImageSourceBitmap.clone();				
				return;
			}
			var imageRectangle:Rectangle = new Rectangle(0,0,this.foregroundImageSourceBitmap.width,this.foregroundImageSourceBitmap.height);
			var foregroundImageBitmap:BitmapData = new BitmapData(imageRectangle.width,imageRectangle.height,true,0x00ffffff);
			foregroundImageBitmap.copyPixels(this.foregroundImageSourceBitmap,imageRectangle,new Point(0,0));
			
			var slicesNumber:int = Math.ceil((imageRectangle.width - this.horisontalOffset)/(this.horisontalWidth + this.horisontalStep));
			var sliceRectangle:Rectangle;
			for (var i:int = 0; i < slicesNumber; i++) {
				sliceRectangle = new Rectangle(this.horisontalOffset + (this.horisontalWidth + this.horisontalStep) * i,0,this.horisontalWidth,foregroundImageBitmap.height);
				foregroundImageBitmap.fillRect(sliceRectangle,0x00000000);
			}
			this.foregroundView.removeChild(this.foregroundImage);
			this.foregroundImage.bitmapData.dispose();
			this.foregroundImage = null;
			
			this.foregroundImage = new Bitmap(foregroundImageBitmap,"auto",true);
			this.foregroundView.addChild(this.foregroundImage);
			
			this.updateScale();
		}
		
		function updateScale():void
		{
			if (! this.scaleRelative) {
				this.foregroundImage.scaleX = 1.0;
				this.foregroundImage.scaleY = 1.0;
				return;
			}
			var oldWidth:Number = this.foregroundImage.width;
			var oldHeight:Number = this.foregroundImage.height;
			this.foregroundImage.width = this.maskView.width;
			this.foregroundImage.height = oldHeight * this.foregroundImage.width / oldWidth;
			this.updateBackgroundColor();
		}
		
		
		// ControlsViewController delegate
		
		public function applyHorisontalSlicing(sliceOffset:int,sliceWidth:int,sliceStep:int):void
		{
			this.horisontalOffset = sliceOffset;
			this.horisontalWidth = sliceWidth;
			this.horisontalStep = sliceStep;
			this.updateHorisontalSlices();
		}
		
		public function setBackgroundColor(color:uint):void
		{
			this.backgroundImageColor = color;
			this.updateBackgroundColor();
		}
		
		public function setForegroundImage(objectId:int):void
		{
			if (this.foregroundImage != null) {
				this.foregroundView.removeChild(this.foregroundImage);
				this.foregroundImage = null;
			}
			
			var oldId:int = CanvasViewController.NOT_DEFINED;
			if (this.foregroundImageId != CanvasViewController.NOT_DEFINED) {
				oldId = this.foregroundImageId;
			}
			this.foregroundImageId = objectId;
			this.imageLibrary.loadFullImageById(this.foregroundImageId,oldId);
		}
		
		public function setRelativeScale(relative:Boolean):void
		{
			this.scaleRelative = relative;
			this.updateScale();	
			this.updateBackgroundColor();
		}
		
		public function saveCurrentImageWithName(imageName:String):void
		{
			this.foregroundImage.scaleX = 1.0;
			this.foregroundImage.scaleY = 1.0;
			this.canvasView.mask = null;
			this.updateBackgroundColor();
			
			var resultImageBitmap:BitmapData = new BitmapData(this.foregroundImage.width,this.foregroundImage.height,false,0xffffff);
			resultImageBitmap.draw(this.canvasView);
			
			this.updateScale();
			this.updateBackgroundColor();
			this.canvasView.mask = this.maskView;
			
			this.imageLibrary.saveImageWithName(imageName,resultImageBitmap);
			resultImageBitmap.dispose();
		}
	}
	
}
