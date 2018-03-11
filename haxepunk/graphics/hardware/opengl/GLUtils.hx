package haxepunk.graphics.hardware.opengl;

import haxe.PosInfos;

@:dox(hide)
class GLUtils
{
	public static function bindTexture(texture:Texture, smooth:Bool, index:Int=GL.TEXTURE0)
	{
		GL.activeTexture(index);
		GLInternal.bindTexture(texture);
		if (smooth)
		{
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		}
		else
		{
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
	}

	public static inline function checkForErrors(?pos:PosInfos)
	{
		#if hxp_gl_debug
		var error = GL.getError();
		if (error != GL.NO_ERROR)
			throw "GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error;
		#else
		var error = GL.getError();
		if (error != GL.NO_ERROR)
			Log.error("GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error);
		#end
	}

	public static inline function invalid(obj:Any):Bool
	{
		return GLInternal.invalid(obj);
	}
}
