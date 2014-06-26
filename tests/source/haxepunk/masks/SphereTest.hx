package haxepunk.masks;

import haxepunk.math.Vector3D;

class SphereTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new Sphere();
		var b = new Sphere();
		assertFalse(a.intersectsSphere(b));
	}

	public function testIntersection()
	{
		var a = new Sphere(new Vector3D(0, 0, 0), 1);
		var b = new Sphere(new Vector3D(1, 1, 1), 1);
		assertTrue(a.intersectsSphere(b));

		b.position.x = b.position.y = b.position.z = 2;
		assertFalse(a.intersectsSphere(b));
	}

}
