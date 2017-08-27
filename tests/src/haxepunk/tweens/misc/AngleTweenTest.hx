package haxepunk.tweens.misc;

import massive.munit.Assert;
import haxepunk.math.Random;

class AngleTweenTest extends TestSuite
{
	@Test
	public function testTween()
	{
		var tween = new AngleTween();
		tween.tween(20, 50, 5);
		Assert.areEqual(20, tween.angle);
		Assert.isTrue(tween.active);
	}

	@Test
	public function testTweenUpdate()
	{
		var tween = new AngleTween();
		tween.tween(10, 240, 4);
		tween.update(2);
		Assert.areEqual(305, tween.angle);

		tween.tween(240, 10, 4);
		tween.update(2);
		Assert.areEqual(305, tween.angle);
	}

	@Test
	public function testUpdate180()
	{
		var tween = new AngleTween();

		Random.randomSeed = 12345; // force HXP.choose selection
		tween.tween(0, 180, 2);
		tween.update(1);
		Assert.areEqual(90, tween.angle);

		Random.randomSeed = 98765; // force HXP.choose selection
		tween.tween(0, 180, 2);
		tween.update(1);
		Assert.areEqual(270, tween.angle);
	}

}
