package haxepunk.gui;

import haxepunk.graphics.Text;
import haxepunk.graphics.Color;

class Label extends Control
{

	public var color(get, never):Color;
	private inline function get_color():Color { return _text.color; }

	public var text(get, set):String;
	private inline function get_text():String { return _text.text; }
	private inline function set_text(value:String):String {
		_text.text = value;
		width = _text.width;
		height = _text.height;
		return value;
	}

	public function new(text:String)
	{
		super();
		_graphic = _text = new Text(text);
		width = _text.width;
		height = _text.height;
	}

	private var _text:Text;

}
