package haxepunk.tweens.motion;

class CubicMotionTest extends TestSuite
{
	@Test
	public function testSetMotion()
	{
		var tween = new CubicMotion();
		tween.setMotion(0, 0, 5, 10, 15, 20, 50, 50, 2);
		tween.update(1);
		Assert.areEqual(13.75, tween.x);
		Assert.areEqual(17.5, tween.y);
	}
}
