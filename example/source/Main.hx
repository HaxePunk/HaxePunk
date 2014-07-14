import haxepunk.Engine;
import haxepunk.graphics.Image;
import lime.graphics.Font;

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		// var image = new Image("assets/lime.jpg");
		// image.centerOrigin();
		// scene.addGraphic(image);

		var text = new haxepunk.graphics.Text("The quick brown fox jumps over the lazy dog.");
		text.color.r = 0.997;
		text.color.g = 0.868;
		text.color.b = 0.462;
		scene.addGraphic(text);

		// scene.add(new Player());
	}
}
