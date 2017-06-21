package haxepunk.debug;

import haxepunk.graphics.Image;
import haxepunk.input.MouseManager;

class ButtonTray extends EntityList<DebugButton>
{
	public function new(
		mouseManager:MouseManager,
		onHide:Void->Void,
		onPause:Void->Void,
		onStep:Void->Void
	)
	{
		super();
		inline function addButton(img:String, f:Void->Void)
		{
			var btn = new DebugButton(img, mouseManager, f);
			btn.x = width;
			width += btn.width;
			add(btn);
		}
		addButton("graphics/debug/console_visible.png", onHide);
		addButton("graphics/debug/console_pause.png", onPause);
		addButton("graphics/debug/console_step.png", onStep);
		addButton("graphics/debug/console_drawcall_add.png", incrementDrawCallDebug);
		addButton("graphics/debug/console_drawcall_all.png", resetDrawCallDebug);
	}

	function resetDrawCallDebug()
	{
		haxepunk.graphics.hardware.Renderer.drawCallLimit = -1;
	}

	function incrementDrawCallDebug()
	{
		haxepunk.graphics.hardware.Renderer.drawCallLimit++;
	}
}
