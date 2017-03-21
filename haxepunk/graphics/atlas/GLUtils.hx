package haxepunk.graphics.atlas;

#if hardware_render
@:dox(hide)
class GLUtils
{
#if lime
	public static function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
#else
	public static function invalid(object:flash.gl.GLObject)
	{
		return object == null || !object.isValid();
	}
#end
}
#end
