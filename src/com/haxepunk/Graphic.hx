package com.haxepunk;

import nme.display.BitmapData;
import nme.geom.Point;

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
	public var visible:Bool;

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
	 * The layer to use for rendering, should only be set by the Entity
	 */
	public var layer(default, set_layer):Int;

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
		layer = HXP.BASELAYER;
	}

	/**
	 * Updates the graphic.
	 */
	public function update()
	{

	}

	/**
	 * Renders the graphic to the screen buffer.
	 * @param	point		The position to draw the graphic.
	 * @param	camera		The camera offset.
	 */
	public function render(target:BitmapData, point:Point, camera:Point) { }

	private function set_layer(value:Int):Int
	{
		return layer = value;
	}

	// Graphic information.
	private var _scroll:Bool;
	private var _point:Point;

	/**
	 * If we can blit the graphic or not (flash/html5)
	 */
	private var _blit:Bool;
}
