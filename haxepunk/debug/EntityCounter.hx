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
		addChild(textField);
	}

	public function update()
	{
		var numEntities = HXP.scene.count;
		x = HXP.windowWidth - textField.width;
		if (count != numEntities)
		{
			count = numEntities;
			textField.text = count + " " + (count == 1 ? "Entity" : "Entities");
			textField.setTextFormat(Format.format(16, 0xFFFFFF, "right"));
			textField.width = textField.textWidth + 20;
			textField.height = textField.textHeight + 4;

			graphics.clear();
			graphics.beginFill(0, 0.5);
			graphics.drawRoundRect(0, -20, textField.width + 20, 40, 40, 40);
		}
	}

	var count:Int = -1;
	var textField = new TextField();
}
