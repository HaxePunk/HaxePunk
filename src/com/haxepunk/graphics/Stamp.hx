package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;

/**
 * A simple non-transformed, non-animated graphic.
 */
class Stamp extends Graphic
{
	/**
	 * Constructor.
	 * @param	source		Source image.
	 * @param	x			X offset.
	 * @param	y			Y offset.
	 */
	public function new(source:Dynamic, x:Int = 0, y:Int = 0) 
	{
		super();
		
		// set the origin
		this.x = x;
		this.y = y;
		
		// set the graphic
		if (Std.is(source, BitmapData)) _source = source;
		else _source = HXP.getBitmap(source);
		
		if (_source == null) throw "Invalid source image.";
		
		_sourceRect = _source.rect;
	}
	
	/** @private Renders the Graphic. */
	override public function render(target:BitmapData, point:Point, camera:Point) 
	{
		if (_source == null) return;
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;
		target.copyPixels(_source, _sourceRect, _point, null, null, true);
	}
	
	/**
	 * Source BitmapData image.
	 */
	public var source(getSource, setSource):BitmapData;
	private function getSource():BitmapData { return _source; }
	private function setSource(value:BitmapData):BitmapData
	{
		_source = value;
		if (_source != null) _sourceRect = _source.rect;
		return _source;
	}
	
	// Stamp information.
	private var _source:BitmapData;
	private var _sourceRect:Rectangle;
}