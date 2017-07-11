package haxepunk;

import massive.munit.Assert;
import haxepunk.Engine;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Scene;

// dummy entity for testing class types
class TestEntity extends Entity {}

@:access(haxepunk.Engine)
class SceneTest
{
	@Before
	public function setup()
	{
		scene = new Scene();
	}

	@Test
	public function testEntityCount()
	{
		var e = new Entity();
		e.type = "foo";
		scene.add(e);
		Assert.areEqual(0, scene.count);

		scene.updateEntityLists();
		Assert.areEqual(1, scene.count);

		scene.add(new Entity());
		scene.add(new Entity());
		scene.add(new Entity());
		scene.remove(e);
		scene.updateEntityLists();
		Assert.areEqual(3, scene.count);
	}

	@Test
	public function testEntityTypes()
	{
		var e = new Entity();
		e.type = "foo";
		scene.add(e);
		scene.add(new Entity());
		scene.updateEntityLists();
		Assert.areEqual(1, scene.typeCount("foo"));
		Assert.areEqual(0, scene.typeCount("bar"));
		Assert.areEqual(1, scene.uniqueTypes);

		Assert.areEqual(1, scene.classCount("haxepunk.Entity"));

		e.type = "bar";
		Assert.areEqual(0, scene.typeCount("foo"));
		Assert.areEqual(1, scene.typeCount("bar"));
		Assert.areEqual(1, scene.uniqueTypes);
	}

	@Test
	public function testEntityLayers()
	{
		var e = new Entity();
		scene.add(e);
		scene.add(new Entity());
		scene.updateEntityLists();
		Assert.areEqual(0, scene.layerCount(15));
		Assert.areEqual(1, scene.layers);

		e.layer = 15;
		Assert.areEqual(1, scene.layerCount(15));
		Assert.areEqual(2, scene.layers);

		e.layer = 0;
		Assert.areEqual(1, scene.layers);
	}

	@Test
	public function testCreateRecycle()
	{
		var e:TestEntity = scene.create(TestEntity, false);
		Assert.isTrue(Std.is(e, TestEntity));
		scene.updateEntityLists();
		Assert.areEqual(0, countRecycled(scene));

		scene.recycle(e);
		scene.recycle(new Entity());
		scene.recycle(new Entity()); // linked with previous entity _recycleNext
		scene.updateEntityLists();
		Assert.areEqual(2, countRecycled(scene));

		scene.clearRecycled(TestEntity);
		Assert.areEqual(1, countRecycled(scene));

		scene.clearRecycledAll();
		Assert.areEqual(0, countRecycled(scene));
	}

	@Test
	public function testEntityName()
	{
		var e = new Entity();
		e.name = "foo";
		scene.add(e);
		scene.updateEntityLists();

		Assert.areEqual(e, scene.getInstance("foo"));

		e.name = "bar";
		Assert.areEqual(e, scene.getInstance("bar"));
		Assert.areEqual(null, scene.getInstance("foo"));
	}

	@:access(haxepunk.Scene)
	function countRecycled(scene:Scene)
	{
		var i:Int = 0;
		for (r in scene._recycled) i++;
		return i;
	}

	var scene:Scene;
}
