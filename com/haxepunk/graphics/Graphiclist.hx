package com.haxepunk.graphics;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * A Graphic that can contain multiple Graphics of one or various types.
 * Useful for drawing sprites with multiple different parts, etc.
 */
class Graphiclist extends Graphic
{
	/**
	 * Constructor.
	 * @param	graphic		Graphic objects to add to the list.
	 */
	public function new(?graphic:Array<Graphic>)
	{
		_graphics = new Array<Graphic>();
		_temp = new Array<Graphic>();
		_camera = new Point();
		_count = 0;

		super();

		if (graphic != null)
		{
			for (g in graphic) add(g);
		}
	}

	/** @private Updates the graphics in the list. */
	@:dox(hide)
	override public function update()
	{
		for (g in _graphics)
		{
			if (g.active) g.update();
		}
	}

	private inline function renderList(renderFunc:Graphic->Void, point:Point, camera:Point)
	{
		point.x += x;
		point.y += y;
		camera.x *= scrollX;
		camera.y *= scrollY;

		for (g in _graphics)
		{
			if (g.visible)
			{
				if (g.relative)
				{
					_point.x = point.x;
					_point.y = point.y;
				}
				else _point.x = _point.y = 0;
				_camera.x = camera.x;
				_camera.y = camera.y;
				renderFunc(g);
			}
		}
	}

	/** @private Renders the Graphics in the list. */
	@:dox(hide)
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		renderList(function(g:Graphic) {
			g.render(target, _point, _camera);
		}, point, camera);
	}

	/** @private Renders the Graphics in the list. */
	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		renderList(function(g:Graphic) {
			g.renderAtlas(layer, _point, _camera);
		}, point, camera);
	}

	/**
	 * Destroys the list of graphics
	 */
	override public function destroy()
	{
		for (g in _graphics)
		{
			g.destroy();
		}
	}

	/**
	 * Adds the Graphic to the list.
	 * @param	graphic		The Graphic to add.
	 * @return	The added Graphic.
	 */
	public function add(graphic:Graphic):Graphic
	{
		if (graphic == null) return graphic;

		// set blit mode on first add
		if (_count == 0) blit = graphic.blit;
		else if (blit != graphic.blit) throw "Can't add graphic objects with different render methods.";

		_graphics[_count ++] = graphic;
		if (!active) active = graphic.active;
		return graphic;
	}

	/**
	 * Removes the Graphic from the list.
	 * @param	graphic		The Graphic to remove.
	 * @return	The removed Graphic.
	 */
	public function remove(graphic:Graphic):Graphic
	{
		if (HXP.indexOf(_graphics, graphic) < 0) return graphic;
		HXP.clear(_temp);

		for (g in _graphics)
		{
			if (g == graphic) _count --;
			else _temp[_temp.length] = g;
		}
		var temp:Array<Graphic> = _graphics;
		_graphics = _temp;
		_temp = temp;
		updateCheck();
		return graphic;
	}

	/**
	 * Removes the Graphic from the position in the list.
	 * @param	index		Index to remove.
	 */
	public function removeAt(index:Int = 0)
	{
		if (_graphics.length == 0) return;
		index %= _graphics.length;
		remove(_graphics[index % _graphics.length]);
		updateCheck();
	}

	/**
	 * Removes all Graphics from the list.
	 */
	public function removeAll()
	{
		HXP.clear(_graphics);
		HXP.clear(_temp);
		_count = 0;
		active = false;
	}

	/**
	 * All Graphics in this list.
	 */
	public var children(get, null):Array<Graphic>;
	private function get_children():Array<Graphic> { return _graphics; }

	/**
	 * Amount of Graphics in this list.
	 */
	public var count(get, null):Int;
	private function get_count():Int { return _count; }

	/**
	 * Check if the Graphiclist should update.
	 */
	private function updateCheck()
	{
		active = false;
		for (g in _graphics)
		{
			if (g.active)
			{
				active = true;
				return;
			}
		}
	}

	// List information.
	private var _graphics:Array<Graphic>;
	private var _temp:Array<Graphic>;
	private var _count:Int;
	private var _camera:Point;
}
