package haxepunk.debug;

import haxe.Log;
import haxe.PosInfos;
import haxe.ds.IntMap;
import flash.Assets;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.utils.Color;
import haxepunk.utils.MathUtil;


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
		init();

		Key.define("_ARROWS", [Key.RIGHT, Key.LEFT, Key.DOWN, Key.UP]);
	}

	// Initialize variables
	function init()
	{
		// Console display objects.
		_sprite = new Sprite();
		var font = Assets.getFont("font/04B_03__.ttf");
		if (font == null)
		{
			font = Assets.getFont(HXP.defaultFont);
		}
		_format = new TextFormat(font.fontName, 8, 0xFFFFFF);
		_back = new Bitmap();

		// FPS panel information.
		_fpsRead = new Sprite();
		_fpsReadText = new TextField();
		_fpsInfo = new Sprite();
		_fpsInfoText0 = new TextField();
		_fpsInfoText1 = new TextField();
		_memReadText = new TextField();

		_layerList = new LayerList();

		// Output panel information.
		_logRead = new Sprite();
		_logReadText0 = new TextField();
		_logReadText1 = new TextField();
		_logScroll = 0;
		_logLines = 33;

		// Entity count panel information.
		_entRead = new Sprite();
		_entReadText = new TextField();

		// Debug panel information.
		_debRead = new Sprite();
		_debReadText0 = new TextField();
		_debReadText1 = new TextField();

		// Button panel information.
		_butRead = new Sprite();

		// Entity selection information.
		_entScreen = new Sprite();
		_entSelect = new Sprite();
		_entRect = new Rectangle();

		// Log information.
		LOG = new Array<String>();

		LAYER_LIST  = new IntMap<Int>();
		ENTITY_LIST = new Array<Entity>();
		SCREEN_LIST = new Array<Entity>();
		SELECT_LIST = new Array<Entity>();

		// Watch information.
		WATCH_LIST = ["x", "y"];
	}

	function traceLog(v:Dynamic, ?infos:PosInfos)
	{
		var log:String = infos.className + "(" + infos.lineNumber + "): " + Std.string(v);
		LOG.push(log);
#if (cpp || neko)
		Sys.println(log);
#end
		if (_enabled && _sprite.visible) updateLog();
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
			for (s in a) LOG.push(s);
		}
		else
		{
			LOG.push(s);
		}

		// If the log is running, update it.
		if (_enabled && _sprite.visible) updateLog();
	}

	/**
	 * Adds properties to watch in the console's debug panel.
	 * @param	properties		The properties (strings) to watch.
	 */
	public function watch(properties:Array<Dynamic>)
	{
		var i:String;
		if (properties.length > 1)
		{
			for (i in properties) WATCH_LIST.push(i);
		}
		else
		{
			WATCH_LIST.push(properties[0]);
		}
	}

	/**
	 * Show the console, no effect if the console insn't hidden.
	 */
	public function show()
	{
		if (!_visible)
		{
			HXP.stage.addChild(_sprite);
			_visible = true;
		}
	}

	/**
	 * Hide the console, no effect if the console isn't visible.
	 */
	public function hide()
	{
		if (_visible)
		{
			HXP.stage.removeChild(_sprite);
			_visible = false;
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
		_visible = true;
		HXP.stage.addChild(_sprite);

		// Used to determine some text sizing.
		var big:Bool = width >= BIG_WIDTH_THRESHOLD;

		// The transparent HaxePunk logo overlay bitmap.
		_sprite.addChild(_back);

		// The entity and selection sprites.
		_sprite.addChild(_entScreen);
		_entScreen.addChild(_entSelect);

		// The entity count text.
		_sprite.addChild(_entRead);
		_entRead.addChild(_entReadText);
		_entReadText.defaultTextFormat = format(16, 0xFFFFFF, "right");
		_entReadText.width = 100;
		_entReadText.height = 20;
		_entRead.x = width - _entReadText.width;

		// The entity count panel.
		_entRead.graphics.clear();
		_entRead.graphics.beginFill(0, .5);
		_entRead.graphics.drawRoundRect(0, -20, _entReadText.width + 20, 40, 40, 40);

		// The FPS text.
		_sprite.addChild(_fpsRead);
		_fpsRead.addChild(_fpsReadText);
		_fpsReadText.defaultTextFormat = format(16);
		_fpsReadText.width = 70;
		_fpsReadText.height = 20;
		_fpsReadText.x = 2;
		_fpsReadText.y = 1;

		// The FPS and frame timing panel.
		_fpsRead.graphics.clear();
		_fpsRead.graphics.beginFill(0, .75);
		_fpsRead.graphics.drawRoundRect(-20, -20, big ? 320 + 20 : 160 + 20, 40, 40, 40);

		_sprite.addChild(_layerList);

		// The frame timing text.
		if (big) _sprite.addChild(_fpsInfo);
		_fpsInfo.addChild(_fpsInfoText0);
		_fpsInfo.addChild(_fpsInfoText1);
		_fpsInfoText0.defaultTextFormat = format(8, 0xAAAAAA);
		_fpsInfoText1.defaultTextFormat = format(8, 0xAAAAAA);
		_fpsInfoText0.width = _fpsInfoText1.width = 60;
		_fpsInfoText0.height = _fpsInfoText1.height = 20;
		_fpsInfo.x = 75;
		_fpsInfoText1.x = 60;
		_fpsInfo.width = _fpsInfoText0.width + _fpsInfoText1.width;

		// The memory usage
#if !js
		_fpsRead.addChild(_memReadText);
		_memReadText.defaultTextFormat = format(16);
		_memReadText.embedFonts = true;
		_memReadText.width = 110;
		_memReadText.height = 20;
		_memReadText.x = (big) ? _fpsInfo.x + _fpsInfoText0.width + _fpsInfoText1.width + 5 : _fpsInfo.x + 9;
		_memReadText.y = 1;
#end

		// The output log text.
		_sprite.addChild(_logRead);
		_logRead.addChild(_logReadText0);
		_logRead.addChild(_logReadText1);
		_logReadText0.defaultTextFormat = format(16, 0xFFFFFF);
		_logReadText1.defaultTextFormat = format(big ? 16 : 8, 0xFFFFFF);
		_logReadText0.selectable = false;
		_logReadText0.width = 80;
		_logReadText0.height = 20;
		_logReadText1.width = width;
		_logReadText0.x = 2;
		_logReadText0.y = 3;
		_logReadText0.text = "OUTPUT:";
		_logHeight = height - 60;
		_logBar = new Rectangle(8, 24, 16, _logHeight - 8);
		_logBarGlobal = _logBar.clone();
		_logBarGlobal.y += 40;
		if (big) _logLines = Std.int(_logHeight / 16.5);
		else _logLines = Std.int(_logHeight / 8.5);

		// The debug text.
		_sprite.addChild(_debRead);
		_debRead.addChild(_debReadText0);
		_debRead.addChild(_debReadText1);
		_debReadText0.defaultTextFormat = format(16, 0xFFFFFF);
		_debReadText1.defaultTextFormat = format(8, 0xFFFFFF);
		_debReadText0.selectable = false;
		_debReadText0.width = 80;
		_debReadText0.height = 20;
		_debReadText1.width = 160;
		_debReadText1.height = Std.int(height / 4);
		_debReadText0.x = 2;
		_debReadText0.y = 3;
		_debReadText1.x = 2;
		_debReadText1.y = 24;
		_debReadText0.text = "DEBUG:";
		_debRead.y = height - (_debReadText1.y + _debReadText1.height);

		// The button panel buttons.
		_sprite.addChild(_butRead);
		_butRead.addChild(_butDebug);
		_butRead.addChild(_butOutput);
		_butRead.addChild(_butPlay).x = 20;
		_butRead.addChild(_butPause).x = 20;
		_butRead.addChild(_butStep).x = 40;
		updateButtons();

		// The button panel.
		_butRead.graphics.clear();
		_butRead.graphics.beginFill(0, .75);
		_butRead.graphics.drawRoundRect(-20, -20, 100, 40, 40, 40);
		debug = true;

		// redraws the logo
		HXP.stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);

		// Set the state to unpaused.
		paused = false;

		if (trace_capture == TraceCapture.Yes)
			Log.trace = traceLog;

		LOG.push("-- HaxePunk v" + HXP.VERSION + " --");
		if (_enabled && _sprite.visible) updateLog();
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
		updateLog();
	}

	/**
	 * If the console should be visible.
	 */
	public var visible(get, set):Bool;
	function get_visible():Bool return _sprite.visible;
	function set_visible(value:Bool):Bool
	{
		_sprite.visible = value;
		if (_enabled && value) updateLog();
		return _sprite.visible;
	}

	/**
	 * Allows masks to be turned on and off in the console
	 */
	public var debugDraw(default, set):Bool = true;
	function set_debugDraw(value:Bool):Bool
	{
		debugDraw = value;
		updateEntityLists(false);
		renderEntities();
		return value;
	}

	/**
	 * Console update, called by game loop.
	 */
	@:dox(hide)
	public function update()
	{
		// Quit if the console isn't enabled or visible.
		if (!_enabled || !_visible)
			return;

		// move on resize
		_entRead.x = width - _entReadText.width;
		_layerList.x = width - _layerList.width - 20;
		_layerList.y = (height - _layerList.height) / 2;
		_layerList.visible = HXP.engine.paused && _debug;

		// Update buttons.
		if (_butRead.visible)
			updateButtons();

		// If the console is paused.
		if (_paused)
		{

			// While in debug mode.
			if (_debug)
			{
				updateEntityLists(HXP.scene.count != ENTITY_LIST.length);

				// While the game is paused.
				if (HXP.engine.paused)
				{
					// When the mouse is pressed.
					if (Mouse.mousePressed)
					{
						// Mouse is within clickable area.
						if (Mouse.mouseFlashY > 20 && (Mouse.mouseFlashX > _debReadText1.width || Mouse.mouseFlashY < _debRead.y))
						{
							if (Key.check(Key.SHIFT))
							{
								if (SELECT_LIST.length != 0) startDragging();
								else startPanning();
							}
							else startSelection();
						}
					}
					else
					{
						// Update mouse movement functions.
						if (_selecting) updateSelection();
						if (_dragging) updateDragging();
						if (_panning) updatePanning();
					}

					// Select all Entities
					if (Key.pressed(Key.A)) selectAll();

					// If the shift key is held.
					if (Key.check(Key.SHIFT))
					{
						// If Entities are selected.
						if (SELECT_LIST.length != 0)
						{
							// Move Entities with the arrow keys.
							if (Input.pressed("_ARROWS")) updateKeyMoving();
						}
						else
						{
							// Pan the camera with the arrow keys.
							if (Input.check("_ARROWS")) updateKeyPanning();
						}
					}
				}
				else
				{
					// Update info while the game runs.
					renderEntities();
					updateFPSRead();
					updateEntityCount();
				}

				// Update debug panel.
				updateDebugRead();
			}
			else
			{
				// log scrollbar
				if (_scrolling) updateScrolling();
				else if (Mouse.mousePressed) startScrolling();
			}
		}
		else
		{
			// Update info while the game runs.
			updateFPSRead();
			updateEntityCount();
		}

		// Console toggle.
		if (Key.pressed(toggleKey)) paused = !_paused;
	}

	/**
	 * If the Console is currently in paused mode.
	 */
	public var paused(get, set):Bool;
	function get_paused():Bool return _paused;
	function set_paused(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (!_enabled) return false;

		// Set the console to paused.
		_paused = value;
		HXP.engine.paused = value;

		// Panel visibility.
		_back.visible = value;
		_entScreen.visible = value;
#if !mobile // buttons always show on mobile devices
		_butRead.visible = value;
#end

		// If the console is paused.
		if (value)
		{
			// Set the console to paused mode.
			if (_debug) debug = true;
			else updateLog();

			Mouse.showCursor();
		}
		else
		{
			// Set the console to running mode.
			_debRead.visible = false;
			_logRead.visible = true;
			updateLog();
			HXP.clear(ENTITY_LIST);
			HXP.clear(SCREEN_LIST);
			HXP.clear(SELECT_LIST);

			var cursor = HXP.cursor;
			HXP.cursor = null;
			HXP.cursor = cursor;
		}
		return _paused;
	}

	/**
	 * If the Console is currently in debug mode.
	 */
	public var debug(get, set):Bool;
	function get_debug():Bool return _debug;
	function set_debug(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (!_enabled) return false;

		// Set the console to debug mode.
		_debug = value;
		_debRead.visible = value;
		_logRead.visible = !value;

		// Update console state.
		if (value) updateEntityLists();
		else updateLog();
		renderEntities();
		return _debug;
	}

	/** @private Steps the frame ahead. */
	function stepFrame()
	{
		HXP.engine.update();
		HXP.engine.render();
		updateEntityCount();
		updateEntityLists();
		renderEntities();
	}

	/** @private Starts Entity dragging. */
	function startDragging()
	{
		_dragging = true;
		_entRect.x = Mouse.mouseX;
		_entRect.y = Mouse.mouseY;
	}

	/** @private Updates Entity dragging. */
	function updateDragging()
	{
		moveSelected(Std.int(Mouse.mouseX - _entRect.x), Std.int(Mouse.mouseY - _entRect.y));
		_entRect.x = Mouse.mouseX;
		_entRect.y = Mouse.mouseY;
		if (Mouse.mouseReleased) _dragging = false;
	}

	/** @private Move the selected Entitites by the amount. */
	function moveSelected(xDelta:Int, yDelta:Int)
	{
		for (e in SELECT_LIST)
		{
			e.x += xDelta;
			e.y += yDelta;
		}
		HXP.engine.render();
		renderEntities();
		updateEntityLists(true);
	}

	/** @private Starts camera panning. */
	function startPanning()
	{
		_panning = true;
		_entRect.x = Mouse.mouseX;
		_entRect.y = Mouse.mouseY;
	}

	/** @private Updates camera panning. */
	function updatePanning()
	{
		if (Mouse.mouseReleased) _panning = false;
		panCamera(Std.int(_entRect.x - Mouse.mouseX), Std.int(_entRect.y - Mouse.mouseY));
		_entRect.x = Mouse.mouseX;
		_entRect.y = Mouse.mouseY;
	}

	/** @private Pans the camera. */
	function panCamera(xDelta:Int, yDelta:Int)
	{
		HXP.camera.x += xDelta;
		HXP.camera.y += yDelta;
		HXP.engine.render();
		updateEntityLists(true);
		renderEntities();
	}

	/** @private Sets the camera position. */
	function setCamera(x:Int, y:Int)
	{
		HXP.camera.x = x;
		HXP.camera.y = y;
		HXP.engine.render();
		updateEntityLists(true);
		renderEntities();
	}

	/** @private Starts Entity selection. */
	function startSelection()
	{
		_selecting = true;
		_entRect.x = Mouse.mouseFlashX;
		_entRect.y = Mouse.mouseFlashY;
		_entRect.width = 0;
		_entRect.height = 0;
	}

	/** @private Updates Entity selection. */
	function updateSelection()
	{
		_entRect.width = Mouse.mouseFlashX - _entRect.x;
		_entRect.height = Mouse.mouseFlashY - _entRect.y;
		if (Mouse.mouseReleased)
		{
			selectEntities(_entRect);
			renderEntities();
			_selecting = false;
			_entSelect.graphics.clear();
		}
		else
		{
			_entSelect.graphics.clear();
			_entSelect.graphics.lineStyle(1, 0xFFFFFF);
			_entSelect.graphics.drawRect(_entRect.x, _entRect.y, _entRect.width, _entRect.height);
		}
	}

	/** @private Selects the Entitites in the rectangle. */
	function selectEntities(rect:Rectangle)
	{
		if (rect.width < 0) rect.x -= (rect.width = -rect.width);
		else if (rect.width == 0) rect.width = 1;
		if (rect.height < 0) rect.y -= (rect.height = -rect.height);
		else if (rect.height == 0) rect.height = 1;

		HXP.rect.width = HXP.rect.height = 6;
		var sx:Float = HXP.screen.fullScaleX,
			sy:Float = HXP.screen.fullScaleY,
			e:Entity;

		if (!Key.check(Key.CONTROL))
		{
			// Replace selections with new selections.
			HXP.clear(SELECT_LIST);
		}
		// Append/Remove selected Entitites.
		for (e in SCREEN_LIST)
		{
			HXP.rect.x = (e.x - HXP.camera.x) * sx - 3;
			HXP.rect.y = (e.y - HXP.camera.y) * sy - 3;
			if (rect.intersects(HXP.rect))
			{
				if (HXP.indexOf(SELECT_LIST, e) < 0)
				{
					SELECT_LIST.push(e);
				}
				else
				{
					SELECT_LIST.remove(e);
				}
			}
		}
	}

	/** @private Selects all entities on screen. */
	function selectAll()
	{
		// capture number selected before clearing selection list
		var numSelected = SELECT_LIST.length;
		HXP.clear(SELECT_LIST);

		// if the number of entities on screen is the same as selected, leave the list cleared
		if (numSelected != SCREEN_LIST.length)
		{
			for (e in SCREEN_LIST) SELECT_LIST.push(e);
		}
		renderEntities();
	}

	/** @private Starts log text scrolling. */
	function startScrolling()
	{
		if (LOG.length > _logLines) _scrolling = _logBarGlobal.contains(Mouse.mouseFlashX, Mouse.mouseFlashY);
	}

	/** @private Updates log text scrolling. */
	function updateScrolling()
	{
		_scrolling = Mouse.mouseDown;
		_logScroll = MathUtil.scaleClamp(Mouse.mouseFlashY, _logBarGlobal.y, _logBarGlobal.bottom, 0, 1);
		updateLog();
	}

	/** @private Moves Entities with the arrow keys. */
	function updateKeyMoving()
	{
		HXP.point.x = (Key.pressed(Key.RIGHT) ? 1 : 0) - (Key.pressed(Key.LEFT) ? 1 : 0);
		HXP.point.y = (Key.pressed(Key.DOWN) ? 1 : 0) - (Key.pressed(Key.UP) ? 1 : 0);
		if (HXP.point.x != 0 || HXP.point.y != 0) moveSelected(Std.int(HXP.point.x), Std.int(HXP.point.y));
	}

	/** @private Pans the camera with the arrow keys. */
	function updateKeyPanning()
	{
		HXP.point.x = (Key.check(Key.RIGHT) ? 1 : 0) - (Key.check(Key.LEFT) ? 1 : 0);
		HXP.point.y = (Key.check(Key.DOWN) ? 1 : 0) - (Key.check(Key.UP) ? 1 : 0);
		if (HXP.point.x != 0 || HXP.point.y != 0) panCamera(Std.int(HXP.point.x), Std.int(HXP.point.y));
	}

	/** @private Update the Entity list information. */
	function updateEntityLists(fetchList:Bool = true)
	{
		// If the list should be re-populated.
		if (fetchList)
		{
			HXP.clear(ENTITY_LIST);
			HXP.scene.getAll(ENTITY_LIST);

			for (key in LAYER_LIST.keys())
			{
				LAYER_LIST.set(key, 0);
			}
		}

		// Update the list of Entities on screen.
		HXP.clear(SCREEN_LIST);
		for (e in ENTITY_LIST)
		{
			var layer = e.layer;
			if (e.onCamera && HXP.scene.layerVisible(layer))
				SCREEN_LIST.push(e);

			if (fetchList)
				LAYER_LIST.set(layer, LAYER_LIST.exists(layer) ? LAYER_LIST.get(layer) + 1 : 1);
		}

		if (fetchList)
		{
			_layerList.set(LAYER_LIST);
		}
	}

	/** @private Renders the Entities positions and hitboxes. */
	function renderEntities()
	{
		var e:Entity;
		// If debug mode is on.
		_entScreen.visible = _debug;
		_entScreen.x = HXP.screen.x;
		_entScreen.y = HXP.screen.y;
		if (_debug)
		{
			var g:Graphics = _entScreen.graphics,
				sx:Float = HXP.screen.fullScaleX,
				sy:Float = HXP.screen.fullScaleY,
				colorHitbox = 0xFFFFFF,
				colorPosition = 0xFFFFFF;
			g.clear();
			for (e in SCREEN_LIST)
			{
				var graphicScrollX = e.graphic != null ? e.graphic.scrollX : 1;
				var graphicScrollY = e.graphic != null ? e.graphic.scrollY : 1;

				// If the Entity is not selected.
				if (HXP.indexOf(SELECT_LIST, e) < 0)
				{
					colorHitbox = 0xFF0000;
					colorPosition = 0x00FF00;
				}
				else
				{
					colorHitbox = 0xFFFFFF;
					colorPosition = 0xFFFFFF;
				}

				// Draw the hitbox and position.
				if (e.width != 0 && e.height != 0)
				{
					g.lineStyle(1, colorHitbox);
					g.drawRect((e.x - e.originX - HXP.camera.x * graphicScrollX) * sx, (e.y - e.originY - HXP.camera.y * graphicScrollY) * sy, e.width * sx, e.height * sy);

					if (debugDraw && e.mask != null)
					{
						g.lineStyle(1, 0x0000FF);
						e.mask.debugDraw(g, sx, sy);
					}
				}
				g.lineStyle(1, colorPosition);
				g.drawCircle((e.x - HXP.camera.x * graphicScrollX) * sx, (e.y - HXP.camera.y * graphicScrollY) * sy, 3);
			}
		}
	}

	/** @private Updates the log window. */
	function updateLog()
	{
		_logHeight = height - 60;
		_logBar.height = _logHeight - 8;

		// If the console is paused.
		if (_paused)
		{
			// Draw the log panel.
			_logRead.y = 40;
			_logRead.graphics.clear();
			_logRead.graphics.beginFill(0, .75);
			_logRead.graphics.drawRect(0, 0, _logReadText0.width - 20, 20);
			_logRead.graphics.moveTo(_logReadText0.width, 20);
			_logRead.graphics.lineTo(_logReadText0.width - 20, 20);
			_logRead.graphics.lineTo(_logReadText0.width - 20, 0);
			_logRead.graphics.curveTo(_logReadText0.width, 0, _logReadText0.width, 20);
			_logRead.graphics.drawRect(0, 20, width, _logHeight);

			// Draw the log scrollbar.
			_logRead.graphics.beginFill(0x202020, 1);
			_logRead.graphics.drawRoundRect(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 16, 16);

			// If the log has more lines than the display limit.
			if (LOG.length > _logLines)
			{
				// Draw the log scrollbar handle.
				_logRead.graphics.beginFill(0xFFFFFF, 1);
				var y:Int = Std.int(_logBar.y + 2 + (_logBar.height - 16) * _logScroll);
				_logRead.graphics.drawRoundRect(_logBar.x + 2, y, 12, 12, 12, 12);
			}

			// Display the log text lines.
			if (LOG.length != 0)
			{
				var i:Int = (LOG.length > _logLines) ? Std.int(Math.round((LOG.length - _logLines) * _logScroll)) : 0,
					n:Int = Std.int(i + Math.min(_logLines, LOG.length)),
					s:String = "";
				while (i < n) s += LOG[i++] + "\n";
				_logReadText1.text = s;
			}
			else _logReadText1.text = "";

			// Indent the text for the scrollbar and size it to the log panel.
			_logReadText1.height = _logHeight;
			_logReadText1.x = 32;
			_logReadText1.y = 24;

			// Make text selectable in paused mode.
			_fpsReadText.selectable = true;
			_fpsInfoText0.selectable = true;
			_fpsInfoText1.selectable = true;
			_memReadText.selectable = true;
			_entReadText.selectable = true;
			_debReadText1.selectable = true;
		}
		else
		{
			// Draw the single-line log panel.
			_logRead.y = height - 40;
			_logReadText1.height = 20;
			_logRead.graphics.clear();
			_logRead.graphics.beginFill(0, .75);
			_logRead.graphics.drawRect(0, 0, _logReadText0.width - 20, 20);
			_logRead.graphics.moveTo(_logReadText0.width, 20);
			_logRead.graphics.lineTo(_logReadText0.width - 20, 20);
			_logRead.graphics.lineTo(_logReadText0.width - 20, 0);
			_logRead.graphics.curveTo(_logReadText0.width, 0, _logReadText0.width, 20);
			_logRead.graphics.drawRect(0, 20, width, 20);

			// Draw the single-line log text with the latests logged text.
			_logReadText1.text = (LOG.length != 0) ? LOG[LOG.length - 1] : "";
			_logReadText1.x = 2;
			_logReadText1.y = 21;

			// Make text non-selectable while running.
			_logReadText1.selectable = false;
			_fpsReadText.selectable = false;
			_fpsInfoText0.selectable = false;
			_fpsInfoText1.selectable = false;
			_memReadText.selectable = false;
			_entReadText.selectable = false;
			_debReadText0.selectable = false;
			_debReadText1.selectable = false;
		}
	}

	/** @private Update the FPS/frame timing panel text. */
	function updateFPSRead()
	{
		_fpsReadText.text = "FPS: " + Std.int(HXP.frameRate);
		_fpsInfoText0.text =
			"Update: " + Std.string(HXP._updateTime) + "ms\n" +
			"Render: " + Std.string(HXP._renderTime) + "ms";
		_fpsInfoText1.text =
			"System: " + Std.string(HXP._systemTime) + "ms\n" +
			"Game: " + Std.string(HXP._gameTime) + "ms";
#if !js
		_memReadText.text =
			(width >= BIG_WIDTH_THRESHOLD ? "Mem: " : "") + MathUtil.roundDecimal(flash.system.System.totalMemory / 1024 / 1024, 2) + "MB";
#end
	}

	/** @private Update the debug panel text. */
	function updateDebugRead()
	{
		var str:String;
		// Find out the screen size and set the text.
		var big:Bool = width >= BIG_WIDTH_THRESHOLD;

		// Update the Debug read text.
		var s:String =
			"Mouse: " + Std.string(HXP.scene.mouseX) + ", " + Std.string(HXP.scene.mouseY) +
			"\nCamera: " + Std.string(HXP.camera.x) + ", " + Std.string(HXP.camera.y);
		if (SELECT_LIST.length != 0)
		{
			if (SELECT_LIST.length > 1)
			{
				s += "\n\nSelected: " + Std.string(SELECT_LIST.length);
			}
			else
			{
				var e:Entity = SELECT_LIST[0];
				s += "\n\n- " + Type.getClassName(Type.getClass(e)) + " -\n";
				for (str in WATCH_LIST)
				{
					var field = Reflect.field(e, str);
					if (field != null)
					{
						s += "\n" + str + ": " + Std.string(field);
					}
				}
			}
		}

		// Set the text and format.
		_debReadText1.text = s;
		_debReadText1.setTextFormat(format(big ? 16 : 8));
		_debReadText1.width = Math.max(_debReadText1.textWidth + 4, _debReadText0.width);
		_debReadText1.height = _debReadText1.y + _debReadText1.textHeight + 4;

		// The debug panel.
		_debRead.y = Std.int(height - _debReadText1.height);
		_debRead.graphics.clear();
		_debRead.graphics.beginFill(0, .75);
		_debRead.graphics.drawRect(0, 0, _debReadText0.width - 20, 20);
		_debRead.graphics.moveTo(_debReadText0.width, 20);
		_debRead.graphics.lineTo(_debReadText0.width - 20, 20);
		_debRead.graphics.lineTo(_debReadText0.width - 20, 0);
		_debRead.graphics.curveTo(_debReadText0.width, 0, _debReadText0.width, 20);
		_debRead.graphics.drawRoundRect(-20, 20, _debReadText1.width + 40, height - _debRead.y, 40, 40);
	}

	/** @private Updates the Entity count text. */
	function updateEntityCount()
	{
		_entReadText.text = Std.string(HXP.scene.count) + " Entities";
	}

	/** @private Updates the Button panel. */
	function updateButtons()
	{
		// Button visibility.
		_butRead.x = (width >= BIG_WIDTH_THRESHOLD ? _fpsInfo.x + _fpsInfoText0.width + _fpsInfoText1.width + Std.int((_entRead.x - (_fpsInfo.x + _fpsInfoText0.width + _fpsInfoText1.width)) / 2) - 30 : 160 + 20);
		_butDebug.visible = _paused && !_debug;
		_butOutput.visible = _paused && _debug;
		_butPlay.visible = HXP.engine.paused;
		_butPause.visible = !HXP.engine.paused;
		_butStep.visible = _paused;

		// Debug/Output button.
		if (_butDebug.bitmapData.rect.contains(_butDebug.mouseX, _butDebug.mouseY))
		{
			_butDebug.alpha = _butOutput.alpha = 1;
			if (Mouse.mousePressed) debug = !_debug;
		}
		else _butDebug.alpha = _butOutput.alpha = 0.5;

		// Play/Pause button.
		if (_butPlay.bitmapData.rect.contains(_butPlay.mouseX, _butPlay.mouseY))
		{
			_butPlay.alpha = _butPause.alpha = 1;
			if (Mouse.mousePressed)
			{
				HXP.engine.paused = !HXP.engine.paused;
				renderEntities();
			}
		}
		else _butPlay.alpha = _butPause.alpha = 0.5;

		// Frame step button.
		if (_butStep.bitmapData.rect.contains(_butStep.mouseX, _butStep.mouseY))
		{
			_butStep.alpha = 1;
			if (Mouse.mousePressed) stepFrame();
		}
		else _butStep.alpha = .5;
	}

	/** @private Gets a TextFormat object with the formatting. */
	function format(size:Int = 16, color:Color = 0xFFFFFF, align:String = "left"):TextFormat
	{
		_format.size = size;
		_format.color = color;
		switch (align)
		{
			case "left":
				_format.align = TextFormatAlign.LEFT;
			case "right":
				_format.align = TextFormatAlign.RIGHT;
			case "center":
				_format.align = TextFormatAlign.CENTER;
			case "justify":
				_format.align = TextFormatAlign.JUSTIFY;
		}
		return _format;
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
	var _enabled:Bool;
	var _visible:Bool;
	var _paused:Bool;
	var _debug:Bool;
	var _scrolling:Bool;
	var _selecting:Bool;
	var _dragging:Bool;
	var _panning:Bool;

	// Console display objects.
	var _sprite:Sprite;
	var _format:TextFormat;
	var _back:Bitmap;

	// FPS panel information.
	var _fpsRead:Sprite;
	var _fpsReadText:TextField;
	var _fpsInfo:Sprite;
	var _fpsInfoText0:TextField;
	var _fpsInfoText1:TextField;
	var _memReadText:TextField;

	// Layer panel information
	var _layerList:LayerList;

	// Output panel information.
	var _logRead:Sprite;
	var _logReadText0:TextField;
	var _logReadText1:TextField;
	var _logHeight:Int;
	var _logBar:Rectangle;
	var _logBarGlobal:Rectangle;
	var _logScroll:Float;

	// Entity count panel information.
	var _entRead:Sprite;
	var _entReadText:TextField;

	// Debug panel information.
	var _debRead:Sprite;
	var _debReadText0:TextField;
	var _debReadText1:TextField;

	// Button panel information
	var _butRead:Sprite;
	var _butDebug:Bitmap;
	var _butOutput:Bitmap;
	var _butPlay:Bitmap;
	var _butPause:Bitmap;
	var _butStep:Bitmap;

	var _bmpLogo:Bitmap;

	// Entity selection information.
	var _entScreen:Sprite;
	var _entSelect:Sprite;
	var _entRect:Rectangle;

	// Log information.
	var _logLines:Int;
	var LOG:Array<String>;

	// Entity lists.
	var LAYER_LIST:IntMap<Int>;
	var ENTITY_LIST:Array<Entity>;
	var SCREEN_LIST:Array<Entity>;
	var SELECT_LIST:Array<Entity>;

	// Watch information.
	var WATCH_LIST:Array<String>;

	// Switch to small text in debug if console width > this threshold.
	static inline var BIG_WIDTH_THRESHOLD:Int = 420;

}
