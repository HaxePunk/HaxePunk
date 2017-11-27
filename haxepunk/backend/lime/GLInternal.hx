package haxepunk.backend.lime;

import lime.graphics.opengl.GL;
import haxepunk.graphics.hardware.Texture;

class GLInternal
{
	@:access(openfl.display.Stage)
	@:access(lime._internal.renderer.opengl.GLRenderer)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var renderer = cast HXP.app.stage.__renderer;
		var renderSession = renderer.renderSession;
		GL.bindTexture(GL.TEXTURE_2D, texture.image.getTexture(renderSession.gl));
	}

	public static inline function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
}
