package com.haxepunk;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Loader;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.Lib;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;
import haxe.Resource;

/**
 * Loads assets and calls the onLoaded function on completion
 */
class DataLoader 
{
	
	var loader : Loader;
	var bytes : URLLoader;
	var queue : Array<{ url:String, binary:Bool, cb:Dynamic -> Void }>;

	public function new() 
	{
		queue = new Array();
	}
	
	public function add(url, binary, callbackFunc)
	{
		queue.push({ url : url, binary : binary, cb : callbackFunc });
	}
	
	public function loadBitmap(file:String, bitmap:Bitmap)
	{
		#if flash
			var me = this;
			add(file, false, function(obj) {
				var bdata = Lib.as(obj, Bitmap);
				if (bdata == null)
				{
					me.onError(file, "Not a bitmap");
				}
				else
				{
					bitmap.bitmapData = bdata.bitmapData;
				}
			});
		#else
			bitmap.bitmapData = BitmapData.load(file);
		#end
	}
	
	public function start()
	{
		var me = this;
		var e = queue.shift();
		loader = null;
		bytes = null;
		if (e == null)
		{
			onLoaded();
			return;
		}
		var data = Resource.getBytes(e.url);
		if (data != null)
		{
			if (e.binary)
			{
				e.cb(data.getData());
				start();
			}
			else
			{
				#if flash
					loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
						e.cb(me.loader.content);
						me.start();
					});
					loader.loadBytes(data.getData());
				#end
			}
			return;
		}
		#if flash
			if (e.binary)
			{
				bytes = new URLLoader(new URLRequest(e.url));
				bytes.dataFormat = URLLoaderDataFormat.BINARY;
				bytes.addEventListener(IOErrorEvent.IO_ERROR, function(err:IOErrorEvent) me.onError(e.url, err.text));
				bytes.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(err:flash.events.SecurityErrorEvent) me.onError(e.url, err.text));
				bytes.addEventListener(Event.COMPLETE, function(_) {
					e.cb(me.bytes.data);
					me.start();
				});
			}
			else
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(err:IOErrorEvent) me.onError(e.url, err.text));
				loader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(err:flash.events.SecurityErrorEvent) me.onError(e.url, err.text));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
					e.cb(me.loader.content);
					me.start();
				});
				loader.load(new URLRequest(e.url));
			}
		#else
			if (e.binary)
			{
				var b = ByteArray.readFile(e.url);
				if (b == null)
				{
					onError(e.url, "could not load from file");
				}
				else
				{
					e.cb(b);
					start();
				}
			}
			else
			{
				// TODO: check for image etc.
			}
		#end
	}
	
	public dynamic function onError( url : String, msg : String )
	{
		throw "Error while loading " + url + " (" + msg + ")";
	}

	public dynamic function onLoaded()
	{
		
	}
	
}