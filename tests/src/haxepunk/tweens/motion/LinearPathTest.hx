package haxepunk.tweens.motion;

import massive.munit.Assert;

class LinearPathTest extends TestSuite
{
	@Test
	public function testMotionWithNoPath()
	{
		var tween = new LinearPath();
		Assert.throws(String, function() tween.setMotion(5));
	}

	@Test
	public function testMotionWithOnePoint()
	{
		var tween = new LinearPath();
		tween.addPoint(0, 0);
		Assert.areEqual(1, tween.pointCount);
		Assert.throws(String, function() tween.setMotionSpeed(5));
	}

	@Test
	public function testMotionWithTwoPoints()
	{
		var tween = new LinearPath();
		tween.addPoint(0, 0);
		tween.addPoint(50, 0);
		tween.setMotion(2);
		tween.update(1);
		Assert.areEqual(25, tween.x);
		Assert.areEqual(0, tween.y);
	}

	@Test
	public function testMotionWithPath()
	{
		var tween = new LinearPath();
		tween.addPoint(25, 13);
		tween.addPoint(50, -50);
		tween.addPoint(240, 50);
		tween.addPoint(19, 23);
		tween.setMotion(2);
		tween.update(1.8);
		Assert.areEqual(69, Math.round(tween.x));
		Assert.areEqual(29, Math.round(tween.y));
	}

	@Test
	public function testGetPointWithNoPoints()
	{
		var tween = new LinearPath();
		Assert.throws(String, function() tween.getPoint(1));
	}

	@Test
	public function testGetPoint()
	{
		var tween = new LinearPath();
		tween.addPoint(50, -50);
		tween.addPoint(240, 50);
		tween.addPoint(19, 23);
		var point = tween.getPoint(1);
		Assert.areEqual(240, point.x);
		Assert.areEqual(50, point.y);
	}

	@Test
	public function testUpdatePathCalledTwice()
	{
		var tween = new LinearPath();
		tween.addPoint(0, 0);
		tween.addPoint(10, 10);
		tween.setMotion(1);
		tween.setMotion(10); // updatePath() shouldn't calculate distances twice
		Assert.isTrue(tween.active);
	}
}
