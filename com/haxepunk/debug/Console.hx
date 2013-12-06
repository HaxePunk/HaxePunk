package com.haxepunk.debug;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

#if nme
import nme.Assets;
#else
import openfl.Assets;
#end
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxe.Log;
import haxe.PosInfos;

enum TraceCapture
{
	No;
	Yes;
}

class Console
{
	/**
	 * The key used to toggle the Console on/off.
	 */
	public var toggleKey:Int;

	public function new()
	{
		init();

		Input.define("_ARROWS", [Key.RIGHT, Key.LEFT, Key.DOWN, Key.UP]);
	}

	// Initialize variables
	private function init()
	{
		_sprite = new Sprite();
		var font = Assets.getFont("font/04B_03__.ttf");
		if (font == null)
		{
			font = Assets.getFont(HXP.defaultFont);
		}
		_format = new TextFormat(font.fontName, 8, 0xFFFFFF);
		_back = new Bitmap();

		_fpsRead = new Sprite();
		_fpsReadText = new TextField();
		_fpsInfo = new Sprite();
		_fpsInfoText0 = new TextField();
		_fpsInfoText1 = new TextField();
		_memReadText = new TextField();

		_layerList = new LayerList();

		_logRead = new Sprite();
		_logReadText0 = new TextField();
		_logReadText1 = new TextField();
		_logScroll = 0;
		_logLines = 33;

		_entRead = new Sprite();
		_entReadText = new TextField();

		_debRead = new Sprite();
		_debReadText0 = new TextField();
		_debReadText1 = new TextField();

		_butRead = new Sprite();

		_entScreen = new Sprite();
		_entSelect = new Sprite();
		_entRect = new Rectangle();

		LOG = new Array<String>();

		LAYER_LIST  = new Array<Int>();
		ENTITY_LIST = new Array<Entity>();
		SCREEN_LIST = new List<Entity>();
		SELECT_LIST = new List<Entity>();

		WATCH_LIST = new List<String>();
		WATCH_LIST.add("x");
		WATCH_LIST.add("y");
		WATCH_LIST.add("layer");
	}

