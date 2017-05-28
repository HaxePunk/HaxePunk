package haxepunk.tweens.motion;

import massive.munit.Assert;

class QuadPathTest extends TestSuite
{
	@Test
	public function testNoPoints()
	{
		var tween = new QuadPath();
		Assert.throws(String, function() tween.setMotion(10));
	}

	@Test
	public function testTwoPoints()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(2, 2);
		Assert.throws(String, function() tween.setMotion(10));
	}

	@Test
	public function testGetPointWithNoPoints()
	{
		var tween = new QuadPath();
		Assert.throws(String, function() tween.getPoint());
	}

	@Test
	public function testGetPoint()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(3, 5);
		tween.addPoint(20, -24);
		var point = tween.getPoint(1);
		Assert.areEqual(3, point.x);
		Assert.areEqual(5, point.y);
	}

	@Test
	public function testMotion()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(2, 2);
		tween.addPoint(0, 4);
		tween.setMotion(2);
		tween.update(1);
		Assert.areEqual(1, tween.x);
		Assert.areEqual(2, tween.y);
	}

	@Test
	public function testMotionSpeed()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(250, 36);
		tween.addPoint(65, 754);
		tween.setMotionSpeed(20);
		tween.update(1);
		Assert.areEqual(14, Math.round(tween.x));
		Assert.areEqual(3, Math.round(tween.y));
		tween.update(30);
		Assert.areEqual(94, Math.round(tween.x));
		Assert.areEqual(635, Math.round(tween.y));
	}

	@Test
	public function testUpdateNotNeeded()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(2, 2);
		tween.addPoint(0, 4);
		tween.setMotionSpeed(1);
		tween.setMotionSpeed(2); // doesn't need second update
		Assert.isTrue(tween.active);
	}

	@Test
	public function testPointCount()
	{
		var tween = new QuadPath();
		tween.addPoint(0, 0);
		tween.addPoint(2, 2);
		tween.addPoint(0, 4);
		tween.addPoint(53, 24);
		tween.addPoint(90, 88);
		Assert.areEqual(5, tween.pointCount);
	}
}
