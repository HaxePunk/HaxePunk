package haxepunk.tweens.misc;

import massive.munit.Assert;

class NumTweenTest extends TestSuite
{
	@Test
	public function testUpdate()
	{
		var tween = new NumTween();
		tween.tween(-5, 5, 2);
		tween.update(1);
		Assert.areEqual(0, tween.value);
	}

	@Test
	public function testUpdateReverse()
	{
		var tween = new NumTween();
		tween.tween(15, 5, 2);
		tween.update(1);
		Assert.areEqual(10, tween.value);
	}
}
