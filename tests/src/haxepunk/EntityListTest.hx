package haxepunk;

import haxepunk.Engine;
import haxepunk.Entity;
import haxepunk.EntityList;
import haxepunk.HXP;
import haxepunk.Scene;

class EntityListTest extends TestSuite
{
	@Before
	public function setup()
	{
		new Engine();
		scene = new Scene();
	}

	@Test
	public function testAddAndRemoveFromScene()
	{
		var list = new EntityList();
		var child1 = new Entity();
		var child2 = new Entity();

		list.add(child1);
		scene.add(list);
		scene.updateLists();

		Assert.areEqual(scene, list.scene);
		Assert.areEqual(scene, child1.scene);
		Assert.areEqual(null, child2.scene);

		list.add(child2);
		scene.updateLists();
		Assert.areEqual(scene, child2.scene);

		scene.remove(list);
		scene.updateLists();
		Assert.areEqual(null, list.scene);
		Assert.areEqual(null, child1.scene);
		Assert.areEqual(null, child2.scene);
	}

	@Test
	public function testMove()
	{
		var list = new EntityList();
		var child1 = new Entity();
		var child2 = new Entity();
		child2.x = 20;

		list.add(child1);
		list.add(child2);
		Assert.areEqual(0.0, list.x);
		Assert.areEqual(0.0, child1.x);
		Assert.areEqual(20.0, child2.x);

		list.x += 20;
		Assert.areEqual(20.0, list.x);
		Assert.areEqual(20.0, child1.x);
		Assert.areEqual(40.0, child2.x);
	}

	var scene:Scene;
}
