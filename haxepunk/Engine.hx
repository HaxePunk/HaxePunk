package haxepunk;

import haxepunk.math.Math;
import haxepunk.math.Matrix3D;
import haxepunk.scene.Scene;
import haxepunk.graphics.Material;
// import haxepunk.input.Input;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;
import lime.ui.Window;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Engine extends Application
{

	public var scene(get, never):Scene;
	private inline function get_scene():Scene { return _scenes.first(); }

	public function new(?scene:Scene)
	{
		super();
		_scenes = new List<Scene>();
		pushScene(scene == null ? new Scene() : scene);
	}

	override public function create(config:Config):Void
	{
		super.create(config);

		HXP.window = windows[0];
		// HXP.input = new Input();

		init();
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function init()
	{
		throw "Override the init function to begin";
	}

	override public function render(context:RenderContext):Void
	{
		scene.draw();

		Material.clear(); // clear any material
	}

	override public function update(deltaTime:Int):Void
	{
#if ((neko || cpp) && HXP_BACKGROUND_LOAD)
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

		// handle time wrapping by negating the last time by the max Int value
		// not sure this is worth it since the game would have to be running almost 19 days straight
		if (deltaTime < _lastTime) _lastTime -= Math.INT_MAX_VALUE;

		var elapsed:Float = (deltaTime - _lastTime) / 1000.0;
		scene.update(elapsed);
		_lastTime = deltaTime;
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
	private var _lastTime:Int = 0;
}
