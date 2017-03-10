package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import haxepunk.utils.MathUtil;

class AtlasRegion
{
	/**
	 * If the region is rotated by 90 degress (used for sprite packing)
	 */
	public var rotated:Bool;

	public var x(get, never):Float;
	public var y(get, never):Float;
	/**
	 * Width of this region
	 */
	public var width(get, never):Float;
	/**
	 * Height of this region
	 */
	public var height(get, never):Float;

	/**
	 * Creates a new AtlasRegion
	 * @param  parent    The AtlasData parent to use for rendering
	 * @param  rect      Rectangle to set for width/height
	 */
	public function new(parent:AtlasData, rect:Rectangle)
	{
		this._parent = parent;
		this._rect = rect;
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
		// make a copy of clipRect, to avoid modifying the original
		var clipRectCopy = clipRect.clone();

		// only clip within the current region
		if (clipRectCopy.x + clipRectCopy.width > _rect.width)
			clipRectCopy.width = _rect.width - clipRectCopy.x;
		if (clipRectCopy.y + clipRectCopy.height > _rect.height)
			clipRectCopy.height = _rect.height - clipRectCopy.y;

		// do not allow negative width/height
		if (clipRectCopy.width < 0) clipRectCopy.width = 0;
		if (clipRectCopy.height < 0) clipRectCopy.height = 0;

		// position clip rect where the last image was
		clipRectCopy.x += _rect.x;
		clipRectCopy.y += _rect.y;
		return _parent.createRegion(clipRectCopy, center);
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
	 * @param	smooth	Whther to draw with antialiasing
	 * @param	blend	Blend mode
	 */
	public inline function draw(x:Float, y:Float, layer:Int,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1,
		?smooth:Bool, ?blend:BlendMode)
	{
		if (smooth == null) smooth = Atlas.smooth;
		if (rotated) angle = angle + 90;

		_parent.prepareTile(_rect, x, y, layer, scaleX, scaleY, angle, red, green, blue, alpha, smooth, blend);
	}

	/**
	 * Prepares tile data for rendering using a matrix
	 * @param	tx		X-Axis translation
	 * @param	ty		Y-Axis translation
	 * @param	a		Top-left
	 * @param	b		Top-right
	 * @param	c		Bottom-left
	 * @param	d		Bottom-right
	 * @param	layer	The layer to draw on
	 * @param	red		Red color value
	 * @param	green	Green color value
	 * @param	blue	Blue color value
	 * @param	alpha	The tile's opacity
	 * @param	smooth	Whther to draw with antialiasing
	 * @param	blend	Blend mode
	 */
	public inline function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		layer:Int, red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1,
		?smooth:Bool, ?blend:BlendMode)
	{
		if (smooth == null) smooth = Atlas.smooth;

		if (rotated)
		{
			var matrix = new Matrix(a, b, c, d, tx, ty);
			matrix.rotate(90 * MathUtil.RAD);
			_parent.prepareTileMatrix(_rect, layer,
				matrix.tx, matrix.ty, matrix.a, matrix.b, matrix.c, matrix.d,
				red, green, blue, alpha, smooth, blend);
		}
		else
		{
			_parent.prepareTileMatrix(_rect, layer, tx, ty, a, b, c, d, red, green, blue, alpha, smooth, blend);
		}
	}

	public function destroy():Void
	{
		if (_parent != null)
		{
			_parent.destroy();
			_parent = null;
		}
	}

	/**
	 * Prints the region as a string
	 *
	 * @return	String version of the object.
	 */
	public function toString():String
	{
		return "[AtlasRegion " + _rect + "]";
	}

	inline function get_x():Float return _rect.x;
	inline function get_y():Float return _rect.y;
	inline function get_width():Float return _rect.width;
	inline function get_height():Float return _rect.height;

	var _rect:Rectangle;
	var _parent:AtlasData;
}
