package haxepunk.tweens.motion;

import massive.munit.Assert;

class QuadMotionTest extends TestSuite
{
	@Test
	public function testDistance()
	{
		var tween = new QuadMotion();
		tween.setMotion(0, 0, 5, 10, 15, 50, 2);
		Assert.areEqual(52, Math.round(tween.distance));
	}

	@Test
	public function testMotion()
	{
		var tween = new QuadMotion();
		tween.setMotion(0, 0, 5, 10, 15, 50, 2);
		tween.update(1);
		Assert.areEqual(6, Math.round(tween.x));
		Assert.areEqual(18, Math.round(tween.y));
	}

	@Test
	public function testMotionSpeed()
	{
		var tween = new QuadMotion();
		tween.setMotionSpeed(0, 0, 5, 10, 15, 50, 20);
		tween.update(1);
		Assert.areEqual(5, Math.round(tween.x));
		Assert.areEqual(12, Math.round(tween.y));
	}
}
