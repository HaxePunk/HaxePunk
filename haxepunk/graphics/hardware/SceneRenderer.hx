package haxepunk.graphics.hardware;

import flash.geom.Rectangle;

@:access(haxepunk.Scene)
@:access(haxepunk.graphics.hardware.DrawCommand)
@:allow(haxepunk.graphics.atlas.AtlasData)
@:dox(hide)
class SceneRenderer
{
	public function new(scene:Scene)
	{
		this.scene = scene;
		batch = new DrawCommandBatch();
	}

	public function startFrame()
	{
		batch.recycle();
		HXP.screen.renderer.startScene(scene);
	}

	public function endFrame()
	{
		HXP.screen.renderer.flushScene(scene);
	}

	/**
	 * Called to render all data to the screen.
	 */
	public function renderScene(rect:Rectangle)
	{
		if (scene.visible)
		{
			HXP.screen.renderer.startScene(scene);
			var currentDraw:DrawCommand = batch.head;
			while (currentDraw != null)
			{
				HXP.screen.renderer.render(currentDraw, scene, rect);
				currentDraw = currentDraw._next;
			}
			HXP.screen.renderer.flushScene(scene);
		}
	}

	var scene:Scene;
	var batch:DrawCommandBatch;
}
