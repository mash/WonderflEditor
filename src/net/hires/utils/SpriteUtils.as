/**
 * Hi-ReS! SpriteUtils v0.1
 *  
 * How to use:
 * 
 * 	SpriteUtils.tint(mySprite,0xFFFFFF);
 * 
 * version log:
 * 
 *  08.01.30		0.1		Mr.doob		Big bang
 **/

package net.hires.utils
{		
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	public class SpriteUtils
	{  
		static public function tint( target:Sprite, hexColor:Number ):void
		{
			var rgbColor:Object = ColorUtils.getRGB(hexColor);
			target.transform.colorTransform = new ColorTransform( 0, 0, 0, 1, rgbColor.r * 255, rgbColor.g * 255, rgbColor.b * 255 );
		}
		
		/**
		* Creates a Video Controller
		*
		* @param		sprite				Sprite			Sprite to resize
		* @param		originalWidth		Number			There original/real width of the Sprite
		* @param		originalHeight		Number			There original/real height of the Sprite
		* @param		targetWidth			Number			There width to resize the Sprite to
		* @param		targetHeight		Number			There height to resize the Sprite to
		* @param		mode				String			Possible modes: "fit","cropped_fit"
		*/
		static public function resize( sprite:Sprite, originalWidth:Number, originalHeight:Number, targetWidth:Number, targetHeight:Number, mode:String ):void
		{
			switch(mode)
			{
				case "fit":
				
					if ((originalWidth / targetWidth) < (originalHeight / targetHeight))
					{
						sprite.height = targetHeight;
						sprite.width = originalWidth * (targetHeight / originalHeight);
					}
					else
					{
						sprite.width = targetWidth;
						sprite.height = originalHeight * (targetWidth / originalWidth);
					}				
				
				break;
				case "cropped_fit":
				
					if ((originalWidth / targetWidth) > (originalHeight / targetHeight))
					{
						sprite.height = targetHeight;
						sprite.width = originalWidth * (targetHeight / originalHeight);
					}
					else
					{
						sprite.width = targetWidth;
						sprite.height = originalHeight * (targetWidth / originalWidth);
					}				
				
				break;
			}
		}
	}
}