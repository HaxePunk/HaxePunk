import haxepunk.Engine;

class HelloWorld extends Engine
{
	override public function ready()
	{
		super.ready();
		scene.camera.clearColor = new haxepunk.graphics.Color(0.9, 0.9, 0.9, 1.0);
		scene.addGraphic(new haxepunk.graphics.Text("Hello world"));
	}
}
