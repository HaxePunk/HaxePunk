package haxepunk.graphics.hardware;

import flash.display.BitmapData;
import flash.gl.GL;
import haxepunk.HXP;

@:dox(hide)
class GLUtils
{
	#if lime
	@:access(openfl.display.Stage)
	@:access(lime._internal.renderer.opengl.GLRenderer)
	#end
	public static function bindTexture(texture:BitmapData, smooth:Bool, index:Int=GL.TEXTURE0)
	{
		GL.activeTexture(index);
		#if lime
		var renderer = cast HXP.stage.__renderer;
		var renderSession = renderer.renderSession;
		GL.bindTexture(GL.TEXTURE_2D, texture.getTexture(renderSession.gl));
		#elseif nme
		if (!texture.premultipliedAlpha) texture.premultipliedAlpha = true;
		GL.bindBitmapDataTexture(texture);
		#end
		if (smooth)
		{
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		}
		else
		{
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
	}

#if lime
	public static inline function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
#else
	public static inline function invalid(object:flash.gl.GLObject)
	{
		return object == null || !object.isValid();
	}
#end
}
