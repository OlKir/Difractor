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
		
		var imageLibrary:ImageLibrary;
		
		var canvasView:Sprite;
		var maskView:Sprite;
		
		var backgroundView:Sprite;
		var backgroundViewColor:Shape;
		var backgroundImage:Bitmap;
		var backgroundImageId:int;
		
		var foregroundView:Sprite;
		var foregroundImage:Bitmap;
		var foregroundImageId:int;
		
		var foregroundImageSourceBitmap:BitmapData;
		
		var scaleRelative:Boolean;
		var alterationEnabled:Boolean;
		
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
			this.backgroundImageId = CanvasViewController.NOT_DEFINED;
			
			this.foregroundView = new Sprite();
			this.foregroundImageId = CanvasViewController.NOT_DEFINED;
			this.canvasView.addChild(this.foregroundView);
			
			this.horisontalOffset = CanvasViewController.NOT_DEFINED;
			this.horisontalWidth = CanvasViewController.NOT_DEFINED;
			this.horisontalStep = CanvasViewController.NOT_DEFINED;
			
			this.scaleRelative = false;
			this.alterationEnabled = false;
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
			this.clearImages();
			
			if (this.foregroundImageId != CanvasViewController.NOT_DEFINED) {
				this.foregroundImageSourceBitmap = this.imageLibrary.getFullImageById(this.foregroundImageId);
				this.foregroundImage = new Bitmap(this.foregroundImageSourceBitmap.clone());
				this.foregroundView.addChild(this.foregroundImage);
				dispatchEvent(new Event(CanvasViewController.FULL_IMAGE_ACCEPTED));
			}
			
			if (this.backgroundImageId != CanvasViewController.NOT_DEFINED) {
				var backgroundBitmap:BitmapData = this.imageLibrary.getFullImageById(this.backgroundImageId);
				this.backgroundImage = new Bitmap(backgroundBitmap.clone());
				this.backgroundView.addChild(this.backgroundImage);
			}
			
			this.updateHorisontalSlices();
			this.updateScale();
			this.updateBackgroundColor();
		}
		
		function clearImages():void
		{
			if (this.foregroundImage != null) {
				this.foregroundView.removeChild(this.foregroundImage);
				this.foregroundImage = null;
			}
			if (this.backgroundImage != null) {
				this.backgroundView.removeChild(this.backgroundImage);
				this.backgroundImage = null;
			}
		}
		
		function updateHorisontalSlices():void
		{
			if ( ! this.foregroundImageSourceBitmap) {
				return;
			}
			
			if (this.isDefaultSliceValues()) {
				this.foregroundImage.bitmapData = this.foregroundImageSourceBitmap.clone();				
				return;
			}
			if (this.alterationEnabled) {
				this.createAlteratedImage();
				return;
			}
			this.createMixedImage();
		}
		
		function isDefaultSliceValues():Boolean
		{
			if ( this.horisontalWidth == CanvasViewController.NOT_DEFINED) {
				return true;
			}
			if ( this.horisontalStep == CanvasViewController.NOT_DEFINED) {
				return true;
			}			
			
			return false;
		}
		
		function createAlteratedImage():void
		{
			var imageRectangle:Rectangle = new Rectangle(0,0,this.foregroundImageSourceBitmap.width,this.foregroundImageSourceBitmap.height);
			var backgroundImageSourceBitmap:BitmapData = new BitmapData(imageRectangle.width * 2,imageRectangle.height,false,backgroundImageColor); 
			if (this.backgroundImage) {
				backgroundImageSourceBitmap = this.backgroundImage.bitmapData;
				this.backgroundImage.visible = false;
			}
			
			var foregroundImageBitmap:BitmapData = new BitmapData(imageRectangle.width * 2,imageRectangle.height,true,0x00ffffff);
			
			var slicesNumber:int = Math.ceil(imageRectangle.width / this.horisontalWidth);
			var sliceRectangle:Rectangle;
			var destinationPoint:Point = null;
			for (var i:int = 0; i < slicesNumber; i++) {
				// Copying slice from foreground image
				sliceRectangle = new Rectangle(i * this.horisontalWidth,0,this.horisontalWidth,foregroundImageBitmap.height);
				destinationPoint = new Point(i *(this.horisontalWidth + this.horisontalStep),0.0);
				foregroundImageBitmap.copyPixels(this.foregroundImageSourceBitmap,sliceRectangle,destinationPoint);
				
				// Copying slice from background image 
				sliceRectangle = new Rectangle(i * this.horisontalStep,0,this.horisontalStep,foregroundImageBitmap.height);
				destinationPoint = new Point(i *(this.horisontalWidth + this.horisontalStep) + this.horisontalWidth,0.0);
				foregroundImageBitmap.copyPixels(backgroundImageSourceBitmap,sliceRectangle,destinationPoint);
			}
			this.setBitmapToForegroundImage(foregroundImageBitmap);
		}
		
		function createMixedImage():void
		{
			if (this.backgroundImage) {
				this.backgroundImage.visible = true;
			}
			
			var imageRectangle:Rectangle = new Rectangle(0,0,this.foregroundImageSourceBitmap.width,this.foregroundImageSourceBitmap.height);
			var foregroundImageBitmap:BitmapData = new BitmapData(imageRectangle.width,imageRectangle.height,true,0x00ffffff);
			foregroundImageBitmap.copyPixels(this.foregroundImageSourceBitmap,imageRectangle,new Point(0,0));
			
			var slicesNumber:int = Math.ceil(imageRectangle.width /(this.horisontalWidth + this.horisontalStep));
			var sliceRectangle:Rectangle;
			for (var i:int = 0; i < slicesNumber; i++) {
				sliceRectangle = new Rectangle((this.horisontalWidth + this.horisontalStep) * i,0,this.horisontalWidth,foregroundImageBitmap.height);
				foregroundImageBitmap.fillRect(sliceRectangle,0x00000000);
			}
			this.setBitmapToForegroundImage(foregroundImageBitmap);
		}
		
		function setBitmapToForegroundImage(imageBitmap:BitmapData):void
		{
			this.foregroundView.removeChild(this.foregroundImage);
			this.foregroundImage.bitmapData.dispose();
			this.foregroundImage = null;
			
			this.foregroundImage = new Bitmap(imageBitmap,"auto",true);
			this.foregroundView.addChild(this.foregroundImage);
			
			this.updateScale();
		}
		
		
		function updateScale():void
		{
			var oldWidth:Number = 0;
			var oldHeight:Number = 0;
			if (! this.scaleRelative) {
				if (this.foregroundImage) {
					this.foregroundImage.scaleX = 1.0;
					this.foregroundImage.scaleY = 1.0;
				}
				if (this.backgroundImage) {
					this.backgroundImage.scaleX = 1.0;
					this.backgroundImage.scaleY = 1.0;
				}
				return;
			}
			if (this.foregroundImage) {
				oldWidth = this.foregroundImage.width;
				oldHeight = this.foregroundImage.height;
				this.foregroundImage.width = this.maskView.width;
				this.foregroundImage.height = oldHeight * this.foregroundImage.width / oldWidth;
			}
			if (this.backgroundImage) {
				oldWidth = this.backgroundImage.width;
				oldHeight = this.backgroundImage.height;
				this.backgroundImage.width = this.maskView.width;
				this.backgroundImage.height = oldHeight * this.backgroundImage.width / oldWidth;
			}
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
		
		public function applyAlteration(alteration:Boolean):void
		{
			this.alterationEnabled = alteration;
			this.updateHorisontalSlices();
		}
		
		public function setBackgroundColor(color:uint):void
		{
			this.backgroundImageColor = color;
			if (this.backgroundImage != null) {
				this.backgroundView.removeChild(this.backgroundImage);
				this.backgroundImage = null;
				this.backgroundImageId = CanvasViewController.NOT_DEFINED;
			}
			if (this.alterationEnabled) {
				this.updateHorisontalSlices();
			}
			
			this.updateBackgroundColor();
		}
		
		public function setForegroundImage(objectId:int):void
		{
			if (objectId == this.foregroundImageId) {
				return;
			}
			
			if (objectId == this.backgroundImageId) {
				this.foregroundImageId = objectId;
				this.placeFullImage(null);
				return;
			}
			
			var oldId:int = CanvasViewController.NOT_DEFINED;
			if (this.foregroundImageId != CanvasViewController.NOT_DEFINED) {
				oldId = this.foregroundImageId;
			}
			if (this.backgroundImageId == oldId) {
				oldId = CanvasViewController.NOT_DEFINED;
			}

			this.foregroundImageId = objectId;
			this.imageLibrary.loadFullImageById(this.foregroundImageId,oldId);
		}
		
		public function setBackgroundImage(objectId:int):void
		{
			if (objectId == this.backgroundImageId) {
				return;
			}
			
			if (objectId == this.foregroundImageId) {
				this.backgroundImageId = objectId;
				this.placeFullImage(null);
				return;
			}
			
			var oldId:int = CanvasViewController.NOT_DEFINED;
			if (this.backgroundImageId != CanvasViewController.NOT_DEFINED) {
				oldId = this.backgroundImageId;
			}
			if (this.foregroundImageId == oldId) {
				oldId = CanvasViewController.NOT_DEFINED;
			}

			this.backgroundImageId = objectId;
			this.imageLibrary.loadFullImageById(this.backgroundImageId,oldId);
		}
		
		
		public function setRelativeScale(relative:Boolean):void
		{
			this.scaleRelative = relative;
			this.updateScale();	
			this.updateBackgroundColor();
		}
		
		public function saveCurrentImageWithName(imageName:String):void
		{
			if (this.foregroundImage) {
				this.foregroundImage.scaleX = 1.0;
				this.foregroundImage.scaleY = 1.0;
			}
			if (this.backgroundImage) {
				this.backgroundImage.scaleX = 1.0;
				this.backgroundImage.scaleY = 1.0;
			}
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
