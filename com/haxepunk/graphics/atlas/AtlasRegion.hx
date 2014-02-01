package com.haxepunk.graphics.atlas;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;

class AtlasRegion
{

	/**
	 * If the region is rotated by 90 degress (used for sprite packing)
	 */
	public var rotated:Bool;
	/**
	 * The tile index used for rendering
	 */
	public var tileIndex(default, null):Int;
	/**
	 * Width of this region
	 */
	public var width(get_width, never):Float;
	/**
	 * Height of this region
	 */
	public var height(get_height, never):Float;

	/**
	 * Creates a new AtlasRegion
	 * @param  parent    The AtlasData parent to use for rendering
	 * @param  tileIndex The tile index to use for drawTiles
	 * @param  rect      Rectangle to set for width/height
	 */
	public function new(parent:AtlasData, tileIndex:Int, rect:Rectangle)
	{
		this.parent = parent;
		this.tileIndex = tileIndex;
		this.rect = rect.clone();
		this.rotated = false;
	}

	/**
	 * Clips an atlas region
	 * @param	clipRect	A clip rectangle with coordinates local to the region
	 * @param	center		The new center point
	 * @return	A new atlas region with the clipped coordinates
	 */
	public function clip(clipRect:Rectangle, ?center:Point):AtlasRegion
	{
		// only clip within the current region
		if (clipRect.x + clipRect.width > rect.width)
			clipRect.width = rect.width - clipRect.x;
		if (clipRect.y + clipRect.height > rect.height)
			clipRect.height = rect.height - clipRect.y;

		// do not allow negative width/height
		if (clipRect.width < 0) clipRect.width = 0;
		if (clipRect.height < 0) clipRect.height = 0;

		// position clip rect where the last image was
		clipRect.x += rect.x;
		clipRect.y += rect.y;
		return parent.createRegion(clipRect, center);
	}

	/**
	 * Prepares tile data for rendering
	 * @param	x		The x-axis location to draw the tile
	 * @param	y		The y-axis location to draw the tile
	 * @param	layer	The layer to draw on
	 * @param	scaleX	The scale value for the x-axis
	 * @param	scaleY	The scale value for the y-axis
	 * @param	angle	An angle to rotate the tile in degrees
	 * @param	red		A red tint value
	 * @param	green	A green tint value
	 * @param	blue	A blue tint value
	 * @param	alpha	The tile's opacity
	 */
	public inline function draw(x:Float, y:Float, layer:Int,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1)
	{
		if (rotated) angle = angle + 90;
		parent.prepareTile(tileIndex, x, y, layer, scaleX, scaleY, angle, red, green, blue, alpha);
	}

	/**
	 * Prepares tile data for rendering using a matrix
	 * @param  tx    X-Axis translation
	 * @param  ty    Y-Axis translation
	 * @param  a     Top-left
	 * @param  b     Top-right
	 * @param  c     Bottom-left
	 * @param  d     Bottom-right
	 * @param  layer The layer to draw on
	 * @param  red   Red color value
	 * @param  green Green color value
	 * @param  blue  Blue color value
	 * @param  alpha Alpha value
	 */
	public inline function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		layer:Int, red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1)
	{
		if (rotated)
		{
			var matrix = new Matrix(a, b, c, d, tx, ty);
			matrix.rotate(90 * HXP.RAD);
			parent.prepareTileMatrix(tileIndex, layer,
				matrix.tx, matrix.ty, matrix.a, matrix.b, matrix.c, matrix.d,
				red, green, blue, alpha);
		}
		else
		{
			parent.prepareTileMatrix(tileIndex, layer, tx, ty, a, b, c, d, red, green, blue, alpha);
		}
	}

	public function destroy():Void
	{
		if (parent != null)
		{
			parent.destroy();
			parent = null;
		}
	}

	/**
	 * Prints the region as a string
	 *
	 * @return	String version of the object.
	 */
	public function toString():String
	{
		return "[AtlasRegion " + width + ", " + height + " " + tileIndex + "]";
	}

	private inline function get_width():Float { return rect.width; }
	private inline function get_height():Float { return rect.height; }

	private var rect:Rectangle;
	private var center:Point;
	private var parent:AtlasData;
}
