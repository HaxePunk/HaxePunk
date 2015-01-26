import haxepunk.gui.*;

class Gui extends haxepunk.Engine
{
	override public function ready()
	{
		scene.add(new Panel(250, 50, 200, 50));

		var button = new Button("Don't press me!\nAugh", 150, 150);
		button.text.color.fromInt(0xFF0000);
		scene.add(button);
	}
}
