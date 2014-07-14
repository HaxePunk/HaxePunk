package haxepunk;

import haxepunk.math.Math;
import haxepunk.math.Matrix4;
import haxepunk.scene.Scene;
import haxepunk.graphics.Material;
import haxepunk.renderers.Renderer;
import haxepunk.input.Input;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;
import lime.ui.Window;

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

		// Init the input system
		Input.init();

		switch (HXP.window.currentRenderer.context)
		{
			#if flash
			case FLASH(stage):
				Renderer.init(stage, ready);
			#elseif (js && canvas)
			case CANVAS(canvas):
				Renderer.init(canvas);
				ready();
			#end
			default:
				ready();
		}
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function ready()
	{
		Renderer.setViewport(0, 0, HXP.window.width, HXP.window.height);
	}

	override public function render(context:RenderContext):Void
	{
		scene.draw();

		// must reset program and texture at end of each frame...
		Renderer.bindProgram(null);
		Renderer.bindTexture(null, 0);
	}

	override public function update(deltaTime:Int):Void
	{
		// Update the input system
		Input.update();

		scene.update(deltaTime / 1000.0);
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
