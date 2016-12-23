package haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;

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
		Renderer.startFrame(scene);

		if (scene.alpha > 0)
		{
			// draw the scene background
			var command = getDrawCommand(null, false, BlendMode.Normal);
			var sceneColor = scene.color == null ? HXP.stage.color : scene.color;
			var red = HXP.getRed(sceneColor) / 255,
				green = HXP.getGreen(sceneColor) / 255,
				blue = HXP.getBlue(sceneColor) / 255;
			var w = HXP.width * HXP.screen.fullScaleX,
				h = HXP.height * HXP.screen.fullScaleY;
			command.addTriangle(0, 0, 0, 0, w, 0, 0, 0, 0, h, 0, 0, red, green, blue, scene.alpha);
			command.addTriangle(0, h, 0, 0, w, 0, 0, 0, w, h, 0, 0, red, green, blue, scene.alpha);
		}
	}

	public function endFrame()
	{
		Renderer.endFrame(scene);
	}

	public function getDrawCommand(texture:BitmapData, smooth:Bool, blend:BlendMode)
	{
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
			var currentDraw:DrawCommand = draw;
			while (currentDraw != null)
			{
				Renderer.render(currentDraw, scene, rect);
				currentDraw = currentDraw._next;
			}
		}
	}

	var scene:Scene;
	var draw:DrawCommand;
	var last:DrawCommand;
}
