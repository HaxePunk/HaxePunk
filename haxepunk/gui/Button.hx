package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.graphics.Text;
import haxepunk.graphics.Color;
import haxepunk.math.Rectangle;
import haxepunk.inputs.Input;
import haxepunk.inputs.Mouse;
import lime.app.Event;

class Button extends Control
{

	public var text(default, null):Text;
	public var onClick:Event<Void->Void>;

	public function new(label:String, x:Float=0, y:Float=0, width:Float=16, height:Float=16)
	{
		var background = new NineSlice(Control.defaultSkin, new Rectangle(0, 96, 8, 8));
		text = new Text(label);
		super(x, y, width, height);
		hitbox.width = width;
		hitbox.height = height;
		addGraphic(background);
		addGraphic(text);
		text.centerOrigin();
		var padding = 10;
		background.setSize(text.width + padding * 2, text.height + padding * 2);
		background.centerOrigin();

		onClick = new Event<Void->Void>();
	}

	override public function update(elapsed:Float)
	{
		if (Input.pressed(MouseButton.LEFT) > 0)
		{
			trace("pressed");
		}
		super.update(elapsed);
	}

}
