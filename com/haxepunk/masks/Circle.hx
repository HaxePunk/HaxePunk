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
		var distanceX = Math.abs(parent.x + _x - other.parent.x - other.parent.width * 0.5),
			distanceY = Math.abs(parent.y + _y - other.parent.y - other.parent.height * 0.5);

		if (distanceX > other.parent.width * 0.5 + radius
			|| distanceY > other.parent.height * 0.5 + radius)
		{
			return false;//The hitbox is to far away so return false
		}
		if (distanceX <= other.parent.width * 0.5|| distanceY <= other.parent.height * 0.5)
		{
			return true;
		}
		var distanceToCorner = (distanceX - other.parent.width * 0.5) * (distanceX - other.parent.width * 0.5)
			+ (distanceY - other.parent.height * 0.5) * (distanceY - other.parent.height * 0.5);

		return distanceToCorner <= _squaredRadius;
	}

	private function collideCircle(other:Circle):Bool
	{
		var dx:Float = (parent.x + _x) - (other.parent.x + other._x);
		var dy:Float = (parent.y + _y) - (other.parent.y + other._y);
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
		var thisX:Float = _x, thisY:Float = _y;
		if (parent != null)
		{
			thisX += parent.x;
			thisY += parent.y;
		}

		var otherX:Float = other.x, otherY:Float = other.y;
		if (other.parent != null)
		{
			otherX += other.parent.x;
			otherY += other.parent.y;
		}

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
		var thisX:Float = _x, thisY:Float = _y;
		if (parent != null)
		{
			thisX += parent.x;
			thisY += parent.y;
		}

		var otherX:Float = other.x, otherY:Float = other.y;
		if (other.parent != null)
		{
			otherX += other.parent.x;
			otherY += other.parent.y;
		}

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
					// find points on the line
					var x:Float = 0, y:Float = 0;
					var normal = -1 / tile.slope;
					var len = Math.sqrt(normal * normal + 1); // slope length (0, 0) to (1, normal)

					// set direction and length of collision vector
					if (tile.slope != 0)
					{
						if (tile.type == AboveSlope)
						{
							x = (tile.slope < 0 ? -radius : radius);
							y = -radius;
						}
						else
						{
							x = (tile.slope < 0 ? radius : -radius);
							y = radius;
						}
					}

					// clamp point to tile boundaries to prevent "ghost" collisions
					x = HXP.clamp(thisX + (x * Math.abs(1 / len)), dx, dx + other.tileWidth);
					y = HXP.clamp(thisY + (y * Math.abs(normal / len)), dy, dy + other.tileHeight);

					// attempt to collide with the slope
					if (other.collidePoint(x, y))
					{
						return true;
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

		var distanceX:Float = Math.abs(parent.x + _x - other.parent.x - other._x - _otherHalfWidth),
			distanceY:Float = Math.abs(parent.y + _y - other.parent.y - other._y - _otherHalfHeight);

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
		graphics.drawCircle((parent.x + _x - HXP.camera.x) * scaleX, (parent.y + _y - HXP.camera.y) * scaleY, radius * scaleX);
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
			parent.originX = -_x + radius;
			parent.originY = -_y + radius;
			parent.height = parent.width = radius + radius;

			// update parent list
			if (list != null)
				list.update();
		}
	}

	// Hitbox information.
	private var _radius:Int;
	private var _squaredRadius:Int; //Set automatically through the setter for radius
}
