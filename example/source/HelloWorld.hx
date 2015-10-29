import haxepunk.Engine;

import haxepunk.graphics.*;

class HelloWorld extends Engine
{
	override public function ready()
	{
		super.ready();
		scene.camera.clearColor = new Color(0.9, 0.9, 0.9, 1.0);
		var text = new Text("Hello world", 32);
		text.color.fromInt(0);
		text.centerOrigin();
		scene.addGraphic(text, scene.width / 2, scene.height / 2);
	}
}
