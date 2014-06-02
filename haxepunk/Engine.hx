package haxepunk;

import lime.Lime;
import lime.utils.Matrix3D;
import haxepunk.scene.Scene;

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
		HXP.windowWidth = HXP.lime.config.width;
		HXP.windowHeight = HXP.lime.config.height;

		scene.draw();
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

	private var _scenes:List<Scene>;

}
