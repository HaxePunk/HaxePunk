package haxepunk.debug;

import haxe.Log;
import haxe.PosInfos;
import flash.Assets;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.input.Key;
import haxepunk.input.Mouse;

/**
 * If the console should capture the trace() function calls.
 *
 * To be passed to `Console.enable`.
 */
enum TraceCapture
{
	/** Traces won't be captured. */
	No;

	/** The console will capture the traces. */
	Yes;
}

/**
 * Console used for debugging, shows entities and their masks.
 *
 * Use `HXP.console`.enable to enable it.
 */
class Console
{
	/**
	 * The key used to toggle the Console on/off.
	 */
	public var toggleKey:Int;

	@:allow(haxepunk)
	function new()
	{
		// Console display objects.
		_sprite = new Sprite();
		_back = new Bitmap();

		_layerList = new LayerList();

		// Button panel information.
		_butPanel = new Sprite();
	}

	function traceLog(v:Dynamic, ?infos:PosInfos)
	{
		var log:String = infos.className + "(" + infos.lineNumber + "): " + Std.string(v);
		_logger.log(log);
#if (cpp || neko)
		Sys.println(log);
#end
		repositionLogger();
	}

	/**
	 * Logs data to the console.
	 * @param	data		The data parameters to log, can be variables, objects, etc. Parameters will be separated by a space (" ").
	 */
	public function log(data:Array<Dynamic>)
	{
		var s:String = "";

		// Iterate through data to build a string.
		for (i in 0...data.length)
		{
			if (i > 0) s += " ";
			s += (data[i] != null ? Std.string(data[i]) : "null");
		}

		// Replace newlines with multiple log statements.
		if (s.indexOf("\n") >= 0)
		{
			var a:Array<String> = s.split("\n");
			for (s in a) _logger.log(s);
		}
		else
		{
			_logger.log(s);
		}

		repositionLogger();
	}

	public inline function watch(properties:Array<String>)
	{
		_debugText.watch(properties);
	}

	/**
	 * Show the console, no effect if the console isn't hidden.
	 */
	public function show()
	{
		if (!_onStage)
		{
			HXP.stage.addChild(_sprite);
			_onStage = true;
		}
	}

	/**
	 * Hide the console, no effect if the console isn't visible.
	 */
	public function hide()
	{
		if (_onStage)
		{
			HXP.stage.removeChild(_sprite);
			_onStage = false;
		}
	}

	/**
	 * Enables the console.
	 *
	 * @param	trace_capture	If the console should capture the trace() function calls.
	 * @param	toggleKey		Key used to toggle the console, `Key.TILDE` (~) by default, use `Key`.
	 */
	public function enable(?trace_capture:TraceCapture, toggleKey=Key.TILDE)
	{
		this.toggleKey = toggleKey;

		// Quit if the console is already enabled.
		if (_enabled) return;

		// load assets based on embedding method
		try
		{
			_bmpLogo = new Bitmap(Assets.getBitmapData("graphics/debug/console_logo.png"));
			_butDebug = new Bitmap(Assets.getBitmapData("graphics/debug/console_debug.png"));
			_butOutput = new Bitmap(Assets.getBitmapData("graphics/debug/console_output.png"));
			_butPlay = new Bitmap(Assets.getBitmapData("graphics/debug/console_play.png"));
			_butPause = new Bitmap(Assets.getBitmapData("graphics/debug/console_pause.png"));
			_butStep = new Bitmap(Assets.getBitmapData("graphics/debug/console_step.png"));
		}
		catch (e:Dynamic)
		{
			return;
		}

		// Enable it and add the Sprite to the stage.
		_enabled = true;
		show();

		// Used to determine some text sizing.
		var big:Bool = width >= BIG_WIDTH_THRESHOLD;

		// The transparent HaxePunk logo overlay bitmap.
		_sprite.addChild(_back);

		// The entity and selection sprites.
		_entSelect = new EntitySelect();
		_entSelect.onLayerCount.bind(function(l) _layerList.set(l));
		_sprite.addChild(_entSelect);

		// The entity count text.
		_entityCount = new EntityCounter();
		_sprite.addChild(_entityCount);

		// The FPS text.
		_fps = new FPSCounter(big);
		_sprite.addChild(_fps);

		_sprite.addChild(_layerList);

		// The output log text.
		_logger = new LogReader(big);
		_sprite.addChild(_logger);

		// The debug text.
		_debugText = new DebugText();
		_sprite.addChild(_debugText);

		// The button panel buttons.
		_sprite.addChild(_butPanel);
		_butPanel.addChild(_butDebug);
		_butPanel.addChild(_butOutput);
		_butPanel.addChild(_butPlay).x = 20;
		_butPanel.addChild(_butPause).x = 20;
		_butPanel.addChild(_butStep).x = 40;
		updateButtons();

		// The button panel.
		_butPanel.graphics.clear();
		_butPanel.graphics.beginFill(0, .75);
		_butPanel.graphics.drawRoundRect(-20, -20, 100, 40, 40, 40);
		debug = true;

		// redraws the logo
		HXP.stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);

