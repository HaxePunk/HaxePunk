package haxepunk.graphics.atlas;

@:dox(hide)
class GLUtils
{
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
