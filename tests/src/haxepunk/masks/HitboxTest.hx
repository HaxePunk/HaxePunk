package haxepunk.masks;

import massive.munit.Assert;
import haxepunk.*;
import haxepunk.masks.*;

class HitboxTest extends TestSuite
{
	@Before
	public function setup()
	{
		box = new Hitbox(20, 20, -10, -10);
	}

	@Test
	public function testHitbox()
	{
		var hitbox = new Hitbox(50, 50);
		Assert.isTrue(collideHitbox(hitbox, 0, 0));
	}

	@Test
	public function testCircle()
	{
		var circle = new Circle(8);
		// hit
		Assert.isTrue(collideCircle(circle, 0, 0));

		// miss
		Assert.isFalse(collideCircle(circle, 20, 0));
		Assert.isFalse(collideCircle(circle, 0, 20));
	}

	@:access(haxepunk.masks.Hitbox)
	private function collideHitbox(hitbox:Hitbox, x:Int, y:Int):Bool
	{
		box._x = x;
		box._y = y;
		return hitbox.collideHitbox(box);
	}

	@:access(haxepunk.masks.Circle)
	private function collideCircle(circle:Circle, x:Int, y:Int):Bool
	{
		circle._x = x;
		circle._y = y;
		return circle.collideHitbox(box);
	}

	private var box:Hitbox;
}
