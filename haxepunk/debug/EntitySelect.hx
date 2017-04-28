package haxepunk.debug;

import haxe.ds.IntMap;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.Entity;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.Signal.Signal1;

enum MouseMode
{
	None;
	Panning;
	Selecting;
	Dragging;
}

class EntitySelect extends Sprite
{

	public var onLayerCount = new Signal1<IntMap<Int>>();
	public var selected = new Array<Entity>();

	public function new()
	{
		super();
		this.addChild(_entSelect);
	}

	public function update()
	{
		// When the mouse is pressed.
		if (Mouse.mousePressed)
		{
			// Mouse is within clickable area.
			if (Mouse.mouseFlashY > 20)
			{
				if (Key.check(Key.SHIFT))
				{
					if (selected.length != 0) startDragging();
					else startPanning();
				}
				else startSelection();
			}
		}
		else
		{
			// Update mouse movement functions.
			switch (_mouseMode)
			{
				case Selecting:
					select(getMouseRectangle());
				case Dragging:
					updateDragging();
				case Panning:
					updatePanning();
				case None:
			}
		}

		// Select all Entities
		if (Key.pressed(Key.A)) selectAll();

		// If the shift key is held.
		if (Key.check(Key.SHIFT))
		{
			// If Entities are selected.
			if (selected.length != 0)
			{
				// Move Entities with the arrow keys.
				keyMove(moveSelected);
			}
			else
			{
				// Pan the camera with the arrow keys.
				keyMove(panCamera);
			}
		}
	}

	inline function keyMove(func:Int->Int->Void)
	{
		var x = (Key.pressed(Key.RIGHT) ? 1 : 0) - (Key.pressed(Key.LEFT) ? 1 : 0);
		var y = (Key.pressed(Key.DOWN) ? 1 : 0) - (Key.pressed(Key.UP) ? 1 : 0);
		if (x == 0 && y == 0) return;
		func(x, y);
	}

	function select(rect:Rectangle)
	{
		if (Mouse.mouseReleased)
		{
			selectEntities(rect);
			_mouseMode = None;
			_entSelect.graphics.clear();
		}
		else
		{
			_entSelect.graphics.clear();
			_entSelect.graphics.lineStyle(1, 0xFFFFFF);
			_entSelect.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		}
	}

	/** @private Starts Entity dragging. */
	function startDragging()
	{
		_mouseMode = Dragging;
		_mouseOrigin.x = Mouse.mouseX;
		_mouseOrigin.y = Mouse.mouseY;
	}

	/** @private Updates Entity dragging. */
	function updateDragging()
	{
		moveSelected(Std.int(Mouse.mouseX - _mouseOrigin.x), Std.int(Mouse.mouseY - _mouseOrigin.y));
		_mouseOrigin.x = Mouse.mouseX;
		_mouseOrigin.y = Mouse.mouseY;
		if (Mouse.mouseReleased) _mouseMode = None;
	}

	/** @private Starts Entity selection. */
	function startSelection()
	{
		_mouseMode = Selecting;
		_mouseOrigin.x = Mouse.mouseFlashX;
		_mouseOrigin.y = Mouse.mouseFlashY;
	}

	function getMouseRectangle():Rectangle
	{
		var rect = new Rectangle(
			_mouseOrigin.x,
			_mouseOrigin.y,
			Mouse.mouseFlashX - _mouseOrigin.x,
			Mouse.mouseFlashY - _mouseOrigin.y
		);

		// make sure rectangle stays positive
		if (rect.width < 0) rect.x -= (rect.width = -rect.width);
		if (rect.height < 0) rect.y -= (rect.height = -rect.height);

		return rect;
	}

	/** @private Move the selected Entitites by the amount. */
	function moveSelected(xDelta:Int, yDelta:Int)
	{
		for (e in selected)
		{
			e.x += xDelta;
			e.y += yDelta;
		}
		HXP.engine.render();
		draw();
		updateEntityLists(true);
	}

