package haxepunk.graphics.hardware;

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Rectangle;
import haxepunk.utils.Color;
import haxepunk.graphics.shader.ColorShader;

@:access(haxepunk.Scene)
@:access(haxepunk.graphics.hardware.DrawCommand)
@:allow(haxepunk.graphics.atlas.AtlasData)
@:dox(hide)
class SceneSprite extends Sprite
{
	public function new(scene:Scene)
	{
		super();
		this.scene = scene;

		var oglView = new flash.display.OpenGLView();
		addChild(oglView);
		oglView.render = renderScene;
		batch = new DrawCommandBatch();
	}

	public function startFrame()
	{
		batch.recycle();
		HXP.screen.renderer.startFrame(scene);

		if (scene.alpha > 0)
		{
			// draw the scene background
			var command = batch.getDrawCommand(null, ColorShader.defaultShader, false, BlendMode.ALPHA, null);
			var sceneColor:Color = scene.color == null ? HXP.stage.color : scene.color,
				alpha = scene.alpha;
			var w = HXP.width * scene.camera.fullScaleX,
				h = HXP.height * scene.camera.fullScaleY;
			command.addTriangle(0, 0, 0, 0, w, 0, 0, 0, 0, h, 0, 0, sceneColor, alpha);
			command.addTriangle(0, h, 0, 0, w, 0, 0, 0, w, h, 0, 0, sceneColor, alpha);
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
