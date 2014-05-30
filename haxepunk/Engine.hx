package haxepunk;

import lime.Lime;
import lime.gl.GL;
import lime.utils.Matrix3D;
import haxepunk.scene.Scene;

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
		_lime = lime;
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
		HXP.windowWidth = _lime.config.width;
		HXP.windowHeight = _lime.config.height;

		scene.draw();
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

	private var _lime:Lime;
	private var _scenes:List<Scene>;

}
