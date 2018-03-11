package haxepunk.graphics.atlas;

import haxepunk.utils.BlendMode;
import haxepunk.graphics.shader.Shader;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;
import haxepunk.utils.Color;

interface IAtlasRegion
{
	public var width(get, never):Int;
	public var height(get, never):Int;

	public function draw(x:Float, y:Float,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle,
		flexibleLayer:Bool=false):Void;

	public function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle,
		flexibleLayer:Bool=false):Void;

	public function clip(clipRect:Rectangle, ?center:Vector2):IAtlasRegion;
}
