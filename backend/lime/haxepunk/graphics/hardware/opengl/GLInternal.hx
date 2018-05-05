package haxepunk.graphics.hardware.opengl;

import openfl.display.BitmapData;
import lime.graphics.opengl.GL;

class GLInternal
{
	@:access(openfl.display.Stage)
	@:access(lime._internal.renderer.opengl.GLRenderer)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var renderer = cast cast(HXP.app, flash.display.Sprite).stage.__renderer;
		#if (openfl < "8.0.0")
		var renderer = renderer.renderSession;
		#end
		var bmd:BitmapData = cast texture;
		GL.bindTexture(GL.TEXTURE_2D, bmd.getTexture(renderer.gl));
	}

	public static inline function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
}
