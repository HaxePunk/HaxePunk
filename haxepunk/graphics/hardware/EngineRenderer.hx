package haxepunk.graphics.hardware;

import flash.display.OpenGLView;
import flash.geom.Rectangle;

@:access(haxepunk.Scene)
@:access(haxepunk.graphics.hardware.SceneRenderer)
@:access(haxepunk.graphics.hardware.DrawCommand)
class EngineRenderer extends OpenGLView
{
	public function new()
	{
		super();
		this.render = renderScenes;
	}

	function renderScenes(rect:Rectangle)
	{
		var renderer = HXP.screen.renderer;
		renderer.startFrame();
		for (scene in HXP.engine)
		{
			if (scene.visible)
			{
				renderer.startScene(scene);
				var currentDraw:DrawCommand = scene.batch.head;
				while (currentDraw != null)
				{
					renderer.render(currentDraw, scene, rect);
					currentDraw = currentDraw._next;
				}
				renderer.flushScene(scene);
			}
		}
		renderer.endFrame();
	}
}
