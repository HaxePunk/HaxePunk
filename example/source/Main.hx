import haxepunk.Engine;
import haxepunk.graphics.Image;

class Main extends Engine
{
	override public function ready()
	{
		scene.addGraphic(new Image("assets/lime.png"));
		scene.add(new Player());
	}
}
