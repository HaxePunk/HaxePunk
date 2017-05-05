package haxepunk.tweens.motion;

import massive.munit.Assert;

class LinearMotionTest extends TestSuite
{
	@Test
	public function testSetMotionDistance()
	{
		var tween = new LinearMotion();
		tween.setMotion(0, 0, 5, 0, 2);
		Assert.areEqual(5, tween.distance);
	}

	@Test
	public function testSetMotionSpeedDistance()
	{
		var tween = new LinearMotion();
		tween.setMotionSpeed(4, 0, 4, 10, 2);
		Assert.areEqual(10, tween.distance);
	}

	@Test
	public function testMotionUpdate()
	{
		var tween = new LinearMotion();
		tween.setMotion(4, 0, 4, 10, 2);
		tween.update(1);
		Assert.areEqual(4, tween.x);
		Assert.areEqual(5, tween.y);
	}

	@Test
	public function testMotionSpeedUpdate()
	{
		var tween = new LinearMotion();
		tween.setMotionSpeed(0, 0, 8, 10, 2);
		tween.update(3);
		Assert.areEqual(4, Math.round(tween.x));
		Assert.areEqual(5, Math.round(tween.y));
	}

	@Test
	public function testMotionValuesUpdatedForComplete()
	{
		var tween = new LinearMotion();
		tween.setMotion(0, 0, 4, 10, 2);
		tween.complete.bind(function()
		{
			Assert.areEqual(4, tween.x);
			Assert.areEqual(10, tween.y);
		});
		tween.update(2);
	}
}
