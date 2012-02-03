package com.haxepunk.masks;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.haxepunk.masks.Grid;
import flash.display.Graphics;
import flash.geom.Point;

/**
 * Uses circular area to determine collision.
 */

 using Std;

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
		_radius = radius;
		_x = x;
		_y = y;
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Circle), collideCircle);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}
	
	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		return parent.x + _x + _radius > other.parent.x - other.parent.originX
			&& parent.y + _y + _radius > other.parent.y - other.parent.originY
			&& parent.x + _x < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y + _y < other.parent.y - other.parent.originY + other.parent.height;
	}
	
	private function collideCircle(other:Circle):Bool 
	{
		var dx = parent.x + _x + _radius - other.parent.x - other._x - other._radius;
		var dy = parent.y + _y + _radius - other.parent.y - other._y - other._radius;
		return dx * dx + dy * dy < _radius + other._radius;
	}
	
	private function collideGrid(other:Grid):Bool 
	{
		var minx = Math.floor((parent.x - radius - other.x) / other.tileWidth);
		var miny = Math.floor((parent.y - radius - other.y) / other.tileHeight);
		var maxx = Math.ceil((parent.x + radius - other.x) / other.tileWidth);
		var maxy = Math.ceil((parent.y + radius - other.x) / other.tileHeight);
		
		var midx = Math.floor((maxx + minx)/2);
		var midy = Math.floor((maxy + miny)/2);
		
		var entityDistX = parent.x - other.x;
		var entityDistY = parent.y - other.y;
		
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
							var dx = entityDistX - (xx + 1) * other.tileWidth;
							var dy = entityDistX - (yy + 1) * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
						else //Upper right
						{
							var dx = entityDistX - (xx + 1) * other.tileWidth;
							var dy = entityDistX - yy * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
					}
					else 
					{
						if (yy <= midy) //Lower left
						{
							var dx = entityDistX - xx * other.tileWidth;
							var dy = entityDistX - (yy + 1) * other.tileHeight;
							if (dx * dx + dy * dy < _squaredRadius)
								return true;
						}
						else //Upper left
						{
							var dx = entityDistX - xx * other.tileWidth;
							var dy = entityDistX - yy * other.tileHeight;
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
		return parent.x + _x + _radius > other.parent.x + other.x
			&& parent.y + _y + _radius > other.parent.y + other.y
			&& parent.x + _x < other.parent.x + other.x + other.width
			&& parent.y + _y < other.parent.y + other.y + other.height;
	}
	
	public inline function projectOn(axis:Point, collisionInfo:CollisionInfo):Void 
	{
		collisionInfo.min = -_radius;
		collisionInfo.max = _radius;
	}
	
	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void 
	{
		graphics.drawCircle((parent.x + _x) * scaleX, (parent.y + _y) * scaleY, radius * scaleX);
	}
	
	/**
	 * X offset.
	 */
	public var x(getX, setX):Int;
	inline private function getX():Int { return _x; }
	private function setX(value:Int):Int
	{
		if (_x == value) return value;
		_x = value;
		if (list != null) update();
		else if (parent != null) update();	
		return _x;
	}
	
	/**
	 * Y offset.
	 */
	public var y(getY, setY):Int;
	inline private function getY():Int { return _y; }
	private function setY(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (list != null) update();
		else if (parent != null) update();		
		return _y;
	}
	
	/**
	 * Radius.
	 */
	public var radius(getRadius, setRadius):Float;
	inline private function getRadius():Float { return _radius; }
	private function setRadius(value:Float):Float
	{
		if (_radius == value) return value;
		_radius = value;
		_squaredRadius = value * value;
		if (list != null) update();
		else if (parent != null) update();	
		return _radius;
	}
	
	/** Updates the parent's bounds for this mask. */
	override public function update() 
	{
		//update entity bounds
		parent.originX = -_x;
		parent.originY = -_y;
		parent.width = (_radius + _radius).int();
		parent.height = (_radius + _radius).int();
		
		// update parent list
		if (list != null) 
			list.update();
	}
	
	// Hitbox information.
	private var _x:Int;
	private var _y:Int;
	private var _radius:Float;
	private var _squaredRadius:Float;//Set automatically through the setter for radius
}