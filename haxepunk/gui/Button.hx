package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.graphics.Graphic;
import haxepunk.graphics.Color;
import haxepunk.math.Rectangle;
import haxepunk.inputs.Input;
import haxepunk.inputs.Mouse;
import lime.app.Event;

class Button extends Control
{

	public var active:Bool = true;
	public var onClick:Event<Void->Void>;

	public function new(text:String, x:Float=0, y:Float=0)
	{
		super(x, y, text);

		var normal = new NineSlice(Control.defaultSkin, new Rectangle(0, 96, 8, 8));
		var hover = new NineSlice(Control.defaultSkin, new Rectangle(24, 96, 8, 8));
		var down = new NineSlice(Control.defaultSkin, new Rectangle(48, 96, 8, 8));
		var inactive = new NineSlice(Control.defaultSkin, new Rectangle(96, 96, 8, 8));

		normal.setSize(width, height);
		hover.setSize(width, height);
		down.setSize(width, height);
		inactive.setSize(width, height);

		this.normal = _graphic = normal;
		this.hover = hover;
		this.down = down;
		this.inactive = inactive;

		onClick = new Event<Void->Void>();
	}

	override public function update(elapsed:Float)
	{
		label.x = x + padding;
		label.y = y + padding;
		if (active)
		{
			if (collidePoint(x, y, Mouse.x, Mouse.y))
			{
				if (Input.check(MouseButton.LEFT))
				{
					_graphic = down;
				}
				else
				{
					_graphic = hover;
				}
			}
			else
			{
				_graphic = normal;
			}
		}
		else
		{
			_graphic = inactive;
		}
		super.update(elapsed);
	}

	private var normal:Graphic;
	private var hover:Graphic;
	private var down:Graphic;
	private var inactive:Graphic;

}
