package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.graphics.Text;
import haxepunk.math.Rectangle;
import haxepunk.inputs.Input;
import haxepunk.inputs.Mouse;
import lime.app.Event;

class Button extends Control
{

	public var onClick:Event<Void->Void>;

	public function new(label:String="Button", x:Float=0, y:Float=0, width:Float=16, height:Float=16)
	{
		var background = new NineSlice(Control.defaultSkin, new Rectangle(0, 96, 8, 8));
		var text = new Text(label);
		super(x, y, width, height);
		hitbox.width = background.width = width;
		hitbox.height = background.height = height;
		addGraphic(background);
		addGraphic(text);

		onClick = new Event<Void->Void>();
	}

	override public function update(elapsed:Float)
	{
		if (Input.pressed(MouseButton.LEFT) > 0)
		{
		}
		super.update(elapsed);
	}

}
