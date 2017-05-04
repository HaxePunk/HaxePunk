package haxepunk.tweens.misc;

import massive.munit.Assert;

class MultiVarTweenTest extends TestSuite
{
	@Test
	public function testTweenNullProperties()
	{
		var tween = new MultiVarTween();
		Assert.throws(String, function() tween.tween({}, null, 0));
	}

	@Test
	public function testTweenNonNumeric()
	{
		var tween = new MultiVarTween();
		Assert.throws(String, function() tween.tween({}, {foo:1, bar:"baz"}, 0));
	}

	@Test
	public function testTweenNonExistantProperty()
	{
		var tween = new MultiVarTween();
		Assert.throws(String, function() tween.tween({bar:0}, {foo:1}, 0));
	}

	@Test
	public function testValidTween()
	{
		var tween = new MultiVarTween();
		tween.tween({foo:0}, {foo:1}, 1);
		Assert.isTrue(tween.active);
	}

	@Test
	public function testTweenUpdate()
	{
		var tween = new MultiVarTween();
		var obj = {foo:0, bar:0};
		tween.tween(obj, {foo:2, bar:3}, 2);
		tween.update(1);
		Assert.areEqual(1, obj.foo);
		Assert.areEqual(1.5, obj.bar);
		tween.update(1);
		Assert.areEqual(2, obj.foo);
		Assert.areEqual(3, obj.bar);
		Assert.isFalse(tween.active);
	}
}
