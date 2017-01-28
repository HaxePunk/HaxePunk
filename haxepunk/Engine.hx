package haxepunk;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import haxepunk.utils.Draw;
import haxepunk.input.Input;
import haxepunk.utils.Random;

/**
 * Main game Sprite class, added to the Flash Stage.
 * Manages the game loop.
 * 
 * Your main class **needs** to extends this.
 */
class Engine extends Sprite
{
	/**
	 * If the game should stop updating/rendering.
	 */
	public var paused:Bool;

	/**
	 * Cap on the elapsed time (default at 30 FPS). Raise this to allow for lower framerates (eg. 1 / 10).
	 */
	public var maxElapsed:Float;

	/**
	 * The max amount of frames that can be skipped in fixed framerate mode.
	 */
	public var maxFrameSkip:Int;

	/**
	 * The amount of milliseconds between ticks in fixed framerate mode.
	 */
	public var tickRate:Int;

	/**
	 * Constructor. Defines startup information about your game.
	 * @param	width			The width of your game.
	 * @param	height			The height of your game.
	 * @param	frameRate		The game framerate, in frames per second.
	 * @param	fixed			If a fixed-framerate should be used.
	 * @param   renderMode      Overrides the default render mode for this target
	 */
	public function new(width:Int = 0, height:Int = 0, frameRate:Float = 60, fixed:Bool = false, ?renderMode:RenderMode)
	{
		super();

		// global game properties
		HXP.bounds = new Rectangle(0, 0, width, height);
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;

		// global game objects
		HXP.engine = this;
		HXP.width = width;
		HXP.height = height;

		if (renderMode != null)
		{
			HXP.renderMode = renderMode;
		}
		else
		{
			HXP.renderMode = #if (flash) RenderMode.BUFFER #else RenderMode.HARDWARE #end;
		}

		// miscellaneous startup stuff
		if (Random.randomSeed == 0) Random.randomizeSeed();

		HXP.entity = new Entity();
		HXP.time = Lib.getTimer();

		paused = false;
		maxElapsed = 0.0333;
		maxFrameSkip = 5;
		tickRate = 4;
		_frameList = new Array();

		// on-stage event listener
#if flash
		if (Lib.current.stage != null) onStage();
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);
#else
		addEventListener(Event.ADDED_TO_STAGE, onStage);
		Lib.current.addChild(this);
#end
	}

	/**
	 * Override this, called after Engine has been added to the stage.
	 */
	public function init() {}

	/**
	 * Override this, called when game gains focus
	 */
	public function focusGained() {}

	/**
	 * Override this, called when game loses focus
	 */
	public function focusLost() {}

	/**
	 * Updates the game, updating the Scene and Entities.
	 */
	public function update()
	{
		_scene.updateLists();
		checkScene();
		if (HXP.tweener.active && HXP.tweener.hasTween) HXP.tweener.updateTweens();
		if (_scene.active)
		{
			if (_scene.hasTween) _scene.updateTweens();
			_scene.update();
		}
		_scene.updateLists(false);
		HXP.screen.update();
	}

	/**
	 * Renders the game, rendering the Scene and Entities.
	 */
	@:dox(hide)
	public function render()
	{
		if (HXP.screen.needsResize) HXP.resize(HXP.windowWidth, HXP.windowHeight);

		// timing stuff
		var t:Float = Lib.getTimer();
		if (_frameLast == 0) _frameLast = Std.int(t);

		// render loop
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			HXP.screen.swap();
			HXP.screen.refresh();
		}
		Draw.resetTarget();

		if (_scenes.length > 0)
		{
			// find the last visible scene, falling through transparent scenes
			var visibleScene:Int = _scenes.length - 1;
			while (_scenes[visibleScene].alpha < 1 && visibleScene > 0)
			{
				--visibleScene;
			}
			for (i in 0 ... visibleScene)
			{
				_scenes[i]._drawn = false;
			}
			// render all visible scenes back to front
			while (visibleScene < _scenes.length)
			{
				var scene = _scenes[visibleScene++];
				scene._drawn = true;
				if (scene.visible) scene.render();
			}
		}

		if (HXP.renderMode == RenderMode.BUFFER)
		{
			HXP.screen.redraw();
		}

		// more timing stuff
		t = Lib.getTimer();
		_frameListSum += (_frameList[_frameList.length] = Std.int(t - _frameLast));
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	/**
	 * Sets the game's stage properties. Override this to set them differently.
	 */
	function setStageProperties()
	{
		HXP.stage.frameRate = HXP.assignedFrameRate;
		HXP.stage.align = StageAlign.TOP_LEFT;
#if !js
		HXP.stage.quality = StageQuality.HIGH;
#end
		HXP.stage.scaleMode = StageScaleMode.NO_SCALE;
		HXP.stage.displayState = StageDisplayState.NORMAL;

		resize(); // call resize once to initialize the screen

		// set resize event
		HXP.stage.addEventListener(Event.RESIZE, function (e:Event) resize());

		HXP.stage.addEventListener(Event.ACTIVATE, function (e:Event)
		{
			HXP.focused = true;
			focusGained();
			_scene.focusGained();
		});

		HXP.stage.addEventListener(Event.DEACTIVATE, function (e:Event)
		{
			HXP.focused = false;
			focusLost();
			_scene.focusLost();
		});

#if (!(flash || html5) && openfl_legacy)
		flash.display.Stage.shouldRotateInterface = function(orientation:Int):Bool
		{
			if (HXP.indexOf(HXP.orientations, orientation) == -1) return false;
			var tmp = HXP.height;
			HXP.height = HXP.width;
			HXP.width = tmp;
			resize();
			return true;
		}
#end
	}

	/** @private Event handler for stage resize */
	function resize()
	{
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.width = HXP.stage.stageWidth;
			HXP.height = HXP.stage.stageHeight;
			HXP.screen.scaleMode.setBaseSize();
		}
		// calculate scale from width/height values
		HXP.resize(HXP.stage.stageWidth, HXP.stage.stageHeight);
		_scrollRect.width = HXP.screen.width;
		_scrollRect.height = HXP.screen.height;
		scrollRect = _scrollRect;
	}

	/** @private Event handler for stage entry. */
	function onStage(?e:Event)
	{
		// remove event listener
#if flash
		if (e != null)
			Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);
		HXP.stage = Lib.current.stage;
		HXP.stage.addChild(this);
