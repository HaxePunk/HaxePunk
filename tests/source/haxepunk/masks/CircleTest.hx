package haxepunk.masks;

import haxepunk.math.Vector3;

class CircleTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new Circle();
		var b = new Circle();
		assertEquals(true, a.intersectsCircle(b));
		assertEquals(null, a.overlapCircle(b));
	}

	public function testPointIntersection()
	{
		var a = new Circle(36.3, 15, 26);
		assertEquals(true, a.containsPoint(new Vector3(2, 4)));
		assertEquals(true, a.containsPoint(new Vector3(51.3, 62.3))); // edge test
		assertEquals(false, a.containsPoint(new Vector3(52, 62.3)));
		assertEquals(false, a.containsPoint(new Vector3(-51.3, -62.3)));
	}

	public function testCircleIntersection()
	{
		var a = new Circle(30);
		var b = new Circle(20, 15, 15);

		assertEquals(true, a.intersectsCircle(b));
		assertEquals(true, b.intersectsCircle(a));

		a.x = -35; a.y = 15;
		assertEquals(true, a.intersects(b));
		a.x = -30; a.y = -20;
		assertEquals(false, a.intersectsCircle(b));
	}

	/*public function testCircleOverlap()
	{
		var a = new Circle(45.5);
		var b = new Circle(24.2, 5.4, 3.5);
		var r = a.overlap(b);
		assertEquals(4.0, r.x);
		assertEquals(4.0, r.x);
	}*/

}
