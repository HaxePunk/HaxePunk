package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.math.Rectangle;
import haxepunk.inputs.Input;
import haxepunk.inputs.Keyboard;

class TextArea extends Control
{
	public function new(x:Float=0, y:Float=0, text:String="")
	{
		super(x, y, text);

		_graphic = _area = new NineSlice(Control.defaultSkin, new Rectangle(0, 0, 8, 8));
		label.color.fromInt(0x000000);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		label.x = x + padding;
		label.y = y + padding;
		if (Input.pressed(Keyboard.last) > 0)
		{
			var last:Int = Keyboard.last;
			switch (Keyboard.last)
			{
				case Key.SPACE:
					label.text += " ";
				case Key.BACKSPACE:
					label.text = label.text.substr(0, -1);
				case Key.ENTER:
					label.text += "\n";
				default:
					if (last < 127)
					{
						label.text += Keyboard.nameOf(Keyboard.last);
					}
			}
		}
	}

	private var _area:NineSlice;
}
