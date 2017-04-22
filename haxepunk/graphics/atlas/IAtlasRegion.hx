package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.graphics.shaders.Shader;

interface IAtlasRegion
{
	public var width(get, never):Int;
	public var height(get, never):Int;

	public function draw(x:Float, y:Float, layer:Int, shader:Shader,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1,
		smooth:Bool, blend:BlendMode, ?clipRect:Rectangle):Void;

	public function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		layer:Int, shader:Shader, red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1,
		smooth:Bool, blend:BlendMode, ?clipRect:Rectangle):Void;

	public function clip(clipRect:Rectangle, ?center:Point):IAtlasRegion;
	public function destroy():Void;
}
