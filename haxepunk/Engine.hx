package haxepunk;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import haxepunk.Signal;
import haxepunk.debug.Console;
import haxepunk.graphics.hardware.EngineRenderer;
import haxepunk.input.Input;
import haxepunk.utils.Draw;
import haxepunk.math.Random;

/**
 * Main game Sprite class, added to the Stage.
 * Manages the game loop.
 *
 * Your main class **needs** to extends this.
 */
class Engine extends Sprite
{
	public var console:Console;

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
	 * Invoked before the update cycle begins each frame.
	 */
	public var preUpdate:Signal0 = new Signal0();
	/**
	 * Invoked after update cycle.
	 */
	public var postUpdate:Signal0 = new Signal0();
	/**
	 * Invoked before rendering begins each frame.
	 */
	public var preRender:Signal0 = new Signal0();
	/**
	 * Invoked after rendering completes.
	 */
	public var postRender:Signal0 = new Signal0();
	/**
	 * Invoked after the screen is resized.
	 */
	public var onResize:Signal0 = new Signal0();
	/**
	 * Invoked when input is received.
	 */
	public var onInputPressed:Signals = new Signals();
	/**
	 * Invoked when input is received.
	 */
	public var onInputReleased:Signals = new Signals();
	/**
	 * Invoked when the application is closed.
	 */
	public var onClose:Signal0 = new Signal0();

	/**
	 * Constructor. Defines startup information about your game.
	 * @param	width			The width of your game.
	 * @param	height			The height of your game.
	 * @param	frameRate		The game framerate, in frames per second.
	 * @param	fixed			If a fixed-framerate should be used.
	 */
	public function new(width:Int = 0, height:Int = 0, frameRate:Float = 60, fixed:Bool = false)
	{
		super();

		// global game properties
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;

		// global game objects
		HXP.engine = this;
		HXP.width = width;
		HXP.height = height;

		HXP.screen = new Screen();

		// miscellaneous startup stuff
		if (Random.randomSeed == 0) Random.randomizeSeed();

		HXP.entity = new Entity();
		HXP.time = Lib.getTimer();

		paused = false;
		maxElapsed = 0.0333;
		maxFrameSkip = 5;
		tickRate = 4;
		_frameList = new Array();

		scrollRect = new Rectangle();

		// on-stage event listener
		addEventListener(Event.ADDED_TO_STAGE, onStage);
		Lib.current.addChild(this);

		addChild(_renderSurface = new EngineRenderer());
		_iterator = new VisibleSceneIterator(this);
	}

	public var visibleScenes(get, never):VisibleSceneIterator;
	function get_visibleScenes():VisibleSceneIterator
	{
		_iterator.reset();
		return _iterator;
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
	 * Toggles between windowed and fullscreen modes
	 */
	public var fullscreen(default, set):Bool = false;
	inline function set_fullscreen(value:Bool):Bool
	{
		stage.displayState = value ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		return fullscreen = value;
	}

	/**
	 * Updates the game, updating the Scene and Entities.
	 */
	public function update()
	{
		HXP.screen.update();

		preUpdate.invoke();

		if (HXP.tweener.active && HXP.tweener.hasTween) HXP.tweener.updateTweens(HXP.elapsed);
		for (scene in _scenes)
		{
			if (scene.active)
			{
				if (scene.hasTween) scene.updateTweens(HXP.elapsed);
				scene.update();
			}
			scene.updateLists();
		}

		updateLists();

		postUpdate.invoke();
	}

	function updateLists()
	{
		inline function loopList(list:Array<Scene>, func:Scene->Void)
		{
			for (i in 0...list.length)
			{
				func(list[i]);
			}
			HXP.clear(list);
		}

		loopList(_remove, function(scene:Scene)
		{
			scene.end();
			scene.updateLists();
			if (scene.autoClear && scene.hasTween) scene.clearTweens();
			_scenes.remove(scene);
		});
		loopList(_add, function(scene:Scene)
		{
			scene.begin();
			scene.updateLists();
			_scenes.push(scene);
		});
	}

	public function topScene():Scene
	{
		return _scenes[_scenes.length-1];
	}

	/**
	 * Renders the game, rendering the Scene and Entities.
	 */
	@:dox(hide)
	public function render()
	{
		// timing stuff
		var t:Float = Lib.getTimer();
		if (_frameLast == 0) _frameLast = Std.int(t);

		preRender.invoke();

		for (scene in visibleScenes)
		{
			HXP.renderingScene = scene;
			scene.render();
		}
		HXP.renderingScene = null;

		postRender.invoke();

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
		stage.frameRate = HXP.assignedFrameRate;
		stage.align = StageAlign.TOP_LEFT;
#if !js
		stage.quality = StageQuality.HIGH;
#end
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.displayState = StageDisplayState.NORMAL;

		Graphic.defaultSmooth = stage.quality != StageQuality.LOW;

		resize(stage.stageWidth, stage.stageHeight); // call resize once to initialize the screen

		// set resize event
		stage.addEventListener(Event.RESIZE, function (e:Event) resize(stage.stageWidth, stage.stageHeight));

		stage.addEventListener(Event.ACTIVATE, function (e:Event)
		{
			HXP.focused = true;
			focusGained();
			for (scene in _scenes) scene.focusGained();
		});

		stage.addEventListener(Event.DEACTIVATE, function (e:Event)
		{
			HXP.focused = false;
			focusLost();
			for (scene in _scenes) scene.focusLost();
		});

#if (!html5 && openfl_legacy)
		flash.display.Stage.shouldRotateInterface = function(orientation:Int):Bool
		{
			if (HXP.indexOf(HXP.orientations, orientation) == -1) return false;
			var tmp = HXP.height;
			HXP.height = HXP.width;
			HXP.width = tmp;
			resize(stage.stageWidth, stage.stageHeight);
			return true;
		}
#end
	}

	/** @private Event handler for stage resize */
	function resize(width:Int, height:Int)
	{
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.width = width;
			HXP.height = height;
			HXP.screen.scaleMode.setBaseSize();
		}
		// calculate scale from width/height values
		HXP.windowWidth = width;
		HXP.windowHeight = height;
		HXP.screen.needsResize = true;

		onResize.invoke();
	}

