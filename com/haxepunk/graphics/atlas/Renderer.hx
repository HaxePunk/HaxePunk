package com.haxepunk.graphics.atlas;


#if tile_shader
typedef Renderer = com.haxepunk.graphics.atlas.renderer.TileShaderRenderer;
#else
typedef Renderer = com.haxepunk.graphics.atlas.renderer.DrawTilesRenderer;
#end
