import haxepunk.Engine;
import haxepunk.scene.Scene;

class SceneTest extends haxe.unit.TestCase
{

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
