package haxepunk.masks;

import haxepunk.math.Vector3;

class HitboxTest extends haxe.unit.TestCase
{

	public function testZero()
	{
		var a = new Hitbox();
		var b = new Hitbox();
		assertEquals(true, a.intersectsHitbox(b));
		assertEquals(null, a.overlapHitbox(b));
	}

	public function testHitboxIntersection()
	{
		var a = new Hitbox(50, 50);
		var b = new Hitbox(50, 50, 25, 25);
		assertEquals(true, a.intersectsHitbox(b));
		assertEquals(true, b.intersectsHitbox(a));

		a.x = a.y = -25; // edges touching
		assertEquals(true, a.intersects(b));
		a.y = -26;
		assertEquals(false, a.intersectsHitbox(b));
	}

	public function testHitboxOverlap()
	{
		var a = new Hitbox(40, 30, 12, -10);
		var b = new Hitbox(20, 50);
		var r = a.overlap(b);
		assertEquals(8.0, r.x);
		assertEquals(-20.0, r.y);

		var r = b.overlap(a);
		assertEquals(-8.0, r.x);
		assertEquals(20.0, r.y);
	}

}
