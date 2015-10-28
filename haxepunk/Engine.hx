package haxepunk;

import haxepunk.math.Math;
import haxepunk.math.Matrix4;
import haxepunk.scene.Scene;
import haxepunk.graphics.Material;
import haxepunk.renderers.Renderer;
import haxepunk.inputs.Input;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.RenderContext;

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

	override public function exec():Int
	{
		HXP.window = windows[0];

		HXP.window.onResize.add(setViewport);
		setViewport(HXP.window.width, HXP.window.height);

		// Init the input system
		Input.init(HXP.window);

		switch (HXP.window.renderer.context)
		{
			#if flash
			case FLASH(stage):
				Renderer.init(stage, ready);
			#end
			case OPENGL(gl):
				ready();
			default:
				throw "Rendering context is not supported!";
		}

		return super.exec();
	}

	/**
	 * This function is called when the engine is ready. All initialization code should go here.
	 */
	public function ready() { }

	private function setViewport(windowWidth:Int, windowHeight:Int)
	{
		if (scene.width == 0) scene.width = HXP.window.width;
		if (scene.height == 0) scene.height = HXP.window.height;
		var x = 0, y = 0, width = scene.width, height = scene.height;
		switch (HXP.scaleMode)
		{
			case NoScale:
				x = Std.int((windowWidth - width) / 2);
				y = Std.int((windowHeight - height) / 2);
			case LetterBox:
				var scale = windowWidth / width;
				if (scale * height > windowHeight)
				{
					scale = windowHeight / height;
				}
				width = Std.int(width * scale);
				height = Std.int(height * scale);
				x = Std.int((windowWidth - width) / 2);
				y = Std.int((windowHeight - height) / 2);
			case Stretch:
				width = windowWidth;
				height = windowHeight;
		}
		Renderer.setViewport(x, y, width, height);
	}

	override public function render(renderer:lime.graphics.Renderer):Void
	{
		var time = haxe.Timer.stamp();
		scene.draw();
		HXP.renderTime = time - haxe.Timer.stamp();

		#if flash
		// must reset program and texture at end of each frame...
		Renderer.bindProgram();
		Renderer.bindTexture(null, 0);
		#end
	}

	override public function update(deltaTime:Int):Void
	{
		var time = haxe.Timer.stamp();
		scene.update(deltaTime / 1000.0);

		// Update the input system
		Input.update();
		HXP.updateTime = time - haxe.Timer.stamp();
	}

	/**
	 * Replaces the current scene
	 * @param scene The replacement scene
	 */
	public function replaceScene(scene:Scene):Scene
	{
		_scenes.pop();
		_scenes.push(scene);
		return HXP.scene = scene;
	}

	/**
	 * Pops a scene from the stack
	 */
	public function popScene():Scene
	{
		// should always have at least one scene
		return HXP.scene = (_scenes.length > 1 ? _scenes.pop() : _scenes.first());
	}

	/**
	 * Pushes a scene (keeping the old one to use later)
	 * @param scene The scene to push
	 */
	public function pushScene(scene:Scene):Scene
	{
		_scenes.push(scene);
		return HXP.scene = scene;
	}

	private var _scenes:List<Scene>;

}
