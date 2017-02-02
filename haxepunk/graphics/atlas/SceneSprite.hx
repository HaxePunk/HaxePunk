package haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Rectangle;
import haxepunk.utils.Color;

@:access(haxepunk.Scene)
@:access(haxepunk.graphics.atlas.DrawCommand)
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
#end
	}

	public function startFrame()
	{
		if (draw != null) draw.recycle();
		draw = last = null;
		HXP.screen.renderer.startFrame(scene);

		if (scene.alpha > 0)
		{
			// draw the scene background
			var command = getDrawCommand(null, false, BlendMode.ALPHA);
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

	public function getDrawCommand(texture:BitmapData, smooth:Bool, ?blend:BlendMode)
	{
		if (blend == null) blend = BlendMode.ALPHA;

		if (last != null && last.texture == texture && last.smooth == smooth && last.blend == blend)
		{
			return last;
		}
		var command = DrawCommand.create(texture, smooth, blend);
		if (last == null)
		{
			draw = last = command;
		}
		else
		{
			last._next = command;
			last = command;
		}
		return command;
	}

	public function renderScene(rect:Rectangle)
	{
		if (scene._drawn && scene.visible)
		{
			HXP.screen.renderer.startScene(scene);
			var currentDraw:DrawCommand = draw;
			while (currentDraw != null)
			{
				HXP.screen.renderer.render(currentDraw, scene, rect);
				currentDraw = currentDraw._next;
			}
			HXP.screen.renderer.flushScene(scene);
		}
	}

	var scene:Scene;
	var draw:DrawCommand;
	var last:DrawCommand;
}
