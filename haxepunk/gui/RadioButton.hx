package haxepunk.gui;

import haxe.ds.StringMap;
import haxepunk.graphics.Image;
import haxepunk.math.Rectangle;

class RadioButton extends ToggleButton
{

	public function new(text:String = "Checkbox", x:Float = 0, y:Float = 0, id:String = "radio")
	{
		super(text, x, y);
		hitbox.height = 16;

		_name = id;
		if (_buttons.exists(id))
		{
			_buttons.get(id).push(this);
		}
		else
		{
			_buttons.set(id, [this]);
		}

		normal = new Image(Control.defaultSkin, new Rectangle(0, 64, 16, 16));
		hover = new Image(Control.defaultSkin, new Rectangle(16, 64, 16, 16));
		down = new Image(Control.defaultSkin, new Rectangle(32, 64, 16, 16));
		hoverDown = new Image(Control.defaultSkin, new Rectangle(48, 64, 16, 16));
		inactive = new Image(Control.defaultSkin, new Rectangle(64, 64, 16, 16));
		inactiveDown = new Image(Control.defaultSkin, new Rectangle(80, 64, 16, 16));
	}

	override private function set_checked(value:Bool):Bool
	{
		if (value)
		{
			var buttons:Array<RadioButton> = _buttons.get(_name);
			for (button in buttons)
			{
				if (button != this)
					button.checked = false;
			}
		}
		return super.set_checked(value);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		label.x = x + padding + _graphic.width;
		label.y = y;
	}

	private static var _buttons = new StringMap<Array<RadioButton>>();

}
