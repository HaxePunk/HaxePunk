package com.haxepunk.graphics.atlas;

import nme.geom.Rectangle;
import nme.geom.Point;

class AtlasRegion
{

	public var rotated:Bool;
	public var tileIndex(default, null):Int;
	public var width(get_width, never):Float;
	public var height(get_height, never):Float;

	public function new(parent:AtlasData, tileIndex:Int, rect:Rectangle, ?center:Point)
	{
		this._parent = parent;
		this.tileIndex = tileIndex;
		this._rect = rect.clone();
		this.rotated = false;
		this._center = center != null ? center : new Point();
	}

	/**
	 * Clips an atlas region
	 * @param clipRect a clip rectangle with coordinates local to the region
	 * @param center the new center point
	 * @return a new atlas region with the clipped coordinates
	 */
	public function clip(clipRect:Rectangle, ?center:Point):AtlasRegion
	{
		if (_parent == null) return this;
		// only clip within the current region
		if (clipRect.x + clipRect.width > _rect.width)
			clipRect.width = _rect.width - clipRect.x;
		if (clipRect.y + clipRect.height > _rect.height)
			clipRect.height = _rect.height - clipRect.y;

		// do not allow negative width/height
		if (clipRect.width < 0) clipRect.width = 0;
		if (clipRect.height < 0) clipRect.height = 0;

		// position clip rect where the last image was
		clipRect.x += _rect.x;
		clipRect.y += _rect.y;
		return _parent.createRegion(clipRect, center);
	}

	/**
	 * Prepares tile data for rendering
	 * @param x the x-axis location to draw the tile
	 * @param y the y-axis location to draw the tile
	 * @param scaleX the scale value for the x-axis
	 * @param scaleY the scale value for the y-axis
	 * @param angle an angle to rotate the tile in degrees
	 * @param red a red tint value
	 * @param green a green tint value
	 * @param blue a blue tint value
	 * @param alpha the tile's opacity
	 */
	public inline function draw(x:Float, y:Float, layer:Int,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1)
	{
		if (_parent != null)
		{
			if (rotated) angle = angle + 90;
			_parent.prepareTile(tileIndex, x, y, layer, scaleX, scaleY, angle, red, green, blue, alpha);
		}
	}

	public function toString():String
	{
		return "[AtlasRegion " + width + ", " + height + " " + tileIndex + "]";
	}

	private inline function get_width():Float { return _rect.width; }
	private inline function get_height():Float { return _rect.height; }

	private var _rect:Rectangle;
	private var _center:Point;
	private var _parent:AtlasData;
}