	/** @private Starts camera panning. */
	function startPanning()
	{
		_mouseMode = Panning;
		_mouseOrigin.x = Mouse.mouseX;
		_mouseOrigin.y = Mouse.mouseY;
	}

	/** @private Updates camera panning. */
	function updatePanning()
	{
		if (Mouse.mouseReleased) _mouseMode = None;
		panCamera(Std.int(_mouseOrigin.x - Mouse.mouseX), Std.int(_mouseOrigin.y - Mouse.mouseY));
		_mouseOrigin.x = Mouse.mouseX;
		_mouseOrigin.y = Mouse.mouseY;
	}

	/** @private Pans the camera. */
	function panCamera(xDelta:Int, yDelta:Int)
	{
		HXP.camera.x += xDelta;
		HXP.camera.y += yDelta;
		HXP.engine.render();
		updateEntityLists(true);
		draw();
	}

	/** @private Renders the Entities positions and hitboxes. */
	public function draw(forceUpdate:Bool=false)
	{
		if (!this.visible) return;

		updateEntityLists(forceUpdate || HXP.scene.count != ENTITY_LIST.length);

		this.x = HXP.screen.x;
		this.y = HXP.screen.y;

		var g:Graphics = this.graphics,
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
			if (HXP.indexOf(selected, e) < 0)
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
			g.drawCircle((e.x - HXP.camera.x * graphicScrollX) * sx, (e.y - HXP.camera.y * graphicScrollY) * sy, ENTITY_HANDLE_RADIUS);
		}
	}

	/**
	 * Allows masks to be turned on and off in the console
	 */
	public var debugDraw(default, set):Bool = true;
	function set_debugDraw(value:Bool):Bool
	{
		debugDraw = value;
		updateEntityLists(false);
		draw();
		return value;
	}

	/** @private Selects all entities on screen. */
	public function selectAll()
	{
		// capture number selected before clearing selection list
		var numSelected = selected.length;
		HXP.clear(selected);

		// if the number of entities on screen is the same as selected, leave the list cleared
		if (numSelected != SCREEN_LIST.length)
		{
			for (e in SCREEN_LIST) selected.push(e);
		}
		draw();
	}

	/** @private Selects the Entitites in the rectangle. */
	function selectEntities(rect:Rectangle)
	{
		// clear selections if not pressing Ctrl (which appends selections)
		if (!Key.check(Key.CONTROL))
		{
			HXP.clear(selected);
		}

		// only make selections if the rectangle has a width and height
		if (rect.width > 0 && rect.height > 0)
		{
			HXP.rect.width = HXP.rect.height = ENTITY_HANDLE_RADIUS * 2;
			// Append/Remove selected Entitites.
			for (e in SCREEN_LIST)
			{
				HXP.rect.x = (e.x - HXP.camera.x) * HXP.screen.fullScaleX - ENTITY_HANDLE_RADIUS;
				HXP.rect.y = (e.y - HXP.camera.y) * HXP.screen.fullScaleY - ENTITY_HANDLE_RADIUS;
				if (rect.intersects(HXP.rect))
				{
					if (HXP.indexOf(selected, e) < 0)
					{
						selected.push(e);
					}
					else
					{
						selected.remove(e);
					}
				}
			}
		}
	}

	public function clear()
	{
		HXP.clear(ENTITY_LIST);
		HXP.clear(SCREEN_LIST);
		HXP.clear(selected);
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
			onLayerCount.invoke(LAYER_LIST);
		}
	}

	var _entSelect = new Sprite();
	var _mouseOrigin = new Point();
	var _mouseMode:MouseMode = None;

	var ENTITY_LIST = new Array<Entity>();
	var SCREEN_LIST = new Array<Entity>();
	var LAYER_LIST = new IntMap<Int>();

	static inline var ENTITY_HANDLE_RADIUS:Int = 3;
}
