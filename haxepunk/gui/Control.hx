package haxepunk.gui;

import haxepunk.scene.Entity;
import haxepunk.inputs.Mouse;
import haxepunk.scene.Scene;

class Control extends Entity
{
	public static var defaultSkin:String = "graphics/gui/defaultSkin.png";

	public var width(get, set):Float;
	private inline function get_width():Float { return hitbox.width; }
	private inline function set_width(value:Float):Float { return hitbox.width = value; }

	public var height(get, set):Float;
	private inline function get_height():Float { return hitbox.height; }
	private inline function set_height(value:Float):Float { return hitbox.height = value; }

	public var label(default, null):Label;

	public var padding:Int = 10;

	public function new(x:Float=0, y:Float=0, ?text:String)
	{
		super(x, y);
		if (text != null)
		{
			label = new Label(text);
			width = label.width + padding * 2;
			height = label.height + padding * 2;
		}
	}

	override private function set_scene(value:Scene):Scene
	{
		if (label != null)
		{
			if (value == null)
			{
				scene.remove(label);
			}
			else
			{
				value.add(label);
			}
		}
		return super.set_scene(value);
	}

}
