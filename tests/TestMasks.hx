import com.haxepunk.Mask;
import com.haxepunk.Entity;
import com.haxepunk.masks.Hitbox;

class TestMasks extends haxe.unit.TestCase
{
	public function testHitbox()
	{
		var e = new Entity(0, 0);

		var a = new Hitbox(30, 50, 10, 10);
		a.assignTo(e);
		var b = new Hitbox(70, 20);
		b.assignTo(e);

		assertTrue(b.collide(a));
	}
}
