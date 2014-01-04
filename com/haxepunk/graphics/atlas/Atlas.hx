package com.haxepunk.graphics.atlas;

import flash.display.Sprite;
import flash.geom.Rectangle;

class Atlas
{

	/**
	 * When a draw array hits this threshold it is rendered and flushed
	 * It keeps memory to a minimum which improves rendering on mobile devices
	 */
	public static var drawCallThreshold:Int = 2000;

	/**
	 * Whether or not to use antialiasing (default: false)
	 */
	public static var smooth:Bool = false;

	/**
	 * The width of this atlas
	 */
	public var width(get_width, never):Int;
	private function get_width():Int { return _data.width; }

	/**
	 * The height of this atlas
	 */
	public var height(get_height, never):Int;
	private function get_height():Int { return _data.height; }

	private function new(source:Dynamic)
	{
		_data = AtlasData.create(source);
	}

	/**
	 * Loads an image and returns the full image as a region
	 * @param	source	The image to use
	 * @return	An AtlasRegion containing the whole image
	 */
	public static function loadImageAsRegion(source:Dynamic):AtlasRegion
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
	// public static var count(get_count, never):Int;
	// private static inline function get_count():Int { return _atlases.length; }

	/**
	 * Toggle the visibility of a layer.
	 *
	 * @param	layer	The layer to toggle.
	 *
	 * @return	The new visibility of the layer.
	 */
	public static function toggleLayerVisibility(layer:Int):Bool
	{
		// var sprite = _sprites.get(layer);
		// if (sprite != null)
		// {
		// 	return sprite.visible = !sprite.visible;
		// }
		return false;
	}

	private var _data:AtlasData;
}
