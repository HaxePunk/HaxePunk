import haxepunk.Engine;
import haxepunk.scene.Entity;
import haxepunk.graphics.Texture;
import haxepunk.graphics.shapes.Cube;
import haxepunk.graphics.importer.Wavefront;

class CubeEntity extends Entity
{
	public function new()
	{
		super();
		// var meshList = Wavefront.load("assets/project.obj");
		// graphic = meshList.first();
		var cube = new Cube();
		cube.material.addTexture(new Texture("assets/lime.png"));
		graphic = cube;
	}
}

class Main extends Engine
{
	override public function init()
	{
		scene.add(new CubeEntity());
	}
}
