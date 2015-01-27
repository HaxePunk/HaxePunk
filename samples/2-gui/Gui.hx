import haxepunk.gui.*;

class Gui extends haxepunk.Engine
{
	override public function ready()
	{
		// Control.defaultSkin = "graphics/gui/nesSkin.png";
		scene.add(new Panel(250, 50, 200, 50));

		var button = new ToggleButton("Press me\nover and over", 150, 125);
		button.label.color.fromInt(0xFF0000);
		scene.add(button);

		scene.add(new CheckBox("Check Me?", 50, 50));
		scene.add(new CheckBox("And another", 50, 75));

		scene.add(new RadioButton("Check this!", 50, 200));
		scene.add(new RadioButton("Or this...", 50, 225));

		scene.add(new TextArea(300, 150));
	}
}
