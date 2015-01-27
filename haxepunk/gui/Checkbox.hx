package haxepunk.gui;

import haxepunk.graphics.Image;
import haxepunk.math.Rectangle;

class CheckBox extends ToggleButton
{

	public function new(text:String = "Checkbox", x:Float = 0, y:Float = 0)
	{
		super(text, x, y);
		hitbox.height = 16;

		normal = new Image(Control.defaultSkin, new Rectangle(0, 48, 16, 16));
		hover = new Image(Control.defaultSkin, new Rectangle(16, 48, 16, 16));
		down = new Image(Control.defaultSkin, new Rectangle(64, 48, 16, 16));
		hoverDown = new Image(Control.defaultSkin, new Rectangle(80, 48, 16, 16));
		inactive = new Image(Control.defaultSkin, new Rectangle(96, 0, 16, 16));
		inactiveDown = new Image(Control.defaultSkin, new Rectangle(96, 32, 16, 16));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		label.x = x + padding + _graphic.width;
		label.y = y;
	}

}
