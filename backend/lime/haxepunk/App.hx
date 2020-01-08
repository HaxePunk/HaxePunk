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
			#if (openfl >= "8.9.2")
			var renderer:openfl._internal.renderer.context3D.Context3DRenderer = cast event.renderer;
			#else
			var renderer:openfl.display.OpenGLRenderer = cast event.renderer;
			haxepunk.graphics.hardware.opengl.GLInternal.gl = renderer.gl;
			#end
			haxepunk.graphics.hardware.opengl.GLInternal.renderer = renderer;
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
