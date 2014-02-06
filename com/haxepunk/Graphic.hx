package com.haxepunk;

import flash.display.BitmapData;
import flash.geom.Point;

typedef AssignCallback = Void -> Void;

class Graphic
{
	/**
	 * If the graphic should update.
	 */
	public var active:Bool;

	/**
	 * If the graphic should render.
	 */
	public var visible(get, set):Bool;
	public function get_visible():Bool { return _visible; }
	public function set_visible(value:Bool):Bool { return _visible = value; }

	/**
	 * X offset.
	 */
	public var x:Float;

	/**
	 * Y offset.
	 */
	public var y:Float;

	/**
	 * X scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollX:Float;

	/**
	 * Y scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollY:Float;

	/**
	 * If the graphic should render at its position relative to its parent Entity's position.
	 */
	public var relative:Bool;

	/**
	 * If we can blit the graphic or not (flash/html5)
	 */
	public var blit(default, null):Bool;

	/**
	 * Constructor.
	 */
	public function new()
	{
		active = false;
		visible = true;
		x = y = 0;
		scrollX = scrollY = 1;
		relative = true;
		_scroll = true;
		_point = new Point();
	}

	/**
	 * Updates the graphic.
	 */
	public function update()
	{

	}

	/**
	 * Removes the graphic from the scene
	 */
	public function destroy() { }

	/**
	 * Renders the graphic to the screen buffer.
	 * @param  target     The buffer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	public function render(target:BitmapData, point:Point, camera:Point) { }

	/**
	 * Renders the graphic as an atlas.
	 * @param  layer      The layer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	public function renderAtlas(layer:Int, point:Point, camera:Point) { }

	/**
	 * Pause updating this graphic.
	 */
	public function pause()
	{
		active = false;
	}

	/**
	 * Resume updating this graphic.
	 */
	public function resume()
	{
		active = true;
	}

	// Graphic information.
	private var _scroll:Bool;
	private var _point:Point;
	private var _entity:Entity;

	private var _visible:Bool;
}