	private function traceLog(v:Dynamic, ?infos:PosInfos)
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
			for (i in properties) WATCH_LIST.add(i);
		}
		else
		{
			WATCH_LIST.add(properties[0]);
		}
	}
	
	/**
	 * Show the console.
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
	 * Hide the console.
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
	 * @param	trace_capture	Option to capture trace in HaxePunk.
	 * @param	toggleKey		Key used to toggle the console, tilde (~) by default.
	 */
	public function enable(?trace_capture:TraceCapture, toggleKey=Key.TILDE)
	{
		this.toggleKey = toggleKey;
		
		// Quit if the console is already enabled.
		if (_enabled) return;

		// load assets based on embedding method
		try
		{
			_bmpLogo = new Bitmap(Assets.getBitmapData("gfx/debug/console_logo.png"));
			_butDebug = new Bitmap(Assets.getBitmapData("gfx/debug/console_debug.png"));
			_butOutput = new Bitmap(Assets.getBitmapData("gfx/debug/console_output.png"));
			_butPlay = new Bitmap(Assets.getBitmapData("gfx/debug/console_play.png"));
			_butPause = new Bitmap(Assets.getBitmapData("gfx/debug/console_pause.png"));
			_butStep = new Bitmap(Assets.getBitmapData("gfx/debug/console_step.png"));
		} catch (e:Dynamic) {
			return;
		}

		// Enable it and add the Sprite to the stage.
		_enabled = true;
		_visible = true;
		HXP.stage.addChild(_sprite);

		// Used to determine some text sizing.
		var big:Bool = width >= 480;

		// The transparent FlashPunk logo overlay bitmap.
		_sprite.addChild(_back);

		// The entity and selection sprites.
		_sprite.addChild(_entScreen);
		_entScreen.addChild(_entSelect);

		// The entity count text.
		_sprite.addChild(_entRead);
		_entRead.addChild(_entReadText);
		_entReadText.defaultTextFormat = format(16, 0xFFFFFF, "right");
#if flash
		_entReadText.embedFonts = true;
#end
		_entReadText.width = 100;
		_entReadText.height = 20;

		// The entity count panel.
		_entRead.graphics.clear();
		_entRead.graphics.beginFill(0, .5);
#if flash
		_entRead.graphics.drawRoundRectComplex(0, 0, _entReadText.width, 20, 0, 0, 20, 0);
#else
		_entRead.graphics.drawRoundRect(0, -20, _entReadText.width + 40, 40, 20, 20);
#end

		// The FPS text.
		_sprite.addChild(_fpsRead);
		_fpsRead.addChild(_fpsReadText);
		_fpsReadText.defaultTextFormat = format(16);
#if flash
		_fpsReadText.embedFonts = true;
#end
		_fpsReadText.width = 70;
		_fpsReadText.height = 20;
		_fpsReadText.x = 2;
		_fpsReadText.y = 1;

		// The FPS and frame timing panel.
		_fpsRead.graphics.clear();
		_fpsRead.graphics.beginFill(0, .75);
#if flash
		_fpsRead.graphics.drawRoundRectComplex(0, 0, big ? 200 : 100, 20, 0, 0, 0, 20);
#else
		_fpsRead.graphics.drawRoundRect(-20, -20, (big ? 220 : 120), 40, 20, 20);
#end

		//_sprite.addChild(_layerList);

		// The frame timing text.
		if (big) _sprite.addChild(_fpsInfo);
		_fpsInfo.addChild(_fpsInfoText0);
		_fpsInfo.addChild(_fpsInfoText1);
		_fpsInfoText0.defaultTextFormat = format(8, 0xAAAAAA);
		_fpsInfoText1.defaultTextFormat = format(8, 0xAAAAAA);
#if flash
		_fpsInfoText0.embedFonts = true;
		_fpsInfoText1.embedFonts = true;
#end
		_fpsInfoText0.width = _fpsInfoText1.width = 60;
		_fpsInfoText0.height = _fpsInfoText1.height = 20;
		_fpsInfo.x = 75;
		_fpsInfoText1.x = 60;

#if !js
		_fpsRead.addChild(_memReadText);
		_memReadText.defaultTextFormat = format(16);
		_memReadText.embedFonts = true;
		_memReadText.width = 110;
		_memReadText.height = 20;
		_memReadText.x = 2;
		_memReadText.y = _fpsInfo.height + 2;
#end

		// The output log text.
		_sprite.addChild(_logRead);
		_logRead.addChild(_logReadText0);
		_logRead.addChild(_logReadText1);
		_logReadText0.defaultTextFormat = format(16, 0xFFFFFF);
		_logReadText1.defaultTextFormat = format(big ? 16 : 8, 0xFFFFFF);
#if flash
		_logReadText0.embedFonts = true;
		_logReadText1.embedFonts = true;
#end
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
		_logLines = Std.int(_logHeight / (big ? 16.5 : 8.5));

		// The debug text.
		_sprite.addChild(_debRead);
		_debRead.addChild(_debReadText0);
		_debRead.addChild(_debReadText1);
		_debReadText0.defaultTextFormat = format(16, 0xFFFFFF);
		_debReadText1.defaultTextFormat = format(8, 0xFFFFFF);
#if flash
		_debReadText0.embedFonts = true;
		_debReadText1.embedFonts = true;
#end
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
#if flash
		_butRead.graphics.drawRoundRectComplex( -20, 0, 100, 20, 0, 0, 20, 20);
#else
		_butRead.graphics.drawRoundRect(-20, -20, 100, 40, 20, 20);
#end
		debug = true;

		// redraws the logo
		HXP.stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);

		// Set the state to unpaused.
		paused = false;

		if (trace_capture != TraceCapture.No)
			Log.trace = traceLog;		
		
		LOG.push("-- HaxePunk v" + HXP.VERSION + " --");
		if (_enabled && _sprite.visible) updateLog();
	}

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
	public var visible(get_visible, set_visible):Bool;
	private function get_visible():Bool { return _sprite.visible; }
	private function set_visible(value:Bool):Bool
	{
		_sprite.visible = value;
		if (_enabled && value) updateLog();
		return _sprite.visible;
	}

	/**
	 * Console update, called by game loop.
	 */
	public function update()
	{
		// Quit if the console isn't enabled or visible.
		if (!_enabled || !_visible)
			return;

		// move on resize
		_entRead.x = width - _entReadText.width;
		_layerList.x = width - _layerList.width - 20;
		_layerList.y = (height - _layerList.height) / 2;


		// Update buttons.
		if (_butRead.visible)
			updateButtons();

		// If the console is paused.
		if (_paused)
		{

			// While in debug mode.
			if (_debug)
			{
				// While the game is paused.
				if (HXP.engine.paused)
				{
					// When the mouse is pressed.
					if (Input.mousePressed)
					{
						// Mouse is within clickable area.
						if (Input.mouseFlashY > 20 && (Input.mouseFlashX > _debReadText1.width || Input.mouseFlashY < _debRead.y))
						{
							if (Input.check(Key.SHIFT))
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
					if (Input.pressed(Key.A)) selectAll();

					// If the shift key is held.
					if (Input.check(Key.SHIFT))
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

					_layerList.update();
				}
				else
				{
					// Update info while the game runs.
					updateEntityLists(HXP.scene.count != ENTITY_LIST.length);
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
				else if (Input.mousePressed) startScrolling();
			}
		}
		else
		{
			// Update info while the game runs.
			updateFPSRead();
			updateEntityCount();
		}

		// Console toggle.
		if (Input.pressed(toggleKey)) paused = !_paused;
	}

	/**
	 * If the Console is currently in paused mode.
	 */
	public var paused(get_paused, set_paused):Bool;
	private function get_paused():Bool { return _paused; }
	private function set_paused(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (!_enabled) return false;

		// Set the console to paused.
		_paused = value;
		HXP.engine.paused = value;

		// Panel visibility.
		_back.visible = value;
		_entScreen.visible = value;
		_layerList.visible = value;
#if !mobile // buttons always show on mobile devices
		_butRead.visible = value;
#end

		// If the console is paused.
		if (value)
		{
			// Set the console to paused mode.
			if (_debug) debug = true;
			else updateLog();
		}
		else
		{
			// Set the console to running mode.
			_debRead.visible = false;
			_logRead.visible = true;
			updateLog();
			HXP.clear(ENTITY_LIST);
			SCREEN_LIST.clear();
			SELECT_LIST.clear();
		}
		return _paused;
	}

	/**
	 * If the Console is currently in debug mode.
	 */
	public var debug(get_debug, set_debug):Bool;
	private function get_debug():Bool { return _debug; }
	private function set_debug(value:Bool):Bool
	{
		// Quit if the console isn't enabled.
		if (!_enabled) return false;

		// Set the console to debug mode.
		_debug = value;
		_debRead.visible = value;
		_layerList.visible = value;
		_logRead.visible = !value;

		// Update console state.
		if (value) updateEntityLists();
		else updateLog();
		renderEntities();
		return _debug;
	}

	/** @private Steps the frame ahead. */
	private function stepFrame()
	{
		HXP.engine.update();
		HXP.engine.render();
		updateEntityCount();
		updateEntityLists();
		renderEntities();
	}

	/** @private Starts Entity dragging. */
	private function startDragging()
	{
		_dragging = true;
		_entRect.x = Input.mouseX;
		_entRect.y = Input.mouseY;
	}

	/** @private Updates Entity dragging. */
	private function updateDragging()
	{
		moveSelected(Std.int(Input.mouseX - _entRect.x), Std.int(Input.mouseY - _entRect.y));
		_entRect.x = Input.mouseX;
		_entRect.y = Input.mouseY;
		if (Input.mouseReleased) _dragging = false;
	}

	/** @private Move the selected Entitites by the amount. */
	private function moveSelected(xDelta:Int, yDelta:Int)
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
	private function startPanning()
	{
		_panning = true;
		_entRect.x = Input.mouseX;
		_entRect.y = Input.mouseY;
	}

	/** @private Updates camera panning. */
	private function updatePanning()
	{
		if (Input.mouseReleased) _panning = false;
		panCamera(Std.int(_entRect.x - Input.mouseX), Std.int(_entRect.y - Input.mouseY));
		_entRect.x = Input.mouseX;
		_entRect.y = Input.mouseY;
	}

	/** @private Pans the camera. */
	private function panCamera(xDelta:Int, yDelta:Int)
	{
		HXP.camera.x += xDelta;
		HXP.camera.y += yDelta;
		HXP.engine.render();
		updateEntityLists(true);
		renderEntities();
	}

	/** @private Sets the camera position. */
	private function setCamera(x:Int, y:Int)
	{
		HXP.camera.x = x;
		HXP.camera.y = y;
		HXP.engine.render();
		updateEntityLists(true);
		renderEntities();
	}

	/** @private Starts Entity selection. */
	private function startSelection()
	{
		_selecting = true;
		_entRect.x = Input.mouseFlashX;
		_entRect.y = Input.mouseFlashY;
		_entRect.width = 0;
		_entRect.height = 0;
	}

	/** @private Updates Entity selection. */
	private function updateSelection()
	{
		_entRect.width = Input.mouseFlashX - _entRect.x;
		_entRect.height = Input.mouseFlashY - _entRect.y;
		if (Input.mouseReleased)
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
	private function selectEntities(rect:Rectangle)
	{
		if (rect.width < 0) rect.x -= (rect.width = -rect.width);
		else if (rect.width == 0) rect.width = 1;
		if (rect.height < 0) rect.y -= (rect.height = -rect.height);
		else if (rect.height == 0) rect.height = 1;

		HXP.rect.width = HXP.rect.height = 6;
		var sx:Float = HXP.screen.fullScaleX,
			sy:Float = HXP.screen.fullScaleY,
			e:Entity;

		if (Input.check(Key.CONTROL))
		{
			// Append selected Entitites with new selections.
			for (e in SCREEN_LIST)
			{
				if (Lambda.indexOf(SELECT_LIST, e) < 0)
				{
					HXP.rect.x = (e.x - HXP.camera.x) * sx - 3;
					HXP.rect.y = (e.y - HXP.camera.y) * sy - 3;
					if (rect.intersects(HXP.rect)) SELECT_LIST.push(e);
				}
			}
		}
		else
		{
			// Replace selections with new selections.
			SELECT_LIST.clear();
			for (e in SCREEN_LIST)
			{
				HXP.rect.x = (e.x - HXP.camera.x) * sx - 3;
				HXP.rect.y = (e.y - HXP.camera.y) * sy - 3;
				if (rect.intersects(HXP.rect)) SELECT_LIST.push(e);
			}
		}
	}

	/** @private Selects all entities on screen. */
	private function selectAll()
	{
		var e:Entity;
		SELECT_LIST.clear();
		for (e in SCREEN_LIST) SELECT_LIST.push(e);
		renderEntities();
	}

	/** @private Starts log text scrolling. */
	private function startScrolling()
	{
		if (LOG.length > _logLines) _scrolling = _logBarGlobal.contains(Input.mouseFlashX, Input.mouseFlashY);
	}

	/** @private Updates log text scrolling. */
	private function updateScrolling()
	{
		_scrolling = Input.mouseDown;
		_logScroll = HXP.scaleClamp(Input.mouseFlashY, _logBarGlobal.y, _logBarGlobal.bottom, 0, 1);
		updateLog();
	}

	/** @private Moves Entities with the arrow keys. */
	private function updateKeyMoving()
	{
		HXP.point.x = (Input.pressed(Key.RIGHT) ? 1 : 0) - (Input.pressed(Key.LEFT) ? 1 : 0);
		HXP.point.y = (Input.pressed(Key.DOWN) ? 1 : 0) - (Input.pressed(Key.UP) ? 1 : 0);
		if (HXP.point.x != 0 || HXP.point.y != 0) moveSelected(Std.int(HXP.point.x), Std.int(HXP.point.y));
	}

	/** @private Pans the camera with the arrow keys. */
	private function updateKeyPanning()
	{
		HXP.point.x = (Input.check(Key.RIGHT) ? 1 : 0) - (Input.check(Key.LEFT) ? 1 : 0);
		HXP.point.y = (Input.check(Key.DOWN) ? 1 : 0) - (Input.check(Key.UP) ? 1 : 0);
		if (HXP.point.x != 0 || HXP.point.y != 0) panCamera(Std.int(HXP.point.x), Std.int(HXP.point.y));
	}

	/** @private Update the Entity list information. */
	private function updateEntityLists(fetchList:Bool = true)
	{
		// If the list should be re-populated.
		if (fetchList)
		{
			HXP.clear(ENTITY_LIST);
			HXP.clear(LAYER_LIST);
			HXP.scene.getAll(ENTITY_LIST);
		}

		// Update the list of Entities on screen.
		SCREEN_LIST.clear();
		for (e in ENTITY_LIST)
		{
			if (e.onCamera)
				SCREEN_LIST.push(e);

			if (Lambda.indexOf(LAYER_LIST, e.layer) < 0)
				LAYER_LIST.push(e.layer);
		}
		// sort the layers
		LAYER_LIST.sort(function (a:Int, b:Int):Int { return a - b; });
		_layerList.set(LAYER_LIST);
	}

	/** @private Renders the Entities positions and hitboxes. */
	private function renderEntities()
	{
		var e:Entity;
		// If debug mode is on.
		_entScreen.visible = _debug;
		if (_debug)
		{
			var g:Graphics = _entScreen.graphics,
				sx:Float = HXP.screen.fullScaleX,
				sy:Float = HXP.screen.fullScaleY;
			g.clear();
			for (e in SCREEN_LIST)
			{
				var graphicScrollX = e.graphic != null ? e.graphic.scrollX : 1;
				var graphicScrollY = e.graphic != null ? e.graphic.scrollY : 1;

				// If the Entity is not selected.
				if (Lambda.indexOf(SELECT_LIST, e) < 0)
				{
					// Draw the normal hitbox and position.
					if (e.width != 0 && e.height != 0)
					{
						g.lineStyle(1, 0xFF0000);
						g.drawRect((e.x - e.originX - HXP.camera.x * graphicScrollX) * sx, (e.y - e.originY - HXP.camera.y * graphicScrollY) * sy, e.width * sx, e.height * sy);

						if (e.mask != null)
						{
							g.lineStyle(1, 0x0000FF);
							e.mask.debugDraw(g, sx, sy);
						}
					}
					g.lineStyle(1, 0x00FF00);
					g.drawRect((e.x - HXP.camera.x * graphicScrollX) * sx - 3, (e.y - HXP.camera.y * graphicScrollY) * sy - 3, 6, 6);
				}
				else
				{
					// Draw the selected hitbox and position.
					if (e.width != 0 && e.height != 0)
					{
						g.lineStyle(1, 0xFFFFFF);
						g.drawRect((e.x - e.originX - HXP.camera.x * graphicScrollX) * sx, (e.y - e.originY - HXP.camera.y * graphicScrollY) * sy, e.width * sx, e.height * sy);

						if (e.mask != null)
						{
							g.lineStyle(1, 0x0000FF);
							e.mask.debugDraw(g, sx, sy);
						}
					}
					g.lineStyle(1, 0xFFFFFF);
					g.drawRect((e.x - HXP.camera.x * graphicScrollX) * sx - 3, (e.y - HXP.camera.y * graphicScrollY) * sy - 3, 6, 6);
				}
			}
		}
	}

	/** @private Updates the log window. */
	private function updateLog()
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
#if flash
			_logRead.graphics.drawRoundRectComplex(0, 0, _logReadText0.width, 20, 0, 20, 0, 0);
#else
			_logRead.graphics.drawRect(0, 0, _logReadText0.width, 20);
#end
			_logRead.graphics.drawRect(0, 20, width, _logHeight);

			// Draw the log scrollbar.
			_logRead.graphics.beginFill(0x202020, 1);
#if flash
			_logRead.graphics.drawRoundRectComplex(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 8, 8, 8, 8);
#else
			_logRead.graphics.drawRoundRect(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 8, 8);
#end

			// If the log has more lines than the display limit.
			if (LOG.length > _logLines)
			{
				// Draw the log scrollbar handle.
				_logRead.graphics.beginFill(0xFFFFFF, 1);
				var y:Int = Std.int(_logBar.y + 2 + (_logBar.height - 16) * _logScroll);
#if flash
				_logRead.graphics.drawRoundRectComplex(_logBar.x + 2, y, 12, 12, 6, 6, 6, 6);
#else
				_logRead.graphics.drawRoundRect(_logBar.x + 2, y, 12, 12, 6, 6);
#end
			}

			// Display the log text lines.
			if (LOG.length != 0)
			{
				var i:Int = (LOG.length > _logLines) ? Std.int(Math.round((LOG.length - _logLines) * _logScroll)) : 0,
					n:Int = Std.int(i + Math.min(_logLines, LOG.length)),
					s:String = "";
				while (i < n) s += LOG[i ++] + "\n";
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
#if flash
			_logRead.graphics.drawRoundRectComplex(0, 0, _logReadText0.width, 20, 0, 20, 0, 0);
#else
			_logRead.graphics.drawRect(0, 0, _logReadText0.width, 20);
#end
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
	private function updateFPSRead()
	{
		_fpsReadText.text = "FPS: " + Std.int(HXP.frameRate);
		_fpsInfoText0.text =
			"Update: " + Std.string(HXP._updateTime) + "ms\n" +
			"Render: " + Std.string(HXP._renderTime) + "ms";
		_fpsInfoText1.text =
			"System: " + Std.string(HXP._systemTime) + "ms\n" +
			"Game: " + Std.string(HXP._gameTime) + "ms";
		_memReadText.text =
			"Mem: " + HXP.round(System.totalMemory / 1024 / 1024, 2) + "MB";
	}

	/** @private Update the debug panel text. */
	private function updateDebugRead()
	{
		var str:String;
		// Find out the screen size and set the text.
		var big:Bool = width >= 480;

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
				var e:Entity = SELECT_LIST.first();
				s += "\n\n- " + Type.getClassName(Type.getClass(e)) + " -\n";
				for (str in WATCH_LIST)
				{
#if flash
					var field = Reflect.getProperty(e, str);
#else
					var field = Reflect.field(e, str);
#end
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
#if flash
		_debRead.graphics.drawRoundRectComplex(0, 0, _debReadText0.width, 20, 0, 20, 0, 0);
		_debRead.graphics.drawRoundRectComplex(0, 20, _debReadText1.width + 20, height - _debRead.y - 20, 0, 20, 0, 0);
#else
		_debRead.graphics.drawRect(0, 0, _debReadText0.width, 20);
		_debRead.graphics.drawRect(0, 20, _debReadText1.width + 20, height - _debRead.y - 20);
#end
	}

	/** @private Updates the Entity count text. */
	private function updateEntityCount()
	{
		_entReadText.text = Std.string(HXP.scene.count) + " Entities";
	}

	/** @private Updates the Button panel. */
	private function updateButtons()
	{
		// Button visibility.
		_butRead.x = _fpsInfo.x + _fpsInfo.width + Std.int((_entRead.x - (_fpsInfo.x + _fpsInfo.width)) / 2) - 30;
		_butDebug.visible = _paused && !_debug;
		_butOutput.visible = _paused && _debug;
		_butPlay.visible = HXP.engine.paused;
		_butPause.visible = !HXP.engine.paused;
		_butStep.visible = _paused;

		// Debug/Output button.
		if (_butDebug.bitmapData.rect.contains(_butDebug.mouseX, _butDebug.mouseY))
		{
			_butDebug.alpha = _butOutput.alpha = 1;
			if (Input.mousePressed) debug = !_debug;
		}
		else _butDebug.alpha = _butOutput.alpha = 0.5;

		// Play/Pause button.
		if (_butPlay.bitmapData.rect.contains(_butPlay.mouseX, _butPlay.mouseY))
		{
			_butPlay.alpha = _butPause.alpha = 1;
			if (Input.mousePressed)
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
			if (Input.mousePressed) stepFrame();
		}
		else _butStep.alpha = .5;
	}

	/** @private Gets a TextFormat object with the formatting. */
	private function format(size:Int = 16, color:Int = 0xFFFFFF, align:String = "left"):TextFormat
	{
		_format.size = size;
		_format.color = color;
		switch(align)
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
	 * Get the unscaled screen size for the Console.
	 */
	public var width(get_width, null):Int;
	private function get_width():Int { return HXP.windowWidth; }

	public var height(get_height, null):Int;
	private function get_height():Int { return HXP.windowHeight; }

	// Console state information.
	private var _enabled:Bool;
	private var _visible:Bool;
	private var _paused:Bool;
	private var _debug:Bool;
	private var _scrolling:Bool;
	private var _selecting:Bool;
	private var _dragging:Bool;
	private var _panning:Bool;

	// Console display objects.
	private var _sprite:Sprite;
	private var _format:TextFormat;
	private var _back:Bitmap;

	// FPS panel information.
	private var _fpsRead:Sprite;
	private var _fpsReadText:TextField;
	private var _fpsInfo:Sprite;
	private var _fpsInfoText0:TextField;
	private var _fpsInfoText1:TextField;
	private var _memReadText:TextField;

	// Layer panel information
	private var _layerList:LayerList;

	// Output panel information.
	private var _logRead:Sprite;
	private var _logReadText0:TextField;
	private var _logReadText1:TextField;
	private var _logHeight:Int;
	private var _logBar:Rectangle;
	private var _logBarGlobal:Rectangle;
	private var _logScroll:Float;

	// Entity count panel information.
	private var _entRead:Sprite;
	private var _entReadText:TextField;

	// Debug panel information.
	private var _debRead:Sprite;
	private var _debReadText0:TextField;
	private var _debReadText1:TextField;

	// Button panel information
	private var _butRead:Sprite;
	private var _butDebug:Bitmap;
	private var _butOutput:Bitmap;
	private var _butPlay:Bitmap;
	private var _butPause:Bitmap;
	private var _butStep:Bitmap;

	private var _bmpLogo:Bitmap;

	// Entity selection information.
	private var _entScreen:Sprite;
	private var _entSelect:Sprite;
	private var _entRect:Rectangle;

	// Log information.
	private var _logLines:Int;
	private var LOG:Array<String>;

	// Entity lists.
	private var LAYER_LIST:Array<Int>;
	private var ENTITY_LIST:Array<Entity>;
	private var SCREEN_LIST:List<Entity>;
	private var SELECT_LIST:List<Entity>;

	// Watch information.
	private var WATCH_LIST:List<String>;
}
