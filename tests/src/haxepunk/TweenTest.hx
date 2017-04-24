package haxepunk;

import massive.munit.Assert;
import haxepunk.Tween;

class TweenTest extends BaseTest
{
	@Before
	public function setup()
	{
	}

	@Test
	public function testStart()
	{
		var tween = new Tween(10);
		tween.start();
		Assert.isTrue(tween.active);
		Assert.areEqual(0, tween.percent);
	}

	@Test
	public function testStartWhereDurationIsZero()
	{
		assertThrows(String, function() new Tween(0));
	}

	@Test
	public function testStartWithNegativeDuration()
	{
		assertThrows(String, function() new Tween(-4));
	}

	@Test
	public function testCancelStartedTween()
	{
		var tween = new Tween(10);
		tween.start();
		tween.cancel();
		Assert.isFalse(tween.active);
	}

	@Test
	public function testUpdateWithoutStart()
	{
		var tween = new Tween(10);
		HXP.elapsed = 1;
		tween.update();
		Assert.areEqual(0.0, tween.percent);
	}

	@Test
	public function testUpdateWithStart()
	{
		var tween = new Tween(10);
		HXP.elapsed = 1;
		Assert.areEqual(0, tween.percent);
		tween.start();
		Assert.areEqual(0, tween.percent);
		tween.update();
		Assert.areEqual(0.1, tween.percent);
	}

	@Test
	public function testScale()
	{
		var tween = new Tween(10);
		HXP.elapsed = 1;
		Assert.areEqual(0, tween.scale);
		tween.start();
		Assert.areEqual(0, tween.scale);
		tween.update();
		Assert.areEqual(0.1, tween.scale);
	}

	@Test
	public function testUpdatePastTarget()
	{
		var tween = new Tween(10);
		HXP.elapsed = 11;
		tween.start();
		tween.update();
		Assert.areEqual(1.1, tween.percent);
		Assert.areEqual(1.0, tween.scale);
	}
}
