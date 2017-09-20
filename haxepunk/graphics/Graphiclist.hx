package haxepunk.graphics;

import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.utils.Color;

/**
 * A Graphic that can contain multiple Graphics of one or various types.
 * Useful for drawing sprites with multiple different parts, etc.
 */
class Graphiclist extends Graphic
{
	override function set_alpha(v:Float):Float
	{
		for (graphic in _graphics)
		{
			graphic.alpha = v;
		}
		return super.set_alpha(v);
	}

	override function set_color(v:Color):Color
	{
		for (graphic in _graphics)
		{
			graphic.color = v;
		}
		return super.set_color(v);
	}

	/**
	 * Constructor.
	 * @param	graphic		Graphic objects to add to the list.
	 */
	public function new(?graphic:Array<Graphic>)
	{
		_graphics = new Array<Graphic>();
		_temp = new Array<Graphic>();
		_camera = new Camera();

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

	/**
	 * Returns the Graphic from the list.
	 * @param	i	The index of the array.
	 * @return	The graphic in n index.
	 */
	@:arrayAccess
	public function get(i:Int):Graphic
	{
		if ( i >= _graphics.length || i < 0 ) throw "Index out of bounds.";
		else return _graphics[i];
	}

	/** @private Renders the Graphics in the list. */
	override public function render(point:Point, camera:Camera)
	{
		var cx = camera.x,
			cy = camera.y;
		camera.setTo(cx * scrollX, cy * scrollY);
		for (g in _graphics)
		{
			if (g.visible)
			{
				if (g.relative)
				{
					_point.x = floorX(camera, point.x) + floorX(camera, x);
					_point.y = camera.floorY(point.y) + camera.floorY(y);
				}
				else _point.x = _point.y = 0;
				g.render(_point, camera);
			}
		}
		camera.setTo(cx, cy);
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

		_graphics[count++] = graphic;
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
			if (g == graphic) count--;
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
		count = 0;
		active = false;
	}

	/**
	 * All Graphics in this list.
	 */
	public var children(get, null):Array<Graphic>;
	function get_children():Array<Graphic> return _graphics;

	/**
	 * Amount of Graphics in this list.
	 */
	public var count(default, null):Int = 0;

	/**
	 * Check if the Graphiclist should update.
	 */
	function updateCheck()
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
	var _graphics:Array<Graphic>;
	var _temp:Array<Graphic>;
	var _camera:Camera;
}