		// Set the state to unpaused.
		paused = false;

		if (trace_capture == TraceCapture.Yes)
			Log.trace = traceLog;

		_logger.log("-- HaxePunk v" + HXP.VERSION + " --");
		repositionLogger();
	}

	@:dox(hide)
	public function onResize(e:Event)
	{
		if (_back.bitmapData != null)
		{
			_back.bitmapData.dispose();
		}
		_back.bitmapData = HXP.createBitmap(width, height, true, 0xFFFFFFFF);
		HXP.matrix.identity();
		HXP.matrix.tx = Math.max((_back.bitmapData.width - _bmpLogo.width) / 2, 0);
		HXP.matrix.ty = Math.max((_back.bitmapData.height - _bmpLogo.height) / 2, 0);
		HXP.matrix.scale(Math.min(width / _back.bitmapData.width, 1), Math.min(height / _back.bitmapData.height, 1));
		_back.bitmapData.draw(_bmpLogo, HXP.matrix, null, BlendMode.MULTIPLY);
		_back.bitmapData.draw(_back.bitmapData, null, null, BlendMode.INVERT);
		_back.bitmapData.colorTransform(_back.bitmapData.rect, new ColorTransform(1, 1, 1, 0.5));
		repositionLogger();
	}

	/**
	 * If the console should be visible.
	 */
	public var visible(get, set):Bool;
	function get_visible():Bool return _sprite.visible;
	function set_visible(value:Bool):Bool
	{
		_sprite.visible = value;
		repositionLogger();
		return _sprite.visible;
	}

	/**
	 * Allows masks to be turned on and off in the console
	 */
	public var debugDraw(get, set):Bool;
	inline function get_debugDraw():Bool return _enabled ? _entSelect.debugDraw : false;
	inline function set_debugDraw(value:Bool):Bool return _enabled ? _entSelect.debugDraw = value : false;

	/**
	 * Console update, called by game loop.
	 */
	@:dox(hide)
	public function update()
	{
		// Quit if the console isn't enabled or visible.
		if (!_enabled || !_onStage)
			return;

		// move on resize
		_entityCount.update();
		_layerList.x = width - _layerList.width - 20;
		_layerList.y = (height - _layerList.height) / 2;
		_layerList.visible = HXP.engine.paused && debug;

		// Update buttons.
		if (_butPanel.visible)
			updateButtons();

		// If the console is paused.
		if (paused)
		{

			// While in debug mode.
			if (debug)
			{

				// While the game is paused.
				if (HXP.engine.paused)
				{
					_entSelect.update();
					_debugText.update(_entSelect.selected, width >= BIG_WIDTH_THRESHOLD);
				}
				else
				{
					_fps.update();
				}

				_entSelect.draw();
			}
			else
			{
				// log scrollbar
				if (_scrolling)
				{
					_scrolling = Mouse.mouseDown;
					_logger.scroll(Mouse.mouseFlashY);
					repositionLogger();
				}
				else if (Mouse.mousePressed)
				{
					_scrolling = _logger.canStartScrolling(Mouse.mouseFlashX, Mouse.mouseFlashY);
				}
			}
		}
		else
		{
			// Update info while the game runs.
			_fps.update();
		}

		// Console toggle.
		if (Key.pressed(toggleKey)) paused = !paused;
	}

	/**
	 * If the Console is currently in paused mode.
	 */
	public var paused(default, set):Bool = false;
	function set_paused(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (!_enabled) return false;

		// Set the console to paused.
		paused = value;
		HXP.engine.paused = value;

		// Panel visibility.
		_back.visible = value;
		_entSelect.visible = value;
#if !mobile // buttons always show on mobile devices
		_butPanel.visible = value;
#end

		// If the console is paused.
		if (value)
		{
			// Set the console to paused mode.
			if (debug) debug = true;
			else repositionLogger();

			Mouse.showCursor();
		}
		else
		{
			// Set the console to running mode.
			_debugText.visible = false;
			_logger.visible = true;
			repositionLogger();
			_entSelect.clear();

			var cursor = HXP.cursor;
			HXP.cursor = null;
			HXP.cursor = cursor;
		}
		return paused;
	}

	/**
	 * If the Console is currently in debug mode.
	 */
	public var debug(default, set):Bool = false;
	function set_debug(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (_enabled)
		{
			// Set the console to debug mode.
			debug = value;
			_debugText.visible = value;
			_logger.visible = !value;

			// Update console state.
			if (!value) repositionLogger();
			_entSelect.visible = value;
			_entSelect.draw();
		}
		return debug;
	}

	/** @private Steps the frame ahead. */
	function stepFrame()
	{
		HXP.engine.update();
		HXP.engine.render();
		_entityCount.update();
		_entSelect.draw();
	}

	/** @private Sets the camera position. */
	function setCamera(x:Int, y:Int)
	{
		HXP.camera.x = x;
		HXP.camera.y = y;
		HXP.engine.render();
		_entSelect.draw(true);
	}

	/** @private Updates the log window. */
	function repositionLogger()
	{
		if (_enabled && visible)
		{
			paused ? _logger.drawMultipleLines() : _logger.drawSingleLine();

			_fps.selectable = paused;
			_entityCount.selectable = paused;
			_debugText.selectable = paused;
		}
	}

	/** @private Shows a bitmap button and handles click events */
	function showButton(bitmap:Bitmap, clicked:Void->Void)
	{
		bitmap.visible = true;
		if (bitmap.bitmapData.rect.contains(bitmap.mouseX, bitmap.mouseY))
		{
			bitmap.alpha = 1;
			if (Mouse.mousePressed) clicked();
		}
		else
		{
			bitmap.alpha = 0.5;
		}
	}

	/** @private Updates the Button panel. */
	function updateButtons()
	{
		// Button visibility.
		_butPanel.x = (width >= BIG_WIDTH_THRESHOLD ? _fps.offset + Std.int((_entityCount.x - _fps.offset) / 2) - 30 : 160 + 20);
		// hide all buttons initially and only show if showButton is called
		_butStep.visible = _butDebug.visible = _butOutput.visible = _butPlay.visible = _butPause.visible = false;

		if (paused)
		{
			// Debug/Output button.
			if (debug)
			{
				showButton(_butOutput, function() debug = false);
			}
			else
			{
				showButton(_butDebug, function() debug = true);
			}

			showButton(_butStep, stepFrame); // Frame step button.
		}

		// Play/Pause button.
		if (HXP.engine.paused)
		{
			showButton(_butPlay, function()
			{
				HXP.engine.paused = false;
				_entSelect.draw();
			});
		}
		else
		{
			showButton(_butPause, function()
			{
				HXP.engine.paused = true;
				_entSelect.draw();
			});
		}
	}

	/**
	 * Get the unscaled screen width for the Console.
	 */
	public var width(get, never):Int;
	function get_width():Int return HXP.windowWidth;

	/**
	 * Get the unscaled screen height for the Console.
	 */
	public var height(get, never):Int;
	function get_height():Int return HXP.windowHeight;

	// Console state information.
	var _enabled:Bool = false;
	var _onStage:Bool = false;
	var _scrolling:Bool;

	// Console display objects.
	var _sprite:Sprite;
	var _back:Bitmap;

	var _layerList:LayerList;
	var _logger:LogReader;
	var _entityCount:EntityCounter;
	var _debugText:DebugText;
	var _fps:FPSCounter;
	var _entSelect:EntitySelect;

	// Button panel information
	var _butPanel:Sprite;
	var _butDebug:Bitmap;
	var _butOutput:Bitmap;
	var _butPlay:Bitmap;
	var _butPause:Bitmap;
	var _butStep:Bitmap;

	var _bmpLogo:Bitmap;

	// Switch to small text in debug if console width > this threshold.
	static inline var BIG_WIDTH_THRESHOLD:Int = 420;

}
