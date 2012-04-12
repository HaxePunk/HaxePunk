package com.haxepunk.masks;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.haxepunk.masks.Grid;
import flash.display.Graphics;
import flash.geom.Point;

/**
 * Uses circular area to determine collision.
 */

class Circle extends Mask
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

		var midx:Int = Math.floor((maxx + minx) / 2),
			midy:Int = Math.floor((maxy + miny) / 2),
			dx:Float, dy:Float;

		for (xx in minx...maxx)
		{
			for (yy in miny...maxy)
			{
				if (other.getTile(xx, yy))
				{
					if (xx <= midx)
					{
						if (yy <= midy) //Lower right
						{
							dx = entityDistX - (xx + 1) * other.tileWidth;
							dy = entityDistX - (yy + 1) * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
						else //Upper right
						{
							dx = entityDistX - (xx + 1) * other.tileWidth;
							dy = entityDistX - yy * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
					}
					else
					{
						if (yy <= midy) //Lower left
						{
							dx = entityDistX - xx * other.tileWidth;
							dy = entityDistX - (yy + 1) * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
						else //Upper left
						{
							dx = entityDistX - xx * other.tileWidth;
							dy = entityDistX - yy * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
					}
					return true;
				}
			}
		}
		return false;
	}

	/** @private Collides against a Hitbox. */
	private function collideHitbox(other:Hitbox):Bool
	{
		var dx = Math.abs(parent.x + _x - other.parent.x + other.x),
			dy = Math.abs(parent.y + _y - other.parent.y + other.y);

		if (dx <= other.width || dy <= other.height)
		{
			return true;
		}
		if (dx > other.width + radius || dy > other.height + radius)
		{
			return false; //The hitbox is to far away so return false
		}

		return (dx * dx + dy * dy) <= _squaredRadius;
	}

	public inline function projectOn(axis:Point, collisionInfo:CollisionInfo):Void
	{
		collisionInfo.min = -_radius;
		collisionInfo.max = _radius;
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		graphics.drawCircle((parent.x + _x - HXP.camera.x) * scaleX, (parent.y + _y - HXP.camera.y) * scaleY, radius * scaleX);
	}

	/**
	 * X offset.
	 */
	public var x(getX, setX):Int;
	private inline function getX():Int { return _x; }
	private function setX(value:Int):Int
	{
		if (_x == value) return value;
		_x = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _x;
	}

	/**
	 * Y offset.
	 */
	public var y(getY, setY):Int;
	private inline function getY():Int { return _y; }
	private function setY(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _y;
	}

	/**
	 * Radius.
	 */
	public var radius(getRadius, setRadius):Int;
	private inline function getRadius():Int { return _radius; }
	private function setRadius(value:Int):Int
	{
		if (_radius == value) return value;
		_radius = value;
		_squaredRadius = value * value;
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
			parent.width = radius + radius;
			parent.height = parent.width;

			// update parent list
			if (list != null)
				list.update();
		}
	}

	// Hitbox information.
	private var _x:Int;
	private var _y:Int;
	private var _radius:Int;
	private var _squaredRadius:Int; //Set automatically through the setter for radius
}