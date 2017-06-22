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
		HXP.screen.renderer.startFrame();
		for (scene in HXP.engine)
		{
			renderScene(scene, rect);
		}
		HXP.screen.renderer.endFrame();
	}

	inline function renderScene(scene:Scene, rect:Rectangle)
	{
		scene.renderer.renderScene(rect);
	}

	public function startScene(scene:Scene) {}

	public function endScene(scene:Scene) {}
}
