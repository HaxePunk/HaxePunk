package haxepunk.debug;

import haxepunk.graphics.Image;
import haxepunk.graphics.NineSlice;
import haxepunk.input.MouseManager;

class DebugButton extends Entity
{
	var bg:NineSlice;
	var icon:Image;

	public function new(img:String, mouseManager:MouseManager, onPress:Void->Void)
	{
		super();
		bg = new NineSlice("graphics/debug/button.png", 8, 8, 8, 8);
		bg.alpha = 0.5;
		addGraphic(bg);

		icon = new Image(img);
		icon.smooth = true;
		addGraphic(icon);

		type = mouseManager.type;
		mouseManager.add(this, null, onPress, onEnter, onExit);

		width = height = 64;
	}

	override public function update()
	{
		super.update();
		bg.width = width;
		bg.height = height;
		icon.x = (width - icon.width) / 2;
		icon.y = (height - icon.height) / 2;
	}

	function onEnter() bg.alpha = 1;
	function onExit() bg.alpha = 0.5;
}
