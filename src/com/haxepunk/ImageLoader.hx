package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.display.Loader;

typedef GraphicCallback = BitmapData -> Void;

class ImageLoader 
{
	
	private static var complete:GraphicCallback;
	private static var file:String;
	private static var done:Bool;

	public static function load(url:String, complete:GraphicCallback)
	{
		file = url;
		done = false;
		ImageLoader.complete = complete;
#if cpp
		var graphic:Bitmap = new Bitmap(BitmapData.loadFromBytes(ByteArray.readFile(url)));
		data = graphic.bitmapData;
#else
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, pngFailed);
		loader.contentLoaderInfo.addEventListener(Event.INIT, pngLoaded);
		loader.load(new URLRequest(url));
#end
	}
	
	private static function pngFailed(e:IOErrorEvent = null)
	{
		trace("Could not find image " + file);
		done = true;
	}
	
	private static function pngLoaded(e:Event)
	{
//		e.target.content.smoothing = true;
		var bitmap:Bitmap = cast(e.target.content, Bitmap);
		complete(bitmap.bitmapData);
		done = true;
	}
	
}