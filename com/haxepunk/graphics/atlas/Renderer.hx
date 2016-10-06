package com.haxepunk.graphics.atlas;

@:dox(hide)
class HardwareNotSupportedRenderer
{
	public function new(data:AtlasData) {}

	public function drawTiles(graphics, tileData, smooth, flags, count):Void
	{
		throw "hardware rendering not supported on this platform";
	}
}

#if (openfl >= "4.0.0")
#if flash
// shouldn't be used
typedef Renderer = HardwareNotSupportedRenderer;
#else
typedef Renderer = com.haxepunk.graphics.atlas.renderer.TileShaderRenderer;
#end
#else
typedef Renderer = com.haxepunk.graphics.atlas.renderer.DrawTilesRenderer;
#end
