package haxepunk.masks;

import haxepunk.math.Vector3;

class PolygonTest extends haxe.unit.TestCase
{

	public function testPolygonIntersection()
	{
		var p = [new Vector3(0, -1), new Vector3(0, 3), new Vector3(5, 0)];
		var a = new Polygon(p);
		var b = new Polygon(p);
		assertEquals(true, a.intersects(b));
		assertEquals(null, a.overlap(b));
	}

}
