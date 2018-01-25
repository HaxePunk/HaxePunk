package haxepunk.graphics.hardware.opengl;

import nme.gl.GL;

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		//if (!texture.premultipliedAlpha) texture.premultipliedAlpha = true;
		GL.bindBitmapDataTexture(texture);
	}

	public static inline function invalid(object:nme.gl.GLObject)
	{
		return object == null || !object.isValid();
	}
}