	/** @private Event handler for stage entry. */
	function onStage(?e:Event)
	{
		// remove event listener
		removeEventListener(Event.ADDED_TO_STAGE, onStage);
		setStageProperties();

		// enable input
		Input.enable();

		// switch scenes
		updateLists();

		// game start
		init();

		// start game loop
		_rate = 1000 / HXP.assignedFrameRate;

		// nonfixed framerate
		_last = Lib.getTimer();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);

		#if (nme || openfl_legacy)
		Lib.stage.onQuit = function() {
			onClose.invoke();
			Lib.close();
		}
		#else
		openfl.Lib.current.stage.application.onExit.add(function(_) {
			onClose.invoke();
		});
		#end

		#if debug_console
		Console.enabled = true;
		#end
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
			HXP.elapsed = 1 / HXP.assignedFrameRate;
			if (_elapsed > HXP.elapsed * maxFrameSkip) _elapsed = HXP.elapsed * maxFrameSkip;
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
		if (!paused || Console.enabled) render();

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
		if (console != null) console.update();

		Input.postUpdate();
	}

	/**
	 * Color to clear the screen
	 * @since	4.0.0
	 **/
	public var clearColor(get, never):Null<Int>;
	inline function get_clearColor():Null<Int> return stage.color;

	public function replaceScene(scene:Scene)
	{
		for (scene in _scenes) remove(scene);
		add(scene);
	}

	/**
	 * Add a scene. It will not become active until the next update.
	 * @param value  The scene to push
	 * @since	2.5.3
	 */
	public function add(scene:Scene)
	{
		_add[_add.length] = scene;
	}

	/**
	 * Remove a scene. The current scenes will remain active until the next update.
	 * @since	2.5.3
	 */
	public function remove(scene:Scene)
	{
		_remove[_remove.length] = scene;
	}

	// Scene information.
	var _add:Array<Scene> = new Array<Scene>();
	var _remove:Array<Scene> = new Array<Scene>();
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

	var _renderSurface:EngineRenderer;
	var _iterator:VisibleSceneIterator;
}

@:access(haxepunk.Engine)
private class VisibleSceneIterator
{
	var engine:Engine;
	var i:Int = 0;

	public function new(engine:Engine)
	{
		this.engine = engine;
	}

	public inline function hasNext():Bool
	{
		return i < engine._scenes.length ||
			(i == engine._scenes.length && engine.console != null);
	}

	public inline function next():Scene
	{
		var next = i < engine._scenes.length ? engine._scenes[i] : engine.console;
		i++;
		return next;
	}

	public inline function reset():Void
	{
		var _scenes = engine._scenes;
		if (_scenes.length > 0)
		{
			// find the last visible scene, falling through transparent scenes
			i = _scenes.length - 1;
			while (_scenes[i].bgAlpha < 1 && i > 0)
			{
				--i;
			}
		}
	}
}
