package haxepunk.scene;

@:access(haxepunk.scene.Scene)
class EntityTest extends haxe.unit.TestCase
{

	public function testNoScene()
	{
		var e = new Entity();
		assertEquals("player", e.type = "player");
		assertEquals(null, e.collide("player"));
	}

	public function testAddToScene()
	{
		var scene = new Scene();
		var e = new Entity();
		scene.add(e);
		scene.updateEntities();
		assertEquals(scene, e.scene);
	}

	public function testCollide()
	{
		var scene = new Scene();

		var a = new Entity(50, 50);
		a.hitbox.left = -50;
		a.hitbox.top = -50;
		a.hitbox.right = 50;
		a.hitbox.bottom = 50;
		scene.add(a);

		var b = new Entity(-25, -25);
		b.hitbox.width = 50;
		b.hitbox.height = 50;
		b.type = "player";
		scene.add(b);

		scene.updateEntities();

		assertEquals(b, a.collide("player"));
	}

}
