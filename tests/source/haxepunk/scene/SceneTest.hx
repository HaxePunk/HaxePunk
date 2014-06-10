package haxepunk.scene;

import haxepunk.Engine;

class SceneTest extends haxe.unit.TestCase
{

	public function testInitialScene()
	{
		var scene = new Scene();
		var e = new Engine(scene);
		assertEquals(scene, e.scene);
	}

	public function testScene()
	{
		var e = new Engine();
		var initialScene = e.scene;
		var scene = new Scene();

		e.pushScene(scene);
		assertEquals(scene, e.scene);

		e.popScene();
		assertEquals(initialScene, e.scene);

		e.popScene();
		assertEquals(initialScene, e.scene);
	}

}
