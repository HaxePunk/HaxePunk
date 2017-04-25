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
	public function testAddTwice()
	{
		var tween = new Tween(1);
		tweener.addTween(tween);
		Assert.throws(String, function() tweener.addTween(tween));
	}

	var tweener:Tweener;
}
