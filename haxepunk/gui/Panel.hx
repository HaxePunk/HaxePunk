package haxepunk.gui;

import haxepunk.graphics.NineSlice;
import haxepunk.math.Rectangle;

class Panel extends ControlGroup
{

	public function new(x:Float=0, y:Float=0, width:Float=32, height:Float=32)
	{
		var panel = new NineSlice(Control.defaultSkin, new Rectangle(48, 0, 16, 16));
		panel.setSize(width, height);
		super(x, y, width, height);
		hitbox.width = width;
		hitbox.height = height;
		addGraphic(panel);
	}

}
