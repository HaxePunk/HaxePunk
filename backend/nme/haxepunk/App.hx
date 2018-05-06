package haxepunk;

import nme.display.OpenGLView;
import nme.geom.Rectangle;

class App extends haxepunk._internal.FlashApp
{
	override function initRenderer()
	{
		// create an OpenGLView object and use the engine's render method
		var view = new OpenGLView();
		view.render = function(rect:Rectangle)
		{
			engine.onRender();
		};
		addChild(view);
	}
}
