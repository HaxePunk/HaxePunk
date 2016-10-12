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

#if tile_shader
typedef Renderer = com.haxepunk.graphics.atlas.renderer.TileShaderRenderer;
#elseif draw_tiles
typedef Renderer = com.haxepunk.graphics.atlas.renderer.DrawTilesRenderer;
#else
typedef Renderer = HardwareNotSupportedRenderer;
#end
