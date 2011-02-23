package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.display.Loader;

typedef GraphicCallback = Bitmap -> Void;

class BitmapLoader 
{
	
	public var bitmap:Bitmap;
	public var loaded:Bool;

	public function new(url:String, ?complete:GraphicCallback)
	{
		_url = url;
		_complete = complete;
		loaded = false;
#if flash
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failed);
		loader.contentLoaderInfo.addEventListener(Event.INIT, finished);
		loader.load(new URLRequest(url));
#else
		bitmap = new Bitmap(BitmapData.loadFromBytes(ByteArray.readFile(url)));
		if (_complete != null) _complete(bitmap);
		loaded = true;
#end
	}
	
	private function failed(e:IOErrorEvent = null)
	{
		trace("Could not find image " + _url);
	}
	
	private function finished(e:Event)
	{
		e.target.content.smoothing = true;
		bitmap = cast(e.target.content, Bitmap);
		if (_complete != null) _complete(bitmap);
		loaded = true;
	}
	
	private var _complete:GraphicCallback;
	private var _url:String;
	
}