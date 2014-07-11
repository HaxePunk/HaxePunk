import haxepunk.Engine;
import haxepunk.graphics.Image;

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
