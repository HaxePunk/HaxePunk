package com.haxepunk.masks;

import com.haxepunk.Mask;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import flash.display.Graphics;
import flash.geom.Point;
import com.haxepunk.masks.Polygon;

/** Uses parent's hitbox to determine collision.
 * This class is used * internally by HaxePunk, you don't need to use this class because
 * this is the default behaviour of Entities without a Mask object. */
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
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		var px:Float = _x + _parent.x, 
			py:Float = _y + _parent.y;

		var ox = other._parent.originX + other._parent.x,
			oy = other._parent.originY + other._parent.y;

		return px + _width > ox
			&& py + _height > oy
			&& px < ox + other._parent.width
			&& py < oy + other._parent.height;
	}

	/** @private Collides against a Hitbox. */
	private function collideHitbox(other:Hitbox):Bool
	{
		var px:Float = _x + _parent.x, 
			py:Float = _y + _parent.y;

		var ox:Float = other._x + other._parent.x, 
			oy:Float = other._y + other._parent.x;

		return px + _width > ox
			&& py + _height > oy
			&& px < ox + other._width
			&& py < oy + other._height;
	}

	/**
	 * X offset.
	 */
	public var x(get, set):Int;
	private function get_x():Int { return _x; }
	private function set_x(value:Int):Int
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
	public var y(get, set):Int;
	private function get_y():Int { return _y; }
	private function set_y(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (list != null) list.update();
		else if (parent != null) update();
		return _y;
	}

	/**
	 * Width.
	 */
	public var width(get, set):Int;
	private function get_width():Int { return _width; }
	private function set_width(value:Int):Int
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
	public var height(get, set):Int;
	private function get_height():Int { return _height; }
	private function set_height(value:Int):Int
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
		if (parent != null)
		{
			// update entity bounds
			_parent.originX = -_x;
			_parent.originY = -_y;
			_parent.width = _width;
			_parent.height = _height;
			// update parent list
			if (list != null)
				list.update();
		}
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		// draw only if the hitbox is part of a Masklist and has a parent
		if (list != null && parent != null && list.count > 1)
		{
			graphics.drawRect((parent.x - HXP.camera.x + x) * scaleX, (parent.y - HXP.camera.y + y) * scaleY, width * scaleX, height * scaleY);
		}
	}
	
	override public function project(axis:Vector, projection:Projection):Void
	{
		var px = _x;
		var py = _y;
		var cur:Float,
			max:Float = Math.NEGATIVE_INFINITY,
			min:Float = Math.POSITIVE_INFINITY;

		cur = px * axis.x + py * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (px + _width) * axis.x + py * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = px * axis.x + (py + _height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (px + _width) * axis.x + (py + _height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		projection.min = min;
		projection.max = max;
	}
	
	// Hitbox information.
	private var _width:Int = 0;
	private var _height:Int = 0;
	private var _x:Int = 0;
	private var _y:Int = 0;
}
