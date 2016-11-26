package com.haxepunk.graphics.atlas;

import flash.geom.Rectangle;
import com.haxepunk.Scene;

@:dox(hide)
class NullRenderer
{
	public static function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		throw "hardware rendering not supported on this platform";
	}

	public static function startFrame(scene:Scene) {}
	public static function endFrame(scene:Scene) {}
}

@:dox(hide)
#if tile_shader
typedef Renderer = com.haxepunk.graphics.atlas.HardwareRenderer;
#elseif draw_tiles
typedef Renderer = com.haxepunk.graphics.atlas.DrawTilesRenderer;
#else
typedef Renderer = NullRenderer;
#end
