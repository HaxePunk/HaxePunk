package haxepunk.masks;

import haxepunk.math.*;

class Hitbox extends Rectangle implements Mask
{

	/**
	 * Constructor.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	x			X offset of the hitbox.
	 * @param	y			Y offset of the hitbox.
	 */
	public function new(width:Float=1, height:Float=1, x:Float=0, y:Float=0)
	{
		super(x, y, width, height);
	}

	public var min(get, set):Vector2;
	private inline function get_min():Vector2 { return new Vector2(left, top); }
	private inline function set_min(value:Vector2):Vector2
	{
		x = value.x;
		y = value.y;
		return value;
	}

	public var max(get, set):Vector2;
	private inline function get_max():Vector2 { return new Vector2(right, bottom); }
	private inline function set_max(value:Vector2):Vector2
	{
		width = value.x - x;
		height = value.y - y;
		return value;
	}

	public function debugDraw(offset:Vector3):Void
	{
		haxepunk.graphics.Draw.rect(offset.x + x, offset.y + y, width, height, HXP.maskColor);
	}

	public function collide(other:Mask):Vector3
	{
		return null;
	}

	/** @private Collides against an Entity. */
	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Hitbox))
		{
			return intersectsHitbox(cast other);
		}
		return false;
	}

	private function intersectsHitbox(other:Hitbox):Bool
	{
		return right >= other.left && left <= other.right &&
			bottom >= other.top && top <= other.bottom;
	}

	public function intersectsPoint(point:Vector3):Bool
	{
		return point.x > left && point.x < right && point.y > top && point.y < bottom;
	}

}
