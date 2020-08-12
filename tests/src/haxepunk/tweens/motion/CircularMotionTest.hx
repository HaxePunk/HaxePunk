package haxepunk.tweens.motion;

class CircularMotionTest extends TestSuite
{
	@Test
	public function testSetMotionClockwise()
	{
		var tween = new CircularMotion();
		tween.setMotion(0, 0, 10, 0, true, 4);
		tween.update(2);
		Assert.areEqual(180, tween.angle);
	}

	@Test
	public function testSetMotionCounterClockwise()
	{
		var tween = new CircularMotion();
		tween.setMotion(0, 0, 10, 0, false, 4);
		tween.update(2);
		Assert.areEqual(-180, tween.angle);
	}

	@Test
	public function testSetMotionSpeedClockwise()
	{
		var tween = new CircularMotion();
		tween.setMotionSpeed(0, 0, 10, 0, true, 0.5);
		tween.update(2);
		Assert.areEqual(10, Math.round(tween.x));
		Assert.areEqual(1, Math.round(tween.y));
	}

	@Test
	public function testSetMotionSpeedCounterClockwise()
	{
		var tween = new CircularMotion();
		tween.setMotionSpeed(0, 0, 10, 0, false, 0.5);
		tween.update(2);
		Assert.areEqual(10, Math.round(tween.x));
		Assert.areEqual(-1, Math.round(tween.y));
	}
}
