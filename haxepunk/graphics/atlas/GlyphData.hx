package haxepunk.graphics.atlas;

import flash.geom.Rectangle;

typedef GlyphData =
{
	var region:AtlasRegion;
	var glyph:String;
	var rect:Rectangle;
	var xOffset:Int;
	var yOffset:Int;
	var xAdvance:Int;
	var scale:Float;
};
