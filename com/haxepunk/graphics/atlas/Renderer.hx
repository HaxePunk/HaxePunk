package com.haxepunk.graphics.atlas;


#if (openfl > "4.0.0")
typedef Renderer = com.haxepunk.graphics.atlas.renderer.TileShaderRenderer;
#else
typedef Renderer = com.haxepunk.graphics.atlas.renderer.DrawTilesRenderer;
#end
