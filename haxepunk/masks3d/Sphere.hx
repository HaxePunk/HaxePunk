package haxepunk.masks3d;

import haxepunk.masks.Mask;
import haxepunk.math.Vector3;

class Sphere implements Mask
{

	/**
	 * Position of the Sphere.
	 */
	public var position:Vector3;

	/**
	 * Radius of the Sphere.
	 */
	public var radius:Float;

	public function new(?position:Vector3, radius:Float=0)
	{
		this.position = (position == null ? new Vector3() : position);
		this.radius = radius;
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, Sphere)) return intersectsSphere(cast other);
		return false;
	}

	public function collide(other:Mask):Vector3
	{
		return Vector3.ZERO;
	}

	public function intersectsPoint(vec:Vector3):Bool
	{
		var dx:Float = position.x - vec.x;
		var dy:Float = position.y - vec.y;
		var dz:Float = position.z - vec.z;
		return (dx * dx + dy * dy + dz * dz) < Math.pow(radius, 2);
	}

	public function intersectsSphere(other:Sphere):Bool
	{
		var dx:Float = position.x - other.position.x;
		var dy:Float = position.y - other.position.y;
		var dz:Float = position.z - other.position.z;
		return (dx * dx + dy * dy + dz * dz) < Math.pow(radius + other.radius, 2);
	}

	private function debugDraw(offset:Vector3):Void
	{
	}

}
