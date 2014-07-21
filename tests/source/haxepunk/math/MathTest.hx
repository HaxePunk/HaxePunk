package haxepunk.math;

class MathTest extends haxe.unit.TestCase
{

	public function testClamp()
	{
		assertEquals(0.5, Math.clamp(0.5, 0, 1));
		assertEquals(0.0, Math.clamp(-2, 0, 1));
		assertEquals(1.0, Math.clamp(2, 0, 1));
	}

	public function testMin()
	{
		assertEquals(0.2, Math.min(0.2, 1.0));
		assertEquals(0.2, Math.min(1.0, 0.2));
	}

	public function testMax()
	{
		assertEquals(1.0, Math.max(0.2, 1.0));
		assertEquals(1.0, Math.max(1.0, 0.2));
	}

	public function testAbs()
	{
		assertEquals(2.0, Math.abs(2));
		assertEquals(2.0, Math.abs(-2));
	}

	public function testRoundTo()
	{
		assertEquals(3.568, Math.roundTo(3.56783, 3));
		assertEquals(3.567, Math.roundTo(3.56732, 3));
		assertEquals(3.57, Math.roundTo(3.56732, 2));
	}

	public function testSign()
	{
		assertEquals(-1, Math.sign(-1563.342));
		assertEquals(1, Math.sign(352.74));
		assertEquals(0, Math.sign(0));
	}

	public function testLerp()
	{
		assertEquals(1.0, Math.lerp(0, 1));
		assertEquals(0.5, Math.lerp(0, 1, 0.5));
		assertEquals(6.8, Math.lerp(6, 10, 0.2));
	}

	public function testAngle()
	{
		assertEquals(315.0, Math.angle(1, 1, 2, 2));

		assertEquals(-50.0, Math.angleDifference(45, 355));
		assertEquals(45.0, Math.angleDifference(45, 90));
	}

	public function testDistance()
	{
		assertEquals(1.0, Math.distance(0, 1, 1, 1));
	}

	public function testSwap()
	{
		assertEquals(2.0, Math.swap(1.0, 2.0, 1.0));
		assertEquals(2.4, Math.swap(1.4, 1.4, 2.4));
		assertEquals(2, Math.swap(1, 1, 2));
		assertEquals("hi", Math.swap("hello", "hi", "hello"));
	}

	public function testUuid()
	{
		var uuid = Math.uuid();
		assertTrue(uuid != Math.uuid());
		assertEquals(36, uuid.length);
		assertEquals('4', uuid.charAt(14));

		uuid = Math.uuid(12);
		assertEquals(-1, uuid.indexOf('-'));
		assertEquals(12, uuid.length);
	}

	public function testRand()
	{
		var rand = Math.rand(4);
		assertTrue(rand >= 0 && rand <= 4);

		var randFloat = Math.random();
		assertTrue(randFloat >= 0 && randFloat <= 1);
	}

}
