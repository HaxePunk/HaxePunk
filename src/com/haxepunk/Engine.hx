package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.Timer;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.Tweener;

/**
 * Main game Sprite class, added to the Flash Stage. Manages the game loop.
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
	 */
	public function new(width:Int, height:Int, frameRate:Float = 60, fixed:Bool = false)
	{
		super();

		// global game properties
		HXP.bounds = new Rectangle(0, 0, width, height);
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;

		// global game objects
		HXP.engine = this;
		HXP.screen = new Screen();
		HXP.screen.resize(width, height);

		// miscellanious startup stuff
		if (HXP.randomSeed == 0) HXP.randomizeSeed();
		HXP.entity = new Entity();
		HXP.time = Lib.getTimer();

		paused = false;
		maxElapsed = 0.0333;
		maxFrameSkip = 5;
		tickRate = 4;
		_frameList = new Array<Int>();
		_delta = 0;

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
	public function init()
	{

	}

	/**
	 * Updates the game, updating the World and Entities.
	 */
	public function update()
	{
		if (HXP.world.active)
		{
			var ft:FriendTweener = HXP.world;
			if (ft._tween != null) HXP.world.updateTweens();
			HXP.world.update();
		}
		HXP.world.updateLists();
		if (!HXP.gotoIsNull()) checkWorld();
	}

	/**
	 * Renders the game, rendering the World and Entities.
	 */
	public function render()
	{
		// timing stuff
		var t:Float = Lib.getTimer();
		if (_frameLast == 0) _frameLast = Std.int(t);

		// render loop
		HXP.screen.swap();
		Draw.resetTarget();
		HXP.screen.refresh();
		if (HXP.world.visible) HXP.world.render();
		HXP.screen.redraw();

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
	public function setStageProperties()
	{
		HXP.stage.frameRate = HXP.assignedFrameRate;
		HXP.stage.align = StageAlign.TOP_LEFT;
		HXP.stage.quality = StageQuality.HIGH;
		HXP.stage.scaleMode = StageScaleMode.NO_SCALE;
		HXP.stage.displayState = StageDisplayState.NORMAL;
	}

	private function onResize(e:Event)
	{
		HXP.screen.resize(HXP.stage.stageWidth, HXP.stage.stageHeight);
		trace(HXP.width + ", " + HXP.height);
	}

	/** @private Event handler for stage entry. */
	private function onStage(e:Event = null)
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

		// set resize event
		HXP.stage.addEventListener(Event.RESIZE, onResize);

		// enable input
		Input.enable();

		// switch worlds
		if (!HXP.gotoIsNull()) checkWorld();

		// game start
		init();

		// start game loop
		_rate = 1000 / HXP.assignedFrameRate;
		if (HXP.fixed)
		{
			// fixed framerate
			_skip = _rate * maxFrameSkip;
			_last = _prev = Lib.getTimer();
			_timer = new Timer(tickRate);
			_timer.run = onTimer;
		}
		else
		{
			// nonfixed framerate
			_last = Lib.getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}

	/** @private Framerate independent game loop. */
	private function onEnterFrame(e:Event)
	{
		// update timer
		_time = _gameTime = Lib.getTimer();
		HXP._flashTime = _time - _flashTime;
		_updateTime = _time;
		HXP.elapsed = (_time - _last) / 1000;
		if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
		HXP.elapsed *= HXP.rate;
		_last = _time;

		// update loop
		if (!paused) update();

		// update console
		if (HXP.console != null) HXP.console.update();

		// update input
		Input.update();

		// update timer
		_time = _renderTime = Lib.getTimer();
		HXP._updateTime = _time - _updateTime;

		// render loop
		if (!paused) render();

		// update timer
		_time = _flashTime = Lib.getTimer();
		HXP._renderTime = _time - _renderTime;
		HXP._gameTime = _time - _gameTime;
	}

	/** @private Fixed framerate game loop. */
	private function onTimer()
	{
		// update timer
		_time = Lib.getTimer();
		_delta += (_time - _last);
		_last = _time;

		// quit if a frame hasn't passed
		if (_delta < _rate) return;

		// update timer
		_gameTime = Std.int(_time);
		HXP._flashTime = _time - _flashTime;

		// update loop
		if (_delta > _skip) _delta = _skip;
		while (_delta > _rate)
		{
			// update timer
			_updateTime = _time;
			_delta -= _rate;
			HXP.elapsed = (_time - _prev) / 1000;
			if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
			HXP.elapsed *= HXP.rate;
			_prev = _time;

			// update loop
			if (!paused) update();

			// update console
			if (HXP.console != null) HXP.console.update();

			// update input
			Input.update();

			// update timer
			_time = Lib.getTimer();
			HXP._updateTime = _time - _updateTime;
		}

		// update timer
		_renderTime = _time;

		// render loop
		if (!paused) render();

		// update timer
		_time = _flashTime = Lib.getTimer();
		HXP._renderTime = _time - _renderTime;
		HXP._gameTime =  _time - _gameTime;
	}

	/** @private Switch Worlds if they've changed. */
	private function checkWorld()
	{
		if (HXP.gotoIsNull()) return;
		HXP.world.end();
		HXP.world.updateLists();
		var ft:FriendTweener = HXP.world;
		if (HXP.world != null && HXP.world.autoClear && ft._tween != null) HXP.world.clearTweens();
		HXP.swapWorld();
		HXP.camera = HXP.world.camera;
		HXP.world.updateLists();
		HXP.world.begin();
		HXP.world.updateLists();
	}

	// Timing information.
	private var _delta:Float;
	private var _time:Float;
	private var _last:Float;
	private var _timer:Timer;
	private var	_rate:Float;
	private var	_skip:Float;
	private var _prev:Float;

	// Debug timing information.
	private var _updateTime:Float;
	private var _renderTime:Float;
	private var _gameTime:Float;
	private var _flashTime:Float;

	// FrameRate tracking.
	private var _frameLast:Float;
	private var _frameListSum:Int;
	private var _frameList:Array<Int>;
}