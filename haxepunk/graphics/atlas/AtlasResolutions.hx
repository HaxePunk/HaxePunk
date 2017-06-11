package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Point;
import haxepunk.graphics.shader.Shader;
import haxepunk.utils.Color;

/**
 * This class manages multiple AtlasRegions containing the same image at
 * different resolutions. At render time, it will use the smallest region that
 * is larger than the specified scale (or the largest region otherwise.)
 */
class AtlasResolutions implements IAtlasRegion
{
	public var width(get, never):Int;
	inline function get_width() return base.width;

	public var height(get, never):Int;
	inline function get_height() return base.height;

	var base:AtlasRegion;
	var regions:Array<AtlasRegion> = new Array();

	/**
	 * Creates a new AtlasResolutions
	 * @param  regions   An array of AtlasRegions
	 */
	public function new(regions:Array<AtlasRegion>)
	{
		if (regions == null || regions.length == 0)
		{
			throw "Can't create an AtlasResolutions set with no AtlasRegions";
		}
		for (region in regions) addResolution(region);
	}

	public function addResolution(region:AtlasRegion)
	{
		if (regions.length == 0)
		{
			this.base = region;
			regions.push(region);
		}
		else
		{
			if (Math.abs(region.width / region.height - base.width / base.height) > 0.001)
			{
				throw 'All AtlasRegions in an AtlasResolutions set must have the same aspect ratio: $base $region';
			}
			for (i in 0 ... regions.length + 1)
			{
				if (i == regions.length || regions[i].width > region.width)
				{
					regions.insert(i, region);
					break;
				}
			}
		}
	}

	/**
	 * Prepares tile data for rendering
	 * @param	x			The x-axis location to draw the tile
	 * @param	y			The y-axis location to draw the tile
	 * @param	layer		The layer to draw on
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
	public inline function draw(x:Float, y:Float, layer:Int,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		var region = regionForScale(Math.max(Math.abs(scaleX), Math.abs(scaleY)));
		var scale:Float = base.width / region.width;
		region.draw(x, y, layer,
			scaleX * scale, scaleY * scale, angle,
			color, alpha,
			shader, smooth, blend, clipRect
		);
	}

	/**
	 * Prepares tile data for rendering using a matrix
	 * @param	tx			X-Axis translation
	 * @param	ty			Y-Axis translation
	 * @param	a			Top-left
	 * @param	b			Top-right
	 * @param	c			Bottom-left
	 * @param	d			Bottom-right
	 * @param	layer		The layer to draw on
	 * @param	red			Red color value
	 * @param	green		Green color value
	 * @param	blue		Blue color value
	 * @param	alpha		The tile's opacity
	 * @param	smooth		Whether to draw with antialiasing
	 * @param	blend		Blend mode
	 * @param	clipRect	Clipping rectangle
	 */
	public inline function drawMatrix(tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		layer:Int, color:Color=Color.White, alpha:Float=1,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		var region = regionForScale(Math.max(Math.abs(a * c), Math.abs(b * d)));
		var scale:Float = base.width / region.width;
		region.drawMatrix(tx * scale, ty * scale, a * scale, b * scale, c * scale, d * scale, layer,
			color, alpha,
			shader, smooth, blend, clipRect
		);
	}

	public function clip(clipRect:Rectangle, ?center:Point):IAtlasRegion
	{
		var clippedRegions:Array<AtlasRegion> = new Array();
		clippedRegions.push(base.clip(clipRect, center));
		for (region in regions)
		{
			if (region == base) continue;
			var scale = region.width / base.width;
			_rect.setTo(clipRect.x * scale, clipRect.y * scale, clipRect.width * scale, clipRect.height * scale);
			if (center != null) _point.setTo(center.x * scale, center.y * scale);
			clippedRegions.push(region.clip(_rect, center == null ? null : _point));
		}
		return new AtlasResolutions(clippedRegions);
	}

	public function destroy():Void
	{
		for (region in regions) region.destroy();
	}

	/**
	 * Prints the region as a string
	 *
	 * @return	String version of the object.
	 */
	public inline function toString():String
	{
		return "[AtlasResolutions for " + base.toString() + " x " + regions.length + " resolutions]";
	}

	/**
	 * Find the best AtlasRegion to draw at a specific scale.
	 */
	inline function regionForScale(currentScale:Float):AtlasRegion
	{
		var best:AtlasRegion = base;
		for (region in regions)
		{
			best = region;
			var scale = region.width / base.width;
			if (scale > currentScale) break;
		}
		return best;
	}

	static var _rect:Rectangle = new Rectangle();
	static var _point:Point = new Point();
}
