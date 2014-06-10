package haxepunk.math;

class Vector3DTest extends haxe.unit.TestCase
{

	public function testInitialize()
	{
		assertVector(new Vector3D());
	}

	public function testDot()
	{
		var a = new Vector3D(1, 2, 3),
			b = new Vector3D(4, 5, 6);

		assertEquals(32.0, a * b);
		assertEquals(32.0, a.dot(b));
		assertEquals(32.0, b * a);
		assertEquals(32.0, b.dot(a));
	}

	public function testCross()
	{
		var a = new Vector3D(1, 2, 3),
			b = new Vector3D(4, 5, 6);

		assertVector(a % b, -3, 6, -3, 1);
		assertVector(a.cross(b), -3, 6, -3, 1);

		assertVector(b % a, 3, -6, 3, 1);
		assertVector(b.cross(a), 3, -6, 3, 1);
	}

	public function testAdd()
	{
		var a = new Vector3D(1, 2, 3),
			b = new Vector3D(4, 5, 6);

		assertVector(a + b, 5, 7, 9);
		assertVector(b + a, 5, 7, 9);
	}

	public function testSubtract()
	{
		var a = new Vector3D(1, 2, 3),
			b = new Vector3D(4, 5, 6);

		assertVector(a - b, -3, -3, -3);
		assertVector(b - a, 3, 3, 3);
	}

	public function testScalar()
	{
		var a = new Vector3D(1, 2, 3);

		assertVector(a * 2, 2, 4, 6);
		assertVector(2 * a, 2, 4, 6);
		assertVector(a * 1.5, 1.5, 3, 4.5);

		assertVector(a / 2, 0.5, 1, 1.5);
		assertVector(a / 0.5, 2, 4, 6);
		// not allowed
		// assertVector(2 / a, 0.5, 1, 1.5);
	}

	public function testEquality()
	{
		var a = new Vector3D(1, 2, 3),
			b = new Vector3D(4, 5, 6);

		assertFalse(a == b);
		assertTrue(a != b);
	}

	public function testNegate()
	{
		var a = new Vector3D(1, 2, 3);

		assertVector(-a, -1, -2, -3);
		assertVector(a.negate(), -1, -2, -3);
	}

	private function assertVector(v:Vector3D, x:Float=0, y:Float=0, z:Float=0, w:Float=0)
	{
		assertEquals(x, v.x);
		assertEquals(y, v.y);
		assertEquals(z, v.z);
		assertEquals(w, v.w);
	}

}
