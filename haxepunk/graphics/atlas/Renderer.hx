package haxepunk.graphics.atlas;

import flash.geom.Rectangle;
import haxepunk.Scene;

@:dox(hide)
#if hardware_render
typedef Renderer = haxepunk.graphics.atlas.HardwareRenderer;

#else
typedef Renderer = NullRenderer;

@:dox(hide)
class NullRenderer
{
	public static function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		throw "hardware rendering not supported on this platform";
	}

	public static function startFrame(scene:Scene) {}
	public static function endFrame(scene:Scene) {}
	public static function startScene(scene:Scene) {}
	public static function flushScene(scene:Scene) {}
}
#end
