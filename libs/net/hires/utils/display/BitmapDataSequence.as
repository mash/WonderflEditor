/**
 * Hi-ReS! BitmapDataSequence v1.1
 * Copyright (c) 2008 Mr.doob @ hi-res.net
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * How to use:
 * 
 *	var video:BitmapDataSequence = BitmapDataSequence( "flvinaswf.swf", 320, 340, 30 );
 *	addChild(video);
 * 
 * version log:
 * 
 *  08.03.22		1.1		Mr.doob			+ Now you can set the size of the video
 * 	08.03.18		1.0		Mr.doob			+ First version
 **/

package net.hires.utils.display
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	public class BitmapDataSequence extends Sprite
	{
		private var file		:String;
		private var finalSize	:Object = { width:0, height:0 };
		private var originalSize:Object = { width:0, height:0 };
		private var bdheight	:Number;
		private var fps			:Number;
		private var totalFrames	:Number;
		
		private var bitmap		:Bitmap;
		private var mc			:MovieClip;
		private var loader		:Loader;
		private var bdArray		:Array;
		
		private var frame		:Number;
		
		public function BitmapDataSequence(file:String, width:Number = 0, height:Number = 0, fps:Number = 0):void
		{
			this.file = file;
			this.fps = (fps) ? fps : 30;
			this.finalSize.width = (width) ? width : 0;
			this.finalSize.height = (height) ? height : 0;
			
			loader = new Loader();
			bdArray = new Array();
			bitmap = new Bitmap();
			addChild(bitmap);
			
			load();
		}
		
		private function nextFrame():void
		{
			bitmap.bitmapData = bdArray[frame];
			frame ++;
			frame %= totalFrames-1;
			setTimeout(nextFrame, 1000 / fps);
		}
		
		private function load():void
		{
			loader.load(new URLRequest(file));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}		
		
		private function onLoadComplete(e:Event):void
		{
			mc = e.target.content;
			
			originalSize.width = mc.width;
			originalSize.height = mc.height;
			
			if (!finalSize.width)
			{
				finalSize.width = mc.width;
				finalSize.height = mc.height;
			}
			
			totalFrames = mc.totalFrames;
			frame = 1;
			convert();
		}
		
		private function convert():void
		{
			if (frame == totalFrames)
			{
				nextFrame();
				return;
			}
				
			mc.gotoAndStop(frame);
			
			var mtr:Matrix = new Matrix();
			
			mtr.scale(finalSize.width / originalSize.width, finalSize.height / originalSize.height);
			
			var bd:BitmapData = new BitmapData(finalSize.width, finalSize.height, true, 0x00000000);
			bd.draw(mc, mtr);
			
			bdArray.push(bd);
			frame++;
			
			convert();
		}
		
	}
	
}