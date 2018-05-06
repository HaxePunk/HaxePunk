package haxepunk;

class App extends haxepunk._internal.FlashApp
{
	#if (openfl >= "8.0.0")
	override function onEnterFrame(e)
	{
		invalidate();
		super.onEnterFrame(e);
	}
	#end

	override function initRenderer()
	{
		#if (openfl >= "8.0.0")
		// use the RenderEvent API
		addEventListener(openfl.events.RenderEvent.RENDER_OPENGL, function(event) {
			var renderer = event.renderer;
			haxepunk.graphics.hardware.opengl.GLInternal.renderer = cast event.renderer;
			haxepunk.graphics.hardware.opengl.GLInternal.gl = cast event.renderer.gl;
			engine.onRender();
		});
		#else
		// create an OpenGLView object and use the engine's render method
		var view = new openfl.display.OpenGLView();
		view.render = function(rect:openfl.geom.Rectangle)
		{
			engine.onRender();
		};
		addChild(view);
		#end
	}
}
