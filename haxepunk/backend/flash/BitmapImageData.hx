package haxepunk.backend.flash;

import haxepunk.graphics.hardware.ImageData;
import haxepunk.utils.Color;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.Assets;

class BitmapImageData implements ImageData
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	public var data(default, null):BitmapData;

	function new(data:BitmapData)
	{
		this.data = data;
		this.width = data.width;
		this.height = data.height;
	}

	public static inline function create(width:Int, height:Int, transparent:Bool, color:Color):BitmapImageData
	{
		return new BitmapImageData(new BitmapData(width, height, transparent, color));
	}

	public static inline function get(name:String):BitmapImageData
	{
		return new BitmapImageData(Assets.getBitmapData(name, false));
	}

	public inline function getPixel(x:Int, y:Int):Int
	{
		return data.getPixel32(x, y);
	}

	public inline function removeColor(color:Int)
	{
		data.threshold(data, data.rect, _zero, "==", color, 0x00000000, 0xFFFFFFFF, true);
	}

	public inline function clearColor(color:Int)
	{
		data.fillRect(data.rect, color);
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		var sprite = new flash.display.Sprite();
		sprite.graphics.clear();
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawCircle(x, y, radius);
		data.draw(sprite);
	}

	public inline function dispose():Void
	{
		data.dispose();
		data = null;
	}

	static var _zero = new Point(0, 0);
}
