package haxepunk;

import lime.Lime;
import haxepunk.math.Matrix3D;
import haxepunk.scene.Scene;
import haxepunk.graphics.Material;
import haxepunk.input.Input;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Engine
{

	public var scene(get, never):Scene;
	private inline function get_scene():Scene { return _scenes.first(); }

	public function new(?scene:Scene)
	{
		_scenes = new List<Scene>();
		pushScene(scene == null ? new Scene() : scene);
	}

	public function ready(lime:Lime):Void
	{
		HXP.lime = lime;
		HXP.windowWidth = lime.config.width;
		HXP.windowHeight = lime.config.height;

		Input.init();

		init();
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function init()
	{
		throw "Override the init function to begin";
	}

	private function render():Void
	{
		scene.draw();

		Material.clear(); // clear any material
	}

	private function update():Void
	{
#if (neko || cpp)
		var msg = Thread.readMessage(false);
		if (msg != null)
		{
			switch (msg.type)
			{
				case "loadTexture":
					msg.texture.createTexture(msg.width, msg.height, msg.data);
			}
		}
#end

		scene.update();

		Input.update();
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public function replaceScene(scene:Scene)
	{
		_scenes.pop();
		_scenes.push(scene);
	}

	/**
	 * Pops a scene from the stack
	 */
	public function popScene()
	{
		// should always have at least one scene
		if (_scenes.length > 1)
		{
			_scenes.pop();
		}
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public function pushScene(scene:Scene)
	{
		_scenes.push(scene);
	}


	// Lime exposed event callbacks, is passed to Input
	private function onmousedown(_event:Dynamic)
	{
		Input.onmousedown(_event);
	}

	// Lime exposed event callbacks, is passed to Input
	private function onmouseup(_event:Dynamic)
	{
		Input.onmouseup(_event);
	}

	// Lime exposed event callbacks, is passed to Input
	private function onmousemove(_event:Dynamic)
	{
		Input.onmouseup(_event);
	}

	private function onkeydown(_event:Dynamic)
	{
		Input.onkeydown(_event);
	}

	private function onkeyup(_event:Dynamic)
	{
		Input.onkeyup(_event);
	}

	// TODO: add other callbacks



	private var _scenes:List<Scene>;
}
