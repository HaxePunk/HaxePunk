package com.haxepunk.graphics.atlas;

import com.haxepunk.graphics.atlas.AtlasData;
import flash.display.Sprite;
import flash.geom.Rectangle;

class Atlas
{

	/**
	 * Whether or not to use antialiasing (default: false)
	 */
	public static var smooth:Bool = false;

	/**
	 * The width of this atlas
	 */
	public var width(get, never):Int;
	private function get_width():Int { return _data.width; }

	/**
	 * The height of this atlas
	 */
	public var height(get, never):Int;
	private function get_height():Int { return _data.height; }

	private function new(source:AtlasDataType)
	{
		_data = AtlasData.create(source);
	}

	/**
	 * Loads an image and returns the full image as a region
	 * @param	source	The image to use
	 * @return	An AtlasRegion containing the whole image
	 */
	public static function loadImageAsRegion(source:AtlasDataType):AtlasRegion
	{
		var data = AtlasData.create(source);
		return data.createRegion(new Rectangle(0, 0, data.width, data.height));
	}

	/**
	 * Removes an atlas from the display list
	 */
	public function destroy()
	{
		_data.destroy();
	}

	/**
	 * Prepares tile data for rendering
	 * @param	tile	The tile index of the tilesheet
	 * @param	x		The x-axis location to draw the tile
	 * @param	y		The y-axis location to draw the tile
	 * @param	layer	The layer to draw on
	 * @param	scaleX	The scale value for the x-axis
	 * @param	scaleY	The scale value for the y-axis
	 * @param	angle	An angle to rotate the tile
	 * @param	red		A red tint value
	 * @param	green	A green tint value
	 * @param	blue	A blue tint value
	 * @param	alpha	The tile's opacity
	 */
	public inline function prepareTile(tile:Int, x:Float, y:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		_data.prepareTile(tile, x, y, layer, scaleX, scaleY, angle, red, green, blue, alpha);
	}

	/**
	 * How many Atlases are active.
	 */
	// public static var count(get, never):Int;
	// private static inline function get_count():Int { return _atlases.length; }

	private var _data:AtlasData;
}
