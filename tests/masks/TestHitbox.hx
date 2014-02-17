package masks;

import com.haxepunk.*;
import com.haxepunk.masks.*;

class TestHitbox extends haxe.unit.TestCase
{

	override public function setup()
	{
		box = new Hitbox(20, 20, -10, -10);
	}

	public function testHitbox()
	{
		var hitbox = new Hitbox(50, 50);
		assertTrue(collideHitbox(hitbox, 0, 0));
	}

	public function testCircle()
	{
		var circle = new Circle(8);
		// hit
		assertTrue(collideCircle(circle, 0, 0));

		// miss
		assertFalse(collideCircle(circle, 20, 0));
		assertFalse(collideCircle(circle, 0, 20));
	}

	@:access(com.haxepunk.masks.Hitbox)
	private function collideHitbox(hitbox:Hitbox, x:Int, y:Int):Bool
	{
		box._x = x;
		box._y = y;
		return hitbox.collideHitbox(box);
	}

	@:access(com.haxepunk.masks.Circle)
	private function collideCircle(circle:Circle, x:Int, y:Int):Bool
	{
		circle._x = x;
		circle._y = y;
		return circle.collideHitbox(box);
	}

	private var box:Hitbox;
}
