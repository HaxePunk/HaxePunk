package haxepunk.tweens.misc;

import massive.munit.Assert;

class VarTweenTest extends TestSuite
{
	@Test
	public function testTweenNullObject()
	{
		var tween = new VarTween();
		Assert.throws(String, function() tween.tween(null, "foo", 0, 0));
	}

	@Test
	public function testTweenNonNumericProperty()
	{
		var tween = new VarTween();
		var foo = { bar: "string" };
		Assert.throws(String, function() tween.tween(foo, "bar", 0, 0));
	}

	@Test
	public function testTweenDurationIsZero()
	{
		var tween = new VarTween();
		Assert.isFalse(tween.active);
		tween.tween({ foo: 0 }, "foo", 0, 0);
		Assert.isFalse(tween.active);
	}

	@Test
	public function testTweenUpdate()
	{
		var tween = new VarTween();
		var foo = { bar: 0 };
		tween.tween(foo, "bar", 1, 2);
		Assert.isTrue(tween.active);
		tween.update(1);
		Assert.areEqual(0.5, foo.bar);
	}
}
