package haxepunk.masks;

import haxepunk.math.Vector3;

class Circle implements Mask
{

    public var x:Float;
    public var y:Float;
    public var radius:Float;

    /**
	 * Constructor.
	 * @param	radius		Radius of the circle.
	 * @param	x			X position of the circle.
	 * @param	y			Y position of the circle.
	 */
    public function new(radius:Float=0, x:Float=0, y:Float=0)
    {
        this.x = x;
        this.y = y;
        this.radius = radius;
    }

	public var min(get, never):Vector3;
	private inline function get_min():Vector3 { return new Vector3(x-radius, y-radius); }

	public var max(get, never):Vector3;
	private inline function get_max():Vector3 { return new Vector3(x+radius, y+radius); }

    public function debugDraw(offset:Vector3):Void
	{
		//haxepunk.graphics.Draw.circle(offset.x + x, offset.y + y, radius, HXP.maskColor);
	}

	public function overlap(other:Mask):Vector3
	{
		if (Std.is(other, Circle)) return overlapCircle(cast other);
		if (Std.is(other, Hitbox)) return overlapHitbox(cast other);
		return null;
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Circle)) return intersectsCircle(cast other);
		if (Std.is(other, Hitbox)) return intersectsHitbox(cast other);
		return false;
	}

	public function intersectsCircle(other:Circle):Bool
	{
		var dx = other.x - x,
			dy = other.y - y;
		return (dx * dx + dy * dy) <= Math.pow(radius + other.radius, 2);
	}

	public function intersectsHitbox(other:Hitbox):Bool
	{
		var halfWidth = other.width * 0.5;
		var halfHeight = other.height * 0.5;

		var distanceX = Math.abs(x - other.x - halfWidth),
			distanceY = Math.abs(y - other.y - halfHeight);

		// the hitbox is too far away so return false
		if (distanceX > halfWidth + radius || distanceY > halfHeight + radius) return false;
		if (distanceX <= halfWidth || distanceY <= halfHeight) return true;

		return Math.pow(distanceX - halfWidth, 2) + Math.pow(distanceY - halfHeight, 2) <= radius * radius;
	}

	public function containsPoint(point:Vector3):Bool
	{
		return point.x >= x - radius && point.x <= x + radius &&
		 	point.y >= y - radius && point.y <= y + radius;
	}

	public function overlapHitbox(other:Hitbox):Vector3
	{
		// TODO: finish this function
		return null;
	}

	public function overlapCircle(other:Circle):Vector3
	{
		// TODO: finish this function
		return null;
	}

}
