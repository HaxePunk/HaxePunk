package haxepunk.masks;

import haxepunk.math.Vector3;

class PolygonTest extends haxe.unit.TestCase
{

	public function testPolygonIntersection()
	{
		var a = Polygon.createRegular();
		var b = Polygon.createRegular();
		assertEquals(true, a.intersects(b));
		assertEquals(null, a.overlap(b));
	}

}
