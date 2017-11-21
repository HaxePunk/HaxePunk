package haxepunk.backend.nme;

import nme.gl.GL;
import haxepunk.graphics.hardware.Texture;

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var bitmap = texture.image;
		if (!bitmap.premultipliedAlpha) bitmap.premultipliedAlpha = true;
		GL.bindBitmapDataTexture(bitmap);
	}

	public static inline function invalid(object:nme.gl.GLObject)
	{
		return object == null || !object.isValid();
	}
}
