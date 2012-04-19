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
	 * Renders the graphic to the screen buffer.
	 * @param	point		The position to draw the graphic.
	 * @param	camera		The camera offset.
	 */
	public function render(target:BitmapData, point:Point, camera:Point)
	{

	}

	/** @private Callback for when the graphic is assigned to an Entity. */
	public var assign(default, null):AssignCallback;

	// Graphic information.
	private var _scroll:Bool;
	private var _point:Point;

	#if hardware
	private var _tileSheet:nme.display.Tilesheet;
	private var imageID:Int;
	#end
}