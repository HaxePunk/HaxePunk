package haxepunk.graphics.hardware;

import haxepunk.utils.Color;

import flash.display.BitmapData;
import flash.geom.Point;

@:forward(width, height, getPixel, setPixel, clone, dispose)
abstract Texture(BitmapData) from BitmapData to BitmapData
{
	public static inline function create(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		return new BitmapData(width, height, transparent, color);
	}

	public inline function removeColor(color:Color)
	{
		this.threshold(this, this.rect, _zero, "==", color, 0x00000000, 0xFFFFFFFF, true);
	}

	public inline function clearColor(color:Color)
	{
		this.fillRect(this.rect, color);
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		var sprite = new flash.display.Sprite();
		sprite.graphics.clear();
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawCircle(x, y, radius);
		this.draw(sprite);
	}

	static var _zero = new Point(0, 0);
}
