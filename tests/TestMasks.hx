
import haxe.unit.TestCase;
import com.haxepunk.Mask;
import com.haxepunk.masks.Hitbox;

class TestMasks extends TestCase
{
	public function testHitboxToHitbox()
	{
		var a:Mask = new Hitbox(50, 80, 4, 4);
		var b:Mask = new Hitbox(20, 40, 3, 3);
		assertTrue(b.collide(a));
	}
}