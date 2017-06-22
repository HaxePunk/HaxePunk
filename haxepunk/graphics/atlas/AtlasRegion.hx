package haxepunk.graphics.atlas;

import haxepunk.utils.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import haxepunk.utils.Color;
import haxepunk.utils.MathUtil;
import haxepunk.graphics.shader.Shader;

class AtlasRegion implements IAtlasRegion
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
	public var width(get, never):Int;
	/**
	 * Height of this region
	 */
	public var height(get, never):Int;

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
	 * @param	x			The x-axis location to draw the tile
	 * @param	y			The y-axis location to draw the tile
	 * @param	shader		The shader to use for drawing
	 * @param	scaleX		The scale value for the x-axis
	 * @param	scaleY		The scale value for the y-axis
	 * @param	angle		An angle to rotate the tile in degrees
	 * @param	red			A red tint value
	 * @param	green		A green tint value
	 * @param	blue		A blue tint value
	 * @param	alpha		The tile's opacity
	 * @param	smooth		Whether to draw with antialiasing
	 * @param	blend		Blend mode
	 * @param	clipRect	Clipping rectangle
	 */
	public inline function draw(x:Float, y:Float,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		if (rotated) angle = angle + 90;

		_parent.prepareTile(_rect, x, y,
			scaleX, scaleY, angle,
			color, alpha,
			shader, smooth, blend, clipRect);
	}

	/**
	 * Prepares tile data for rendering using a matrix
	 * @param	tx			X-Axis translation
	 * @param	ty			Y-Axis translation
	 * @param	a			Top-left
	 * @param	b			Top-right
	 * @param	c			Bottom-left
	 * @param	d			Bottom-right
	 * @param	shader		The shader to use for drawing
	 * @param	red			Red color value
	 * @param	green		Green color value
	 * @param	blue		Blue color value
	 * @param	alpha		The tile's opacity
	 * @param	smooth		Whether to draw with antialiasing
	 * @param	blend		Blend mode
	 * @param	clipRect	Clipping rectangle
	 */
	public inline function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle):Void
	{
		if (rotated)
		{
			var matrix = new Matrix(a, b, c, d, tx, ty);
			matrix.rotate(90 * MathUtil.RAD);
			_parent.prepareTileMatrix(_rect,
				matrix.tx, matrix.ty, matrix.a, matrix.b, matrix.c, matrix.d,
				color, alpha,
				shader, smooth, blend, clipRect
			);
		}
		else
		{
			_parent.prepareTileMatrix(_rect,
				tx, ty, a, b, c, d,
				color, alpha,
				shader, smooth, blend, clipRect
			);
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
	public inline function toString():String
	{
		return "[AtlasRegion " + _rect + "]";
	}

	inline function get_x():Float return _rect.x;
	inline function get_y():Float return _rect.y;
	inline function get_width():Int return Std.int(_rect.width);
	inline function get_height():Int return Std.int(_rect.height);

	var _rect:Rectangle;
	var _parent:AtlasData;
}
