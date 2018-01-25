package haxepunk.graphics.hardware.opengl;

class GLInternal
{
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture) {}

	public static inline function invalid(object:UInt)
	{
		return object == 0;
	}
}
