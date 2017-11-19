package haxepunk;

import haxepunk.input.Input;

#if (lime || nme)
import flash.display.OpenGLView;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

class App extends Sprite
{
	var engine:Engine;
	public function new(engine:Engine)
	{
		// on-stage event listener
		addEventListener(Event.ADDED_TO_STAGE, onStage);
		Lib.current.addChild(this);
		this.engine = engine;
		super();
	}

	function getTime():Float
	{
		return Lib.getTimer();
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
		HXP.stage = stage;
		setStageProperties();

		// create an OpenGLView object and use the engine's render method
		var view = new OpenGLView();
		view.render = function(rect:flash.geom.Rectangle)
		{
			engine.onRender();
		};
		addChild(view);

		// enable input
		Input.enable();

		// switch scenes
		engine.checkScene();

		// game start
		engine.init();

		// start game loop
		engine._rate = 1000 / HXP.assignedFrameRate;

		// nonfixed framerate
		engine._last = getTime();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);

		#if (nme || openfl_legacy)
		Lib.stage.onQuit = function() {
			onClose.invoke();
			Lib.close();
		}
		#else
		Lib.current.stage.application.onExit.add(function(_) {
			engine.onClose.invoke();
		});
		#end

		#if debug_console
		Console.enabled = true;
		#end
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

		_resize(); // call resize once to initialize the screen

		// set resize event
		HXP.stage.addEventListener(Event.RESIZE, function (e:Event) _resize());

		HXP.stage.addEventListener(Event.ACTIVATE, function (e:Event)
		{
			HXP.focused = true;
			engine.focusGained();
			engine.scene.focusGained();
		});

		HXP.stage.addEventListener(Event.DEACTIVATE, function (e:Event)
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


	/** @private Event handler for stage resize */
	function _resize()
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
		if (scrollRect == null)
		{
			scrollRect = new flash.geom.Rectangle();
		}
		scrollRect.width = HXP.screen.width;
		scrollRect.height = HXP.screen.height;

		engine.onResize.invoke();
	}

}

#else

class App
{
	public function new(engine:Engine) {}

	function getTime():Float
	{
		return 0;
	}
}

#end
