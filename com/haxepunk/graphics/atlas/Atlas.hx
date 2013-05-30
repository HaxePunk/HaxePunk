package com.haxepunk.graphics.atlas;

import flash.display.Sprite;
import flash.geom.Rectangle;

class Atlas
{

	public static var drawCallThreshold:Int = 25000;
	public static var smooth:Bool = false;

	public var width(get_width, never):Int;
	private function get_width():Int { return _data.width; }

	public var height(get_height, never):Int;
	private function get_height():Int { return _data.height; }

	private function new(source:Dynamic)
	{
		_data = AtlasData.create(source);
	}

	/**
	 * Loads an image and returns the full image as a region
	 * @param source the image to use
	 * @return an AtlasRegion containing the whole image
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
	 * @param tile the tile index of the tilesheet
	 * @param x the x-axis location to draw the tile
	 * @param y the y-axis location to draw the tile
	 * @param layer the layer to draw on
	 * @param scaleX the scale value for the x-axis
	 * @param scaleY the scale value for the y-axis
	 * @param angle an angle to rotate the tile
	 * @param red a red tint value
	 * @param green a green tint value
	 * @param blue a blue tint value
	 * @param alpha the tile's opacity
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
