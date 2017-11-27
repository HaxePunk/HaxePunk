package haxepunk.backend.lime;

import lime.graphics.opengl.GL;
import haxepunk.graphics.hardware.Texture;
import haxepunk.backend.flash.BitmapImageData;

class GLInternal
{
	@:access(openfl.display.Stage)
	@:access(lime._internal.renderer.opengl.GLRenderer)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var renderer = cast cast(HXP.app, flash.display.Sprite).stage.__renderer;
		var renderSession = renderer.renderSession;
		GL.bindTexture(GL.TEXTURE_2D, cast(texture.image, BitmapImageData).data.getTexture(renderSession.gl));
	}

	public static inline function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
}
