package haxepunk;

import massive.munit.Assert;
import haxepunk.Tweener;

class TweenerTest
{
	@Before
	public function setup()
	{
		tweener = new Tweener();
	}

	@Test
	public function testHasTween()
	{
		var tween = new Tween(0);
		Assert.isFalse(tweener.hasTween);
		tweener.addTween(tween);
		Assert.isTrue(tweener.hasTween);
	}

	@Test
	public function testAddTwice()
	{
		var tween = new Tween(1);
		tweener.addTween(tween);
		Assert.throws(String, function() tweener.addTween(tween));
	}

	@Test
	public function testCallback()
	{
		var called = 0;
		var tween = new Tween(2, Persist);
		tween.complete.bind(function() called += 1);
		tweener.addTween(tween, true);
		Assert.areEqual(0, called);
		tweener.updateTweens(1);
		Assert.areEqual(0, called);
		tweener.updateTweens(1);
		Assert.areEqual(1, called);
		tweener.updateTweens(1);
		Assert.areEqual(1, called);
	}

	@Test
	public function testRemoveFromNonParent()
	{
		var tween = new Tween(1);
		Assert.throws(String, function() tweener.removeTween(tween));
	}

	@Test
	public function testRemovedIsInactive()
	{
		var tween = new Tween(1);
		tweener.addTween(tween, true);
		Assert.isTrue(tween.active);
		tweener.removeTween(tween);
		Assert.isFalse(tween.active);
	}

	@Test
	public function testTweenCancel()
	{
		var tween = new Tween(1);
		tweener.addTween(tween, true);
		tween.cancel();
		Assert.throws(String, function() tweener.removeTween(tween));
	}

	@Test
	public function testClearTweens()
	{
		var tweens = [new Tween(1), new Tween(3), new Tween(2)];
		for (tween in tweens)
		{
			tweener.addTween(tween, true);
			Assert.isTrue(tween.active);
		}
		tweener.clearTweens();
		for (tween in tweens)
		{
			Assert.isFalse(tween.active);
		}
	}

	var tweener:Tweener;
}
