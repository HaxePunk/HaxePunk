package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.graphics.shaders.Shader;
import haxepunk.utils.Color;

interface IAtlasRegion
{
	public var width(get, never):Int;
	public var height(get, never):Int;

	public function draw(x:Float, y:Float, layer:Int,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle):Void;

	public function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		layer:Int, color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle):Void;

	public function clip(clipRect:Rectangle, ?center:Point):IAtlasRegion;
	public function destroy():Void;
}
