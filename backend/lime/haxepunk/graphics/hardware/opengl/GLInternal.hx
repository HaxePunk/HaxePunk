package haxepunk.graphics.hardware.opengl;

import openfl.display.BitmapData;
import lime.graphics.opengl.GL;
import lime.graphics.GLRenderContext;

class GLInternal
{
	#if (openfl >= "8.0.0")
	public static var renderer:openfl.display.OpenGLRenderer;
	public static var gl:GLRenderContext;
	#end

	@:access(openfl.display.Stage)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		#if (openfl < "8.0.0")
		var renderer = @:privateAccess (HXP.app.stage.__renderer).renderSession;
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
