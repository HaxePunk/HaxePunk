package com.haxepunk.graphics.atlas;

/**
 * Renderer-specific flags.
 */
class Tilesheet
{
	public static inline var TILE_SCALE = 0x0001;
	public static inline var TILE_ROTATION = 0x0002;
	public static inline var TILE_RGB = 0x0004;
	public static inline var TILE_ALPHA = 0x0008;
	public static inline var TILE_TRANS_2X2 = 0x0010;
	public static inline var TILE_RECT = 0x0020;
	public static inline var TILE_ORIGIN = 0x0040;
	public static inline var TILE_TRANS_COLOR = 0x0080;

#if (openfl >= "4.0.0")
	public static inline var TILE_BLEND_NORMAL:Int = cast openfl.display.BlendMode.ALPHA;
	public static inline var TILE_BLEND_ADD:Int = cast openfl.display.BlendMode.ADD;
	public static inline var TILE_BLEND_MULTIPLY:Int = cast openfl.display.BlendMode.MULTIPLY;
	public static inline var TILE_BLEND_SCREEN:Int = cast openfl.display.BlendMode.SCREEN;
	public static inline var TILE_BLEND_SUBTRACT:Int = cast openfl.display.BlendMode.SUBTRACT;
#else
	public static inline var TILE_BLEND_NORMAL:Int = openfl.display.Tilesheet.TILE_BLEND_NORMAL;
	public static inline var TILE_BLEND_ADD:Int = openfl.display.Tilesheet.TILE_BLEND_ADD;
	public static inline var TILE_BLEND_MULTIPLY:Int = openfl.display.Tilesheet.TILE_BLEND_MULTIPLY;
	public static inline var TILE_BLEND_SCREEN:Int = openfl.display.Tilesheet.TILE_BLEND_SCREEN;
	public static inline var TILE_BLEND_SUBTRACT:Int = openfl.display.Tilesheet.TILE_BLEND_SUBTRACT;
#end
}
