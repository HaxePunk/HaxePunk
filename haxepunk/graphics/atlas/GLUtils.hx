package haxepunk.graphics.atlas;

#if hardware_render
import flash.gl.GLObject;

@:dox(hide)
class GLUtils
{
#if (lime && js)
	public static function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
#else
	public static function invalid(object:GLObject)
	{
		return object == null || !object.isValid();
	}
#end
}
#end