#else
		removeEventListener(Event.ADDED_TO_STAGE, onStage);
		HXP.stage = stage;
#end
		setStageProperties();

		// enable input
		Input.enable();

		// switch scenes
		checkScene();

		// game start
		Draw.init();
		init();

		// start game loop
		_rate = 1000 / HXP.assignedFrameRate;

		// nonfixed framerate
		_last = Lib.getTimer();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);

		// Warnings when forcing RenderMode
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			#if (!(flash || js) && debug)
			HXP.console.log(["Warning: Using RenderMode.BUFFER on native target may result in bad performance"]);
			#end
		}
		else
		{
			#if ((flash) && debug)
			HXP.console.log(["Warning: Using RenderMode.HARDWARE on flash target may result in corrupt graphics"]);
			#end
		}
	}

	/** @private Framerate independent game loop. */
	function onEnterFrame(e:Event)
	{
		_time = _gameTime = Lib.getTimer();
		HXP._systemTime = _time - _systemTime;
		_updateTime = _time;

		// update timer
		var elapsed = (_time - _last) / 1000;
		if (HXP.fixed)
		{
			_elapsed += elapsed;
			if (_elapsed > maxElapsed) _elapsed = maxElapsed;
			HXP.elapsed = 1 / HXP.assignedFrameRate;
			while (_elapsed > HXP.elapsed)
			{
				_elapsed -= HXP.elapsed;
				step();
			}
		}
		else
		{
			HXP.elapsed = elapsed;
			if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
			HXP.elapsed *= HXP.rate;
			step();
		}
		_last = _time;

		// update timer
		_time = _renderTime = Lib.getTimer();
		HXP._updateTime = _time - _updateTime;

		// render loop
		if (paused) _frameLast = _time; // continue updating frame timer
		else render();

		// update timer
		_time = _systemTime = Lib.getTimer();
		HXP._renderTime = _time - _renderTime;
		HXP._gameTime = _time - _gameTime;
	}

	function step()
	{
		// update input
		Input.update();

		// update loop
		if (!paused) update();

		// update console
		if (HXP.consoleEnabled()) HXP.console.update();

		Input.postUpdate();
	}

	/** @private Switch scenes if they've changed. */
	inline function checkScene()
	{
		if (_scene != null && _scenes.length > 0 && _scenes[_scenes.length - 1] != _scene)
		{
			_scene.end();
			_scene.updateLists();
			if (_scene.autoClear && _scene.hasTween) _scene.clearTweens();

			_scene = _scenes[_scenes.length - 1];

			addChild(_scene.sprite);
			HXP.camera = _scene.camera;
			_scene.updateLists();
			_scene.begin();
			_scene.updateLists();
		}
	}

	/**
	 * Push a scene onto the stack. It will not become active until the next update.
	 * @param value  The scene to push
	 * @since	2.5.3
	 */
	public function pushScene(value:Scene):Void
	{
		_scenes.push(value);
	}

	/**
	 * Pop a scene from the stack. The current scene will remain active until the next update.
	 * @since	2.5.3
	 */
	public function popScene():Scene
	{
		var scene = _scenes.pop();
		if (contains(scene.sprite))
		{
			removeChild(scene.sprite);
		}
		return scene;
	}

	/**
	 * The currently active Scene object. When you set this, the Scene is flagged
	 * to switch, but won't actually do so until the end of the current frame.
	 */
	public var scene(get, set):Scene;
	inline function get_scene():Scene return _scene;
	function set_scene(value:Scene):Scene
	{
		if (_scene == value) return value;
		if (_scenes.length > 0)
		{
			popScene();
		}
		_scenes.push(value);
		return _scene;
	}

	// Scene information.
	var _scene:Scene = new Scene();
	var _scenes:Array<Scene> = new Array<Scene>();

	// Timing information.
	var _delta:Float = 0;
	var _time:Float = 0;
	var _last:Float = 0;
	var _rate:Float = 0;
	var _skip:Float = 0;
	var _prev:Float = 0;
	var _elapsed:Float = 0;

	// Debug timing information.
	var _updateTime:Float = 0;
	var _renderTime:Float = 0;
	var _gameTime:Float = 0;
	var _systemTime:Float = 0;

	// FrameRate tracking.
	var _frameLast:Float = 0;
	var _frameListSum:Int = 0;
	var _frameList:Array<Int>;

	var _scrollRect:Rectangle = new Rectangle();
}
