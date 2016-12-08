package com.haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;

@:access(com.haxepunk.graphics.atlas.DrawCommand)
class SceneSprite extends Sprite
{
	public function new(scene:Scene)
	{
		super();
		this.scene = scene;
#if tile_shader
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
		var currentDraw:DrawCommand = draw;
		while (currentDraw != null)
		{
			Renderer.render(currentDraw, scene, rect);
			currentDraw = currentDraw._next;
		}
	}

	var scene:Scene;
	var draw:DrawCommand;
	var last:DrawCommand;
}
