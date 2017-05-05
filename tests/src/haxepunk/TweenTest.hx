package haxepunk;

import massive.munit.Assert;

class TweenTest
{
	@Before
	public function setup()
	{
	}

	@Test
	public function testStart()
	{
		var called = 0;
		var tween = new Tween(10);
		tween.started.bind(function() called += 1);
		tween.start();
		Assert.isTrue(tween.active);
		Assert.areEqual(1, called);
	}

	@Test
	public function testStartWhereDurationIsZero()
	{
		var tween = new Tween(0);
		tween.start();
		Assert.isFalse(tween.active);
		tween.update(0);
		Assert.areEqual(0.0, tween.percent);
	}

	@Test
	public function testStartWithNegativeDuration()
	{
		Assert.throws(String, function() new Tween(-4));
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
		tween.update(1);
		Assert.areEqual(0.0, tween.percent);
	}

	@Test
	public function testUpdateWithStart()
	{
		var tween = new Tween(10);
		Assert.areEqual(0, tween.percent);
		tween.start();
		Assert.areEqual(0, tween.percent);
		tween.update(1);
		Assert.areEqual(0.1, tween.percent);
	}

	@Test
	public function testScale()
	{
		var tween = new Tween(10);
		Assert.areEqual(0, tween.scale);
		tween.start();
		Assert.areEqual(0, tween.scale);
		tween.update(1);
		Assert.areEqual(0.1, tween.scale);
	}

	@Test
	public function testUpdatePastTarget()
	{
		var tween = new Tween(10);
		tween.start();
		tween.update(11);
		Assert.areEqual(1.0, tween.percent);
		Assert.areEqual(1.0, tween.scale);
	}

	@Test
	public function testEasing()
	{
		var called = 0;
		var tween = new Tween(6, null, function(f) return called += 1);
		tween.start();
		Assert.areEqual(0, called);
		tween.update(4);
		Assert.areEqual(1, called);
	}

	@Test
	public function testOneShot()
	{
		var called = 0;
		var tween = new Tween(10, OneShot);
		tween.complete.bind(function() called += 1);
		tween.start();
		tween.update(10);
		Assert.areEqual(1, called);
		Assert.isFalse(tween.active);
	}

	@Test
	public function testPingPong()
	{
		var tween = new Tween(10, PingPong);
		tween.start();
		Assert.isTrue(tween.forward);
		tween.update(10);
		Assert.isFalse(tween.forward);
		Assert.isTrue(tween.active);
		tween.update(10);
		Assert.isTrue(tween.forward);
	}

	@Test
	public function testUpdateListener()
	{
		var called = 0;
		var tween = new Tween(4);
		tween.updated.bind(function() called += 1);
		tween.start();
		Assert.areEqual(0, called);
		tween.update(1);
		Assert.areEqual(1, called);
		tween.update(1);
		Assert.areEqual(2, called);
	}

}
