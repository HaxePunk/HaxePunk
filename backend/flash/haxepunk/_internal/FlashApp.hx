package haxepunk._internal;

import flash.display.OpenGLView;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import haxepunk.debug.Console;

class FlashApp extends Sprite
{
	/**
	 * Toggles between windowed and fullscreen modes
	 */
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return stage.displayState == StageDisplayState.FULL_SCREEN;
	inline function set_fullscreen(value:Bool):Bool
	{
		if (value) stage.displayState = StageDisplayState.FULL_SCREEN;
		else stage.displayState = StageDisplayState.NORMAL;
		return value;
	}

	var engine:Engine;

	public function new(engine:Engine)
	{
		super();
		this.engine = engine;

		// on-stage event listener
		addEventListener(Event.ADDED_TO_STAGE, onStage);
	}

	public function init()
	{
		Lib.current.addChild(this);
	}

	public function getTimeMillis():Float
	{
		return Lib.getTimer();
	}

	public function multiTouchSupported():Bool
	{
		return flash.ui.Multitouch.supportsTouchEvents;
	}

	function onEnterFrame(e:Event)
	{
		engine.onUpdate();
	}

	/** @private Event handler for stage entry. */
	@:access(haxepunk.Engine)
	function onStage(?e:Event)
	{
		// remove event listener
		removeEventListener(Event.ADDED_TO_STAGE, onStage);
		setStageProperties();

		// create an OpenGLView object and use the engine's render method
		var view = new OpenGLView();
		view.render = function(rect:Rectangle)
		{
			engine.onRender();
		};
		addChild(view);

		// enable input
		initKeyInput();
		initMouseInput();
		initGamepadInput();

		if (multiTouchSupported())
		{
			initTouchInput();
		}

		engine.checkScene();

		// game start
		engine.init();

		// start game loop
		engine._rate = 1000 / HXP.assignedFrameRate;

		// nonfixed framerate
		engine._last = getTimeMillis();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);

		#if (nme || openfl_legacy)
		Lib.stage.onQuit = function() {
			engine.onClose.invoke();
			Lib.close();
		}
		#else
		Lib.current.stage.application.onExit.add(function(_) {
			engine.onClose.invoke();
		});
		#end

		#if hxp_debug_console
		Console.enabled = true;
		#end
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

		HXP.screen.color = stage.color;

		_resize(); // call resize once to initialize the screen

		// set resize event
		stage.addEventListener(Event.RESIZE, function (e:Event) _resize());

		stage.addEventListener(Event.ACTIVATE, function (e:Event)
		{
			HXP.focused = true;
			engine.focusGained();
			engine.scene.focusGained();
		});

		stage.addEventListener(Event.DEACTIVATE, function (e:Event)
		{
			HXP.focused = false;
			engine.focusLost();
			engine.scene.focusLost();
		});

		#if (!html5 && openfl_legacy)
		flash.display.Stage.shouldRotateInterface = function(orientation:Int):Bool
		{
			if (HXP.indexOf(HXP.orientations, orientation) == -1) return false;
			var tmp = HXP.height;
			HXP.height = HXP.width;
			HXP.width = tmp;
			_resize();
			return true;
		}
		#end
	}

	public function initMouseInput()
	{
		MouseInput.init(this);
	}

	public function initKeyInput()
	{
		KeyInput.init(this);
	}

	public function initGamepadInput() {}

	public function initTouchInput()
	{
		TouchInput.init(this);
	}

	public inline function getMouseX() return stage.mouseX;
	public inline function getMouseY() return stage.mouseY;

	/** @private Event handler for stage resize */
	function _resize()
	{
		if (HXP.width == 0 || HXP.height == 0)
		{
			// set initial size
			HXP.width = stage.stageWidth;
			HXP.height = stage.stageHeight;
			HXP.screen.scaleMode.setBaseSize();
		}
		// calculate scale from width/height values
		HXP.resize(stage.stageWidth, stage.stageHeight);
		if (scrollRect == null)
		{
			scrollRect = new Rectangle();
		}
		scrollRect.width = HXP.screen.width;
		scrollRect.height = HXP.screen.height;

		engine.onResize.invoke();
	}
}
