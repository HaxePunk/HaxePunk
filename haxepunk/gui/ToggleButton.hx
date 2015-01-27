package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.graphics.Graphic;
import haxepunk.inputs.Input;
import haxepunk.inputs.Mouse;
import haxepunk.math.Rectangle;

class ToggleButton extends Button
{

	public var checked(default, set):Bool = false;
	private function set_checked(value:Bool):Bool { return checked = value; }

	public function new(text:String = "Toggle", x:Float = 0, y:Float = 0)
	{
		super(text, x, y);
		hoverDown = down;
		var inactiveDown = new NineSlice(Control.defaultSkin, new Rectangle(72, 96, 8, 8));
		inactiveDown.setSize(width, height);
		this.inactiveDown = inactiveDown;
	}

	override public function update(elapsed:Float)
	{
		label.x = x + padding;
		label.y = y + padding;
		if (active)
		{
			if (collidePoint(x, y, Mouse.x, Mouse.y))
			{
				if (Input.pressed(MouseButton.LEFT) > 0)
				{
					checked = !checked;
				}
				else
				{
					_graphic = checked ? hoverDown : hover;
				}
			}
			else
			{
				_graphic = checked ? down : normal;
			}
		}
		else
		{
			_graphic = checked ? inactiveDown : inactive;
		}
	}

	private var hoverDown:Graphic;
	private var inactiveDown:Graphic;

}
