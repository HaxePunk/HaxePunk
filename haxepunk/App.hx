package haxepunk;

import kha.Scheduler;
import kha.System;
import kha.Window;
import kha.input.Keyboard;

class App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return System.isFullScreen();
	inline function set_fullscreen(value:Bool):Bool
	{
		if(value)
			System.requestFullscreen();
		else
			System.exitFullscreen();
		return value;
	}

	public function init()
	{
		System.start({title: "Project", width: 1024, height: 768, framebuffer: {frequency: HXP.assignedFramerate}}, function(window)
		{
			// TODO : a better way to do this
			Assets.loadEverything(onStage.bind(window));
		});
	}

	// TODO : System.time or Scheduler.time() ?
	public function getTimeMillis():Float return System.time;

	// TODO : figure out a way to get that info from Kha
	public function multiTouchSupported():Bool return false;

	// TODO : figure out if we want that functional or deleted
	public function getMouseX():Float
	{
		return 0;
	}
	public function getMouseY():Float
	{
		return 0;
	}

	/// ###############
	/// # Private API #
	/// ###############

	private var _engine:Engine;
	private var _window:Window;

	@:allow(haxepunk.Engine.createApp)
	private function new(engine:Engine)
	{
		_engine = engine;
	}

	/**
	 * @private Event handler for stage entry.
	 * @param window Kha window linked to the running System.
	 */
	@:access(haxepunk.Engine)
	private function onStage(window:Window)
	{
		_window = window;
		setStageProperties();

		// Use the engine's render method
		// TODO : frames have to be passed to the engine, and the engine has to accept them as params
		System.notifyOnFrames(function (frames) _engine.onRender());

		// Enable input
		// TODO : this is all backend code
		initKeyInput();
		initMouseInput();
		initGamepadInput();
		if(multiTouchSupported())
			initTouchInput();
		
		_engine.checkScene();

		// Game start
		_engine.init();

		// Start game loop
		// TODO : Engine can do that on its own
		_engine._rate = 1000 / HXP.assignedFramerate;

		// Nonfixed framerate
		_engine._last = getTimeMillis();
		Scheduler.addFrameTask(onEnterFrame);
		
		// TODO : catch application closing and call _engine.close()
		// On mobile, use the shutdownListener in System.notifyOnApplicationState()
		// On other targets, figure out if we can and how to do it

		#if hxp_debug_console
		Console.enabled = true;
		#end
	}

	/**
	 * @private Sets the game's stage properties. Override this to set them differently.
	 */
	private function setStageProperties(window:Window)
	{
		// framerate set in System.start
		// nnf align
		// nnf quality
		// nnf scale mode
		// nnf display state

		// nnf screen color

		_resize(_window.width, _window.height); // call once to initialize the screen

		// Set resize event
		_window.notifyOnResize(_resize);

		// TODO : Set onFocus event ???
		HXP.focused = true;

		// TODO : Set onFocusLost event ???

		// nnf rotate interface ?
	}

	// TODO : this is all backend code
	private function initKeyInput()
	{
		var keyboard = Keyboard.get();
		keyboard.notify(Key.onKeyDown, Key.onKeyUp, Key.onCharacter);
	}
	private function initMouseInput() { }
	private function initGamepadInput() { }
	private function initTouchInput() { }

	private function onEnterFrame()
	{
		_engine.onUpdate();
	}

	/**
	 * @private Event handler for stage resize.
	 */
	private function _resize(newWidth:Int, newHeight:Int)
	{
		if(HXP.width == 0 || HXP.height == 0)
		{
			// Set initial size
			HXP.width = newWidth;
			HXP.height = newHeight;
			HXP.screen.scaleMode.setBaseSize();
		}
		// Calculate scale from width/height values
		HXP.resize(newWidth, newHeight);
		// nnf scrollRect (i don't think ?)
		_engine.onResize.invoke();
	}
}
