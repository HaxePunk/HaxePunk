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
	public function new() {}

	public function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		throw "hardware rendering not supported on this platform";
	}

	public function startFrame(scene:Scene) {}
	public function endFrame(scene:Scene) {}
	public function startScene(scene:Scene) {}
	public function flushScene(scene:Scene) {}
}
#end
