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
		label.text = Keyboard.buffer;
	}

	private var _area:NineSlice;
}
