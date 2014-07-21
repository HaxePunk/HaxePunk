import haxepunk.Engine;
import haxepunk.HXP;

class HelloWorld extends Engine
{
	override public function ready()
	{
		super.ready();
		scene.camera.clearColor.fromRGB(0.9, 0.9, 0.9);

		var text = new haxepunk.graphics.Text("Hello world!");
		text.color.fromInt(0xF2990D);
		scene.addGraphic(text, 0, (HXP.window.width - text.width) / 2, (HXP.window.height - text.size) / 2);
	}
}
