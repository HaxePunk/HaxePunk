import com.haxepunk.Engine;
import com.haxepunk.Entity;
import com.haxepunk.EntityList;
import com.haxepunk.HXP;
import com.haxepunk.Scene;


class TestEntityList extends haxe.unit.TestCase
{
	override public function setup()
	{
		new Engine();
		scene = new Scene();
	}

	public function testAddAndRemoveFromScene()
	{
		var list = new EntityList();
		var child1 = new Entity();
		var child2 = new Entity();

		list.add(child1);
		scene.add(list);
		scene.updateLists();

		assertEquals(scene, list.scene);
		assertEquals(scene, child1.scene);
		assertEquals(null, child2.scene);

		list.add(child2);
		scene.updateLists();
		assertEquals(scene, child2.scene);

		scene.remove(list);
		scene.updateLists();
		assertEquals(null, list.scene);
		assertEquals(null, child1.scene);
		assertEquals(null, child2.scene);
	}

	public function testMove()
	{
		var list = new EntityList();
		var child1 = new Entity();
		var child2 = new Entity();
		child2.x = 20;

		list.add(child1);
		list.add(child2);
		assertEquals(0.0, list.x);
		assertEquals(0.0, child1.x);
		assertEquals(20.0, child2.x);

		list.x += 20;
		assertEquals(20.0, list.x);
		assertEquals(20.0, child1.x);
		assertEquals(40.0, child2.x);
	}

	private var scene:Scene;
}
