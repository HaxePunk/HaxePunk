package haxepunk.masks;

import haxepunk.math.*;

class Hitbox extends Rectangle implements Mask
{

	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X position of the hitbox.
	 * @param	y			Y position of the hitbox.
	 */
	public function new(width:Float=0, height:Float=0, x:Float=0, y:Float=0)
	{
		super(x, y, width, height);
	}

	public var min(get, set):Vector3;
	private inline function get_min():Vector3 { return new Vector3(left, top); }
	private inline function set_min(value:Vector3):Vector3
	{
		x = value.x;
		y = value.y;
		return value;
	}

	public var max(get, set):Vector3;
	private inline function get_max():Vector3 { return new Vector3(right, bottom); }
	private inline function set_max(value:Vector3):Vector3
	{
		width = value.x - x;
		height = value.y - y;
		return value;
	}

	public function debugDraw(offset:Vector3):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + x, offset.y + y, width, height, HXP.maskColor);
	}

	public function overlap(other:Mask):Vector3
	{
		if (Std.is(other, Hitbox)) return overlapHitbox(cast other);
		return null;
	}

	/** @private Collides against an Entity. */
	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Hitbox)) return intersectsHitbox(cast other);
		if (Std.is(other, Circle)) return cast(other, Circle).intersectsHitbox(this);
		return false;
	}

	public function intersectsHitbox(other:Hitbox):Bool
	{
		return right >= other.left && left <= other.right &&
			bottom >= other.top && top <= other.bottom;
	}

	public function containsPoint(point:Vector3):Bool
	{
		return point.x >= left && point.x <= right && point.y >= top && point.y <= bottom;
	}

	public function overlapHitbox(other:Hitbox):Vector3
	{
		var left = other.left - this.right;
		var right = other.right - this.left;
		var top = other.top - this.bottom;
		var bottom = other.bottom - this.top;

		if (left >= 0 || right <= 0 || top >= 0 || bottom <= 0)
		{
			return null;
		}

		return new Vector3(
			(Math.abs(left) < right) ? left : right,
			(Math.abs(top) < bottom) ? top : bottom,
			0
		);
	}

}
