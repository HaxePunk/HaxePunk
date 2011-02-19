package com.haxepunk.masks;

import com.haxepunk.Mask;

/**
 * Uses parent's hitbox to determine collision. This class is used
 * internally by FlashPunk, you don't need to use this class because
 * this is the default behaviour of Entities without a Mask object.
 */
class Hitbox extends Mask
{
	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X offset of the hitbox.
	 * @param	y			Y offset of the hitbox.
	 */
	public function new(width:Int = 1, height:Int = 1, x:Int = 0, y:Int = 0) 
	{
		super();
		_width = width;
		_height = height;
		_x = x;
		_y = y;
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}
	
	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		return parent.x + _x + _width > other.parent.x - other.parent.originX
			&& parent.y + _y + _height > other.parent.y - other.parent.originY
			&& parent.x + _x < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y + _y < other.parent.y - other.parent.originY + other.parent.height;
	}
	
	/** @private Collides against a Hitbox. */
	private function collideHitbox(other:Hitbox):Bool
	{
		return parent.x + _x + _width > other.parent.x + other._x
			&& parent.y + _y + _height > other.parent.y + other._y
			&& parent.x + _x < other.parent.x + other._x + other._width
			&& parent.y + _y < other.parent.y + other._y + other._height;
	}
	
	/**
	 * X offset.
	 */
	public var x(getX, setX):Int;
	private function getX():Int { return _x; }
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
	private function getY():Int { return _y; }
	private function setY(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (list!= null) list.update();
		else if (parent != null) update();
		return _y;
	}
	
	/**
	 * Width.
	 */
	public var width(getWidth, setWidth):Int;
	private function getWidth():Int { return _width; }
	private function setWidth(value:Int):Int
	{
		if (_width == value) return value;
		_width = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _width;
	}
	
	/**
	 * Height.
	 */
	public var height(getHeight, setHeight):Int;
	private function getHeight():Int { return _height; }
	private function setHeight(value:Int):Int
	{
		if (_height == value) return value;
		_height = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _height;
	}
	
	/** Updates the parent's bounds for this mask. */
	override public function update() 
	{
		// update entity bounds
		parent.originX = -_x;
		parent.originY = -_y;
		parent.width = _width;
		parent.height = _height;
		
		// update parent list
		if (list != null) list.update();
	}
	
	// Hitbox information.
	private var _width:Int;
	private var _height:Int;
	private var _x:Int;
	private var _y:Int;
}