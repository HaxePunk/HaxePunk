import haxepunk.Engine;
import haxepunk.graphics.Image;
import haxepunk.graphics.Shape;
import haxepunk.graphics.Material;
import haxepunk.graphics.Texture;

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		var image = new Image("assets/lime.png");
		image.centerOrigin();
		scene.addGraphic(image);

		scene.add(new Player());
	}
}
