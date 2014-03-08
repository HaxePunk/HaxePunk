package com.haxepunk.masks;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.SlopedGrid;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import flash.display.Graphics;
import flash.geom.Point;

/**
 * Uses circular area to determine collision.
 */

class Circle extends Hitbox
{
	/**
	 * Constructor.
	 * @param	radius		Radius of the circle.
	 * @param	x			X offset of the circle.
	 * @param	y			Y offset of the circle.
	 */
	public function new(radius:Int = 1, x:Int = 0, y:Int = 0)
	{
		super();
		this.radius = radius;
		_x = x + radius;
		_y = y + radius;

		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Circle), collideCircle);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Grid), collideGrid);
		_check.set(Type.getClassName(SlopedGrid), collideSlopedGrid);
	}

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		var distanceX = Math.abs(_parent.x + _x - other._parent.x - other._parent.width * 0.5),
			distanceY = Math.abs(_parent.y + _y - other._parent.y - other._parent.height * 0.5);

		if (distanceX > other._parent.width * 0.5 + radius
			|| distanceY > other._parent.height * 0.5 + radius)
		{
			return false;//The hitbox is to far away so return false
		}
		if (distanceX <= other._parent.width * 0.5|| distanceY <= other._parent.height * 0.5)
		{
			return true;
		}
		var distanceToCorner = (distanceX - other._parent.width * 0.5) * (distanceX - other._parent.width * 0.5)
			+ (distanceY - other._parent.height * 0.5) * (distanceY - other._parent.height * 0.5);

		return distanceToCorner <= _squaredRadius;
	}

	private function collideCircle(other:Circle):Bool
	{
		var dx:Float = (_parent.x + _x) - (other._parent.x + other._x);
		var dy:Float = (_parent.y + _y) - (other._parent.y + other._y);
		return (dx * dx + dy * dy) < Math.pow(_radius + other._radius, 2);
	}

	private inline function collideGridTile(mx:Float, my:Float, hTileWidth:Float, hTileHeight:Float, thisX:Float, thisY:Float)
	{
		var collide = false;
		var dx = Math.abs(thisX - mx);

		if (dx <= hTileWidth + radius)
		{
			var dy = Math.abs(thisY - my);

			if (dy <= hTileHeight + radius)
			{
				if (dx <= hTileWidth || dy <= hTileHeight)
				{
					collide = true;
				}
				else
				{
					var xCornerDist = dx - hTileWidth;
					var yCornerDist = dy - hTileHeight;

					if (xCornerDist * xCornerDist + yCornerDist * yCornerDist <= _squaredRadius)
						collide = true;
				}
			}
		}
		return collide;
	}

	private function collideGrid(other:Grid):Bool
	{
		var thisX:Float = _x + _parent.x,
			thisY:Float = _y + _parent.y;

		var otherX:Float = other.x + other._parent.x,
			otherY:Float = other.y + other._parent.y;

		var entityDistX:Float = thisX - otherX, entityDistY:Float = thisY - otherY;

		var minx:Int = Math.floor((entityDistX - radius) / other.tileWidth),
			miny:Int = Math.floor((entityDistY - radius) / other.tileHeight),
			maxx:Int = Math.ceil((entityDistX + radius) / other.tileWidth),
			maxy:Int = Math.ceil((entityDistY + radius) / other.tileHeight);

		if (minx < 0) minx = 0;
		if (miny < 0) miny = 0;
		if (maxx > other.columns) maxx = other.columns;
		if (maxy > other.rows)    maxy = other.rows;

		var hTileWidth = other.tileWidth * 0.5,
			hTileHeight = other.tileHeight * 0.5;

		var dx, dy = otherY + miny * other.tileHeight;
		for (yy in miny...maxy)
		{
			dx = otherX + minx * other.tileWidth;
			for (xx in minx...maxx)
			{
				if (other.getTile(xx, yy))
				{
					if (collideGridTile(dx + hTileWidth, dy + hTileHeight,
							hTileWidth, hTileHeight, thisX, thisY))
						return true;
				}
				dx += other.tileWidth;
			}
			dy += other.tileHeight;
		}

		return false;
	}

	private function collideSlopedGrid(other:SlopedGrid):Bool
	{
		var thisX:Float = _x + _parent.x,
			thisY:Float = _y + _parent.y;

		var otherX:Float = other.x + other._parent.x,
			otherY:Float = other.y + other._parent.y;

		var entityDistX:Float = thisX - otherX, entityDistY:Float = thisY - otherY;

		var minx:Int = Math.floor((entityDistX - radius) / other.tileWidth),
			miny:Int = Math.floor((entityDistY - radius) / other.tileHeight),
			maxx:Int = Math.ceil((entityDistX + radius) / other.tileWidth),
			maxy:Int = Math.ceil((entityDistY + radius) / other.tileHeight);

		if (minx < 0) minx = 0;
		if (miny < 0) miny = 0;
		if (maxx > other.columns) maxx = other.columns;
		if (maxy > other.rows)    maxy = other.rows;

		var hTileWidth = other.tileWidth * 0.5,
			hTileHeight = other.tileHeight * 0.5;

		var dx, dy = otherY + miny * other.tileHeight;
		for (yy in miny...maxy)
		{
			dx = otherX + minx * other.tileWidth;
			for (xx in minx...maxx)
			{
				var tile = other.getTile(xx, yy);
				if (tile.type == Solid)
				{
					if (collideGridTile(dx + hTileWidth, dy + hTileHeight,
							hTileWidth, hTileHeight, thisX, thisY))
						return true;
				}
				else if (tile.type == AboveSlope || tile.type == BelowSlope)
				{
					// test if center of circle is inside slope
					if (other.collidePointInSlope(dx, dy, thisX, thisY, tile))
					{
						return true;
					}

					// attempt to collide with the slope
					// Adapted from http://stackoverflow.com/questions/1073336/circle-line-collision-detection
					var x1 = dx, y1 = dy + tile.yOffset;
					var yoff = tile.slope * other.tileWidth;
					var x2 = x1 + yoff / tile.slope,
						y2 = y1 + yoff;

					var dx = x2 - x1, dy = y2 - y1, // direction vector of line
						fx = x1 - thisX, fy = y1 - thisY; // vector from center to line start

					var a = dx * dx + dy * dy;
					var b = (fx * dx + fy * dy) * 2;
					var c = (fx * fx + fy * fy) - (radius * radius);
					var discriminant = b * b - 4 * a * c;
					if (discriminant >= 0)
					{
						discriminant = Math.sqrt(discriminant);
						var t1 = (-b - discriminant) / (2 * a);
						var t2 = (-b + discriminant) / (2 * a);

						if ((t1 >= 0 && t1 <= 1) || // Impale, Poke
							(t2 >= 0 && t2 <= 1) || // ExitWound
							(t1 < 0 && t2 > 1)) // CompletelyInside
						{
							return true;
						}
					}
				}
				dx += other.tileWidth;
			}
			dy += other.tileHeight;
		}
		return false;
	}

	/** @private Collides against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		var _otherHalfWidth:Float = other._width * 0.5;
		var _otherHalfHeight:Float = other._height * 0.5;

		var px:Float = _x + _parent.x,
			py:Float = _y + _parent.y;

		var ox:Float = other._x, oy:Float = other._y;
		if (other.parent != null)
		{
			ox += other.parent.x;
			oy += other.parent.y;
		}

		var distanceX:Float = Math.abs(px - ox - _otherHalfWidth),
			distanceY:Float = Math.abs(py - oy - _otherHalfHeight);

		if (distanceX > _otherHalfWidth + radius || distanceY > _otherHalfHeight + radius)
		{
			return false;	// the hitbox is too far away so return false
		}
		if (distanceX <= _otherHalfWidth || distanceY <= _otherHalfHeight)
		{
			return true;
		}
		var distanceToCorner:Float = (distanceX - _otherHalfWidth) * (distanceX - _otherHalfWidth)
			+ (distanceY - _otherHalfHeight) * (distanceY - _otherHalfHeight);

		return distanceToCorner <= _squaredRadius;
	}

	override public function project(axis:Vector, projection:Projection):Void
	{
		projection.min = -_radius;
		projection.max = _radius;
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		graphics.drawCircle((_parent.x + _x - HXP.camera.x) * scaleX, (_parent.y + _y - HXP.camera.y) * scaleY, radius * scaleX);
	}

	override private function get_x():Int { return _x - _radius; }
	override private function get_y():Int { return _y - _radius; }

	/**
	 * Radius.
	 */
	public var radius(get, set):Int;
	private inline function get_radius():Int { return _radius; }
	private function set_radius(value:Int):Int
	{
		if (_radius == value) return value;
		_radius = value;
		_squaredRadius = value * value;
		height = width = _radius + _radius;
		if (list != null) list.update();
		else if (parent != null) update();
		return _radius;
	}

	/** Updates the parent's bounds for this mask. */
	override public function update()
	{
		if (parent != null)
		{
			//update entity bounds
			_parent.originX = -_x + radius;
			_parent.originY = -_y + radius;
			_parent.height = _parent.width = radius + radius;

			// update parent list
			if (list != null)
				list.update();
		}
	}

	// Hitbox information.
	private var _radius:Int;
	private var _squaredRadius:Int; //Set automatically through the setter for radius
}
