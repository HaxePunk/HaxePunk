package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Rectangle;
import haxepunk.utils.Color;

@:access(haxepunk.Scene)
@:access(haxepunk.graphics.atlas.DrawCommand)
@:allow(haxepunk.graphics.atlas.AtlasData)
@:dox(hide)
class SceneSprite extends Sprite
{
	public function new(scene:Scene)
	{
		super();
		this.scene = scene;
#if hardware_render
		var oglView = new flash.display.OpenGLView();
		addChild(oglView);
		oglView.render = renderScene;
		batch = new DrawCommandBatch();
#end
	}

	public function startFrame()
	{
		batch.recycle();
		HXP.screen.renderer.startFrame(scene);

		if (scene.alpha > 0)
		{
			// draw the scene background
			var command = batch.getDrawCommand(null, false, BlendMode.ALPHA);
			var sceneColor:Color = scene.color == null ? HXP.stage.color : scene.color;
			var red = sceneColor.red,
				green = sceneColor.green,
				blue = sceneColor.blue,
				alpha = scene.alpha;
			var w = HXP.width * HXP.screen.fullScaleX,
				h = HXP.height * HXP.screen.fullScaleY;
			command.addTriangle(0, 0, 0, 0, w, 0, 0, 0, 0, h, 0, 0, red * alpha, green * alpha, blue * alpha, alpha);
			command.addTriangle(0, h, 0, 0, w, 0, 0, 0, w, h, 0, 0, red * alpha, green * alpha, blue * alpha, alpha);
		}
	}

	public function endFrame()
	{
		HXP.screen.renderer.endFrame(scene);
	}

	public function renderScene(rect:Rectangle)
	{
		if (scene._drawn && scene.visible)
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
