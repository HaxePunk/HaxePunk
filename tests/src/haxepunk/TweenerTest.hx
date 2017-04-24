package haxepunk;

import massive.munit.Assert;
import haxepunk.Tweener;

class TweenerTest extends BaseTest
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
		assertThrows(String, function() tweener.addTween(tween));
	}

	var tweener:Tweener;
}
