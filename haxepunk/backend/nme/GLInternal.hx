package haxepunk.backend.nme;

#if nme

import nme.gl.GL;
import haxepunk.graphics.hardware.Texture;
import haxepunk.backend.flash.BitmapImageData;

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var bitmap = cast(texture.image, BitmapImageData).data;
		if (!bitmap.premultipliedAlpha) bitmap.premultipliedAlpha = true;
		GL.bindBitmapDataTexture(bitmap);
	}

	public static inline function invalid(object:nme.gl.GLObject)
	{
		return object == null || !object.isValid();
	}
}

#end
