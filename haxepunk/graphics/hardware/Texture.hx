package haxepunk.graphics.hardware;

import haxepunk.utils.Color;

class Texture
{
	public static inline function create(width:Int, height:Int, transparent:Bool=false, color:Color=0):Texture
	{
		return null;
	}

	public var width:Int = 0;
	public var height:Int = 0;

	public function getPixel(x:Int, y:Int):Color
	{
		return 0;
	}
	public function setPixel(x:Int, y:Int, c:Color) {}

	public function removeColor(color:Color) {}
	public function clearColor(color:Color) {}
	public function drawCircle(x:Float, y:Float, radius:Float) {}
	public function dispose() {}
}
