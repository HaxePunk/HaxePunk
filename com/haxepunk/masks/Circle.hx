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

	private function collideGrid(other:Grid):Bool
	{
		var thisX:Float = parent.x + _x,
			thisY:Float = parent.y + _y,
			otherX:Float = other.parent.x + other.x,
			otherY:Float = other.parent.y + other.y,
			entityDistX:Float = thisX - otherX,
			entityDistY:Float = thisY - otherY;

		var minx:Int = Math.floor((entityDistX - radius) / other.tileWidth),
			miny:Int = Math.floor((entityDistY - radius) / other.tileHeight),
			maxx:Int = Math.ceil((entityDistX + radius) / other.tileWidth),
			maxy:Int = Math.ceil((entityDistY + radius) / other.tileHeight);

		if (minx < 0) minx = 0;
		if (miny < 0) miny = 0;
		if (maxx > other.columns) maxx = other.columns;
		if (maxy > other.rows)    maxy = other.rows;

		var hTileWidth = other.tileWidth * 0.5,
			hTileHeight = other.tileHeight * 0.5,
			dx:Float, dy:Float;

		for (xx in minx...maxx)
		{
			for (yy in miny...maxy)
			{
				if (other.getTile(xx, yy))
				{
					var mx = otherX + xx*other.tileWidth + hTileWidth,
						my = otherY + yy*other.tileHeight + hTileHeight;

					var dx = Math.abs(thisX - mx);

					if (dx > hTileWidth + radius)
						continue;

					var dy = Math.abs(thisY - my);

					if (dy > hTileHeight + radius)
						continue;

					if (dx <= hTileWidth || dy <= hTileHeight)
						return true;

					var xCornerDist = dx - hTileWidth;
					var yCornerDist = dy - hTileHeight;

					if (xCornerDist * xCornerDist + yCornerDist * yCornerDist <= _squaredRadius)
						return true;
				}
			}
		}

		return false;
	}

	private function collideSlopedGrid(other:SlopedGrid):Bool
	{
		var thisX:Float = parent.x + _x,
			thisY:Float = parent.y + _y,
			otherX:Float = other.parent.x + other.x,
			otherY:Float = other.parent.y + other.y,
			entityDistX:Float = thisX - otherX,
			entityDistY:Float = thisY - otherY;

		var minx:Int = Math.floor((entityDistX - radius) / other.tileWidth),
			miny:Int = Math.floor((entityDistY - radius) / other.tileHeight),
			maxx:Int = Math.ceil((entityDistX + radius) / other.tileWidth),
			maxy:Int = Math.ceil((entityDistY + radius) / other.tileHeight);

		if (minx < 0) minx = 0;
		if (miny < 0) miny = 0;
		if (maxx > other.columns) maxx = other.columns;
		if (maxy > other.rows)    maxy = other.rows;

		var hTileWidth = other.tileWidth * 0.5,
			hTileHeight = other.tileHeight * 0.5,
			dx:Float, dy:Float;

		for (xx in minx...maxx)
		{
			for (yy in miny...maxy)
			{
				var tile = other.getTile(xx, yy);
				if (tile == null || tile.type == null) continue;
				if (tile.type == Solid)
				{
					var mx = otherX + xx*other.tileWidth + hTileWidth,
						my = otherY + yy*other.tileHeight + hTileHeight;

					var dx = Math.abs(thisX - mx);

					if (dx > hTileWidth + radius)
						continue;

					var dy = Math.abs(thisY - my);

					if (dy > hTileHeight + radius)
						continue;

					if (dx <= hTileWidth || dy <= hTileHeight)
						return true;

					var xCornerDist = dx - hTileWidth;
					var yCornerDist = dy - hTileHeight;

					if (xCornerDist * xCornerDist + yCornerDist * yCornerDist <= _squaredRadius)
						return true;
				}
				else if (tile.type == AboveSlope || tile.type == BelowSlope)
				{
					var normal = -1 / tile.slope;
					var dx = -(otherX + xx*other.tileWidth - thisX);
					var dy = -(otherY + yy*other.tileHeight - thisY);
					var b = -(normal * dx - dy);
					var x = Math.abs((b - tile.yOffset) / (normal - tile.slope));
					var y = x * normal + b;

					var dist = HXP.distance(dx, dy, x, y);
					if (dist <= radius) return true;
				}
			}
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
