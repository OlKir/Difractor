package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
 
	public class BitmapResampler
	{
 
		public function BitmapResampler( ) { }
 
		//returns a BitmapData Instance of the image of the source DisplayObject / BitmapData
		public static function getResampledBitmapData( source : IBitmapDrawable , width : Number , height : Number ) : BitmapData {
 
		var sourceBitmapData : BitmapData;
 
		if ( source is DisplayObject ) { // if source is a DisplayObject instance
				sourceBitmapData  = getBitmapDataFromDisplayObject( DisplayObject( source )  );
		}else if ( source is BitmapData) { // if source is a BitmapData instance
				sourceBitmapData = source as BitmapData;
		}else { // break on unhandled source
				return null; 
		}
 
		//set the scale for the draw operation, for the new width / height
		var matrix : Matrix =  new Matrix();
		matrix.scale( width / sourceBitmapData.width  , height / sourceBitmapData.height );
 
		//create the resized bitmap data
		var ouputBitmapData : BitmapData = new BitmapData( width, height , true , 0x00000000 );
 
		//draw the source to the bitmapData instance
		ouputBitmapData.draw( sourceBitmapData , matrix , null , null , null , true );
 
		//dispose of temporary bitmap data
		if ( source is DisplayObject ) sourceBitmapData.dispose();
 
		return ouputBitmapData;
 
	}
 
		//returns a Bitmap of the image of the source DisplayObject / BitmapData
		public static function getResampledBitmap( source : IBitmapDrawable , width : Number , height : Number ) : Bitmap {
			var bmp : Bitmap = new Bitmap( getResampledBitmapData( source , width, height ) );
			bmp.smoothing = true;
			return bmp;
		}
 
		// this function will create a BitmapData instance which contains the image of the source DisplayObject
		// note : transformations will be reset
		protected static function getBitmapDataFromDisplayObject( source : DisplayObject ) : BitmapData {
 
			//get the rectangle of the image data in the DisplayObject
			var sourceRect : Rectangle = DisplayObject( source ).getBounds( DisplayObject( source ) );
 
			//create a BitmapData instance to draw the DisplayObject to
			var bitmapData : BitmapData = new BitmapData( sourceRect.width , sourceRect.height , true , 0x000000000 );
 
			//draw the portion of the clip that contains image data
			var matrix : Matrix = new Matrix();
			matrix.translate( -sourceRect.x , -sourceRect.y );
			bitmapData.draw( source , matrix , null , null , null , true );
 
			return bitmapData;
		}
 
	}
 
}