package haxepunk.scene;

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
		assertEquals(scene, e.scene);
	}

	public function testCollide()
	{
		var scene = new Scene();

		var a = new Entity(50, 50);
		a.hitbox.min.x = -50;
		a.hitbox.min.y = -50;
		a.hitbox.max.x = 50;
		a.hitbox.max.y = 50;
		scene.add(a);

		var b = new Entity(-25, -25);
		b.hitbox.width = 50;
		b.hitbox.height = 50;
		b.type = "player";
		scene.add(b);

		assertEquals(b, a.collide("player"));
	}

}
