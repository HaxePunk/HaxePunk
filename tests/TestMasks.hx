import com.haxepunk.Mask;
import com.haxepunk.Entity;
import com.haxepunk.masks.Circle;
import com.haxepunk.masks.Hitbox;

class TestMasks extends haxe.unit.TestCase
{

	public override function setup()
	{
		hitbox = new Hitbox(20, 20, -10, -10);
		circle = new Circle(10);

		// have to assign the parents
		hitbox.assignTo(new Entity(0, 0));
		circle.assignTo(new Entity(0, 0));
	}

	public override function tearDown()
	{

	}

	public function testHitbox()
	{
		// check that we collide with the circle
		assertTrue(hitbox.collide(circle));

		circle.x = 20; circle.y = 20;
		assertFalse(hitbox.collide(circle));
	}

	private var hitbox:Hitbox;
	private var circle:Circle;
}
