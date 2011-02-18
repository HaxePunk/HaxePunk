package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import haxe.Timer;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;

/**
 * Main game Sprite class, added to the Flash Stage. Manages the game loop.
 */
class Engine extends MovieClip
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
		HXP.width = width;
		HXP.height = height;
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;
		
		// global game objects
		HXP.engine = this;
		HXP.screen = new Screen();
		HXP.bounds = new Rectangle(0, 0, width, height);
		HXP.world = new World();
		
		// miscellanious startup stuff
		if (HXP.randomSeed == 0) HXP.randomizeSeed();
		HXP.entity = new Entity();
		HXP.time = Timer.stamp();
		
		paused = false;
		maxElapsed = 0.0333;
		maxFrameSkip = 5;
		tickRate = 4;
		_frameList = new Array<Int>();
		
		// on-stage event listener
		addEventListener(Event.ADDED_TO_STAGE, onStage);
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
			if (HXP.world.tween != null) HXP.world.updateTweens();
			HXP.world.update();
		}
		HXP.world.updateLists();
		if (HXP.goto != null) checkWorld();
	}
	
	/**
	 * Renders the game, rendering the World and Entities.
	 */
	public function render()
	{
		// timing stuff
		var t:Float = Timer.stamp();
		if (_frameLast == 0) _frameLast = Std.int(t);
		
		// render loop
		HXP.screen.swap();
		Draw.resetTarget();
		HXP.screen.refresh();
		if (HXP.world.visible) HXP.world.render();
		HXP.screen.redraw();
		
		// more timing stuff
		t = Timer.stamp();
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
		stage.frameRate = HXP.assignedFrameRate;
		stage.align = StageAlign.TOP_LEFT;
		stage.quality = StageQuality.HIGH;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.displayState = StageDisplayState.NORMAL;
	}
	
	/** @private Event handler for stage entry. */
	private function onStage(e:Event = null)
	{
		// remove event listener
		removeEventListener(Event.ADDED_TO_STAGE, onStage);
		
		// set stage properties
		HXP.stage = flash.Lib.current;
		setStageProperties();
		
		// enable input
		Input.enable();
		
		// switch worlds
		if (HXP.goto != null) checkWorld();
		
		// game start
		init();
		
		// start game loop
		_rate = 1000 / HXP.assignedFrameRate;
		if (HXP.fixed)
		{
			// fixed framerate
			_skip = _rate * maxFrameSkip;
			_last = _prev = Timer.stamp();
			_timer = new Timer(tickRate);
			_timer.run = onTimer;
		}
		else
		{
			// nonfixed framerate
			_last = Timer.stamp();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
	
	/** @private Framerate independent game loop. */
	private function onEnterFrame(e:Event)
	{
		// update timer
		_time = _gameTime = Timer.stamp();
		HXP.flashTime = _time - _flashTime;
		_updateTime = _time;
		HXP.elapsed = (_time - _last) / 1000;
		if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
		HXP.elapsed *= HXP.rate;
		_last = _time;
		
		// update console
		if (HXP.console != null) HXP.console.update();
		
		// update loop
		if (!paused) update();
		
		// update input
		Input.update();
		
		// update timer
		_time = _renderTime = Timer.stamp();
		HXP.updateTime = _time - _updateTime;
		
		// render loop
		if (!paused) render();
		
		// update timer
		_time = _flashTime = Timer.stamp();
		HXP.renderTime = _time - _renderTime;
		HXP.gameTime = _time - _gameTime;
	}
	
	/** @private Fixed framerate game loop. */
	private function onTimer()
	{
		// update timer
		_time = Timer.stamp();
		_delta += (_time - _last);
		_last = _time;
		
		// quit if a frame hasn't passed
		if (_delta < _rate) return;
		
		// update timer
		_gameTime = Std.int(_time);
		HXP.flashTime = _time - _flashTime;
		
		// update console
		if (HXP.console != null) HXP.console.update();
		
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
			
			// update input
			Input.update();
			
			// update timer
			_time = Timer.stamp();
			HXP.updateTime = _time - _updateTime;
		}
		
		// update timer
		_renderTime = _time;
		
		// render loop
		if (!paused) render();
		
		// update timer
		_time = _flashTime = Timer.stamp();
		HXP.renderTime = _time - _renderTime;
		HXP.gameTime =  _time - _gameTime;
	}
	
	/** @private Switch Worlds if they've changed. */
	private function checkWorld()
	{
		if (HXP.goto == null) return;
		HXP.world.end();
		HXP.world.updateLists();
		if (HXP.world != null && HXP.world.autoClear && HXP.world.tween != null) HXP.world.clearTweens();
		HXP.world = HXP.goto;
		HXP.goto = null;
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