package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;

class EntityCounter extends Sprite
{
	public var selectable(get, set):Bool;
	function get_selectable():Bool return textField.selectable;
	function set_selectable(value:Bool):Bool return textField.selectable = value;

	public function new()
	{
		super();
		this.addChild(textField);
		textField.defaultTextFormat = Format.format(16, 0xFFFFFF, "right");
		textField.width = 100;
		textField.height = 20;
		this.x = width - textField.width;

		// The entity count panel.
		this.graphics.clear();
		this.graphics.beginFill(0, .5);
		this.graphics.drawRoundRect(0, -20, textField.width + 20, 40, 40, 40);
	}

	public function update()
	{
		this.x = HXP.windowWidth - textField.width;
		var numEntities = HXP.scene.count;
		if (count != numEntities)
		{
			count = numEntities;
			textField.text = Std.string(count) + " Entities";
		}
	}

	var count:Int = 0;
	var textField = new TextField();
}
