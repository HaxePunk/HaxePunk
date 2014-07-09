import haxepunk.Engine;
import haxepunk.graphics.Image;
import haxepunk.graphics.Shape;
import haxepunk.graphics.Material;
import haxepunk.graphics.Texture;

class Main extends Engine
{
	override public function ready()
	{
		var image = new Image("assets/lime.png");
		image.centerOrigin();
		scene.addGraphic(image);

		// var material = new Material();
		// material.addTexture(Texture.create("assets/lime.png"));
		// var cube = Shape.createCube(material);
		// scene.addGraphic(cube);

		// scene.add(new Player());
	}
}
