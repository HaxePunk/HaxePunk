package haxepunk;

import haxepunk.math.Math;
import haxepunk.math.Matrix3D;
import haxepunk.scene.Scene;
import haxepunk.graphics.Material;
import haxepunk.input.Input;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.ui.Window;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Engine extends Application
{

	public var scene(get, set):Scene;
	private inline function get_scene():Scene { return _scenes.first(); }
	private inline function set_scene(scene:Scene):Scene { return replaceScene(scene); }

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
		HXP.context = HXP.window.currentRenderer.context;

		// Init the input system
		Input.init();

		switch (HXP.context)
		{
			#if flash
			case FLASH(stage):
				HXP.renderer = new haxepunk.renderers.FlashRenderer(stage, ready);
			#else
			case OPENGL(gl):
				HXP.renderer = new haxepunk.renderers.GLRenderer(gl);
				ready();
			#end
			default:
				throw "Unsupported renderer";
		}
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function ready() { }

	override public function render(context:RenderContext):Void
	{
		// make sure the render context stays updated
		HXP.context = context;
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

		scene.update(deltaTime / 1000.0);

		// Update the input system
		Input.update();
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public function replaceScene(scene:Scene):Scene
	{
		_scenes.pop();
		_scenes.push(scene);
		return scene;
	}

	/**
	 * Pops a scene from the stack
	 */
	public function popScene():Scene
	{
		// should always have at least one scene
		return (_scenes.length > 1 ? _scenes.pop() : _scenes.first());
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public function pushScene(scene:Scene):Scene
	{
		_scenes.push(scene);
		return scene;
	}

	private var _scenes:List<Scene>;

}
