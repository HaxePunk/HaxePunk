package haxepunk.masks;

import haxepunk.math.Vector3;

class BoxTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new Box();
		var b = new Box();
		assertEquals(true, a.intersectsBox(b));
		assertEquals(null, a.overlapBox(b));
	}

	public function testBoxIntersection()
	{
		var a = new Box(50, 50);
		var b = new Box(50, 50, 25, 25);
		assertEquals(true, a.intersectsBox(b));
		assertEquals(true, b.intersectsBox(a));

		a.x = a.y = -25; // edges touching
		assertEquals(true, a.intersects(b));
		a.y = -26;
		assertEquals(false, a.intersectsBox(b));
	}

	public function testBoxOverlap()
	{
		var a = new Box(40, 30, 12, -10);
		var b = new Box(20, 50);
		var r = a.overlap(b);
		assertEquals(8.0, r.x);
		assertEquals(-20.0, r.y);

		var r = b.overlap(a);
		assertEquals(-8.0, r.x);
		assertEquals(20.0, r.y);
	}

}
