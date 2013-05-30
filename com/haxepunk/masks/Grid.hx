package com.haxepunk.masks;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Mask;

/**
 * Uses a hash grid to determine collision, faster than
 * using hundreds of Entities for tiled levels, etc.
 */
class Grid extends Hitbox
{
	/**
	 * If x/y positions should be used instead of columns/rows.
	 */
	public var usePositions:Bool;


	/**
	 * Constructor.
	 * @param	width			Width of the grid, in pixels.
	 * @param	height			Height of the grid, in pixels.
	 * @param	tileWidth		Width of a grid tile, in pixels.
	 * @param	tileHeight		Height of a grid tile, in pixels.
	 * @param	x				X offset of the grid.
	 * @param	y				Y offset of the grid.
	 */
	public function new(width:Int, height:Int, tileWidth:Int, tileHeight:Int, x:Int = 0, y:Int = 0)
	{
		super();

		// check for illegal grid size
		if (width == 0 || height == 0 || tileWidth == 0 || tileHeight == 0)
		{
			throw "Illegal Grid, sizes cannot be 0.";
		}

		_rect = HXP.rect;
		_point = HXP.point;
		_point2 = HXP.point2;

		// set grid properties
		columns = Std.int(width / tileWidth);
		rows = Std.int(height / tileHeight);

		_tile = new Rectangle(0, 0, tileWidth, tileHeight);
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		usePositions = false;

		// set callback functions
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Pixelmask), collidePixelmask);

		data = new Array<Array<Bool>>();
		for (x in 0...rows)
		{
			data.push(new Array<Bool>());
#if neko // initialize to false instead of null
			for (y in 0...columns)
			{
				data[x][y] = false;
			}
#end
		}
	}

	/**
	 * Sets the value of the tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	solid		If the tile should be solid.
	 */
	public function setTile(column:Int = 0, row:Int = 0, solid:Bool = true)
	{
		if ( ! checkTile(column, row) ) return;

		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		data[row][column] = solid;
	}

	/**
	 * Makes the tile non-solid.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public inline function clearTile(column:Int = 0, row:Int = 0)
	{
		setTile(column, row, false);
	}

	private inline function checkTile(column:Int, row:Int):Bool
	{
		// check that tile is valid
		if (column < 0 || column > columns - 1 || row < 0 || row > rows - 1)
		{
			//trace('Tile out of bounds: ' + column + ', ' + row);
			return false;
		}
		else
		{
			return true;
		}
	}

	/**
	 * Gets the value of a tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	 */
	public function getTile(column:Int = 0, row:Int = 0):Bool
	{
		if ( ! checkTile(column, row) ) return false;

		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		return data[row][column];
	}

	/**
	 * Sets the value of a rectangle region of tiles.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 * @param	fill		Value to fill.
	 */
	public function setRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1, solid:Bool = true)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row    = Std.int(row / _tile.height);
			width  = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}

		for (yy in row...(row + height))
		{
			for (xx in column...(column + width))
			{
				setTile(xx, yy, solid);
			}
		}
	}

	/**
	 * Makes the rectangular region of tiles non-solid.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 */
	public inline function clearRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1)
	{
		setRect(column, row, width, height, false);
	}

	/**
	* Loads the grid data from a string.
	* @param str			The string data, which is a set of tile values (0 or 1) separated by the columnSep and rowSep strings.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*/
	public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n")
	{
		var row:Array<String> = str.split(rowSep),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
		for (y in 0...rows)
		{
			if (row[y] == '') continue;
			col = row[y].split(columnSep);
			cols = col.length;
			for (x in 0...cols)
			{
				if (col[x] == '') continue;
				setTile(x, y, Std.parseInt(col[x]) > 0);
			}
		}
	}

	/**
	* Saves the grid data to a string.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*/
	public function saveToString(columnSep:String = ",", rowSep:String = "\n"): String
	{
		var s:String = '',
			x:Int, y:Int;
		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				s += Std.string(getTile(x, y));
				if (x != columns - 1) s += columnSep;
			}
			if (y != rows - 1) s += rowSep;
		}
		return s;
	}

	/**
	 * The tile width.
	 */
	public var tileWidth(get_tileWidth, never):Int;
	private inline function get_tileWidth():Int { return Std.int(_tile.width); }

	/**
	 * The tile height.
	 */
	public var tileHeight(get_tileHeight, never):Int;
	private inline function get_tileHeight():Int { return Std.int(_tile.height); }

	/**
	 * How many columns the grid has
	 */
	public var columns(default, null):Int;

	/**
	 * How many rows the grid has.
	 */
	public var rows(default, null):Int;

	/**
	 * The grid data.
	 */
	public var data(default, null):Array<Array<Bool>>;

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		var rectX:Int, rectY:Int, pointX:Int, pointY:Int;
		_rect.x = other.parent.x - other.parent.originX - parent.x + parent.originX;
		_rect.y = other.parent.y - other.parent.originY - parent.y + parent.originY;
		pointX  = Std.int((_rect.x + other.parent.width - 1) / _tile.width) + 1;
		pointY  = Std.int((_rect.y + other.parent.height -1) / _tile.height) + 1;
		rectX   = Std.int(_rect.x / _tile.width);
		rectY   = Std.int(_rect.y / _tile.height);

		for (dy in rectY...pointY)
		{
			for (dx in rectX...pointX)
			{
				if (getTile(dx, dy))
				{
					return true;
				}
			}
		}
		return false;
	}

	/** @private Collides against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		var rectX:Int, rectY:Int, pointX:Int, pointY:Int;
		_rect.x = other.parent.x - other._x - parent.x + _x;
		_rect.y = other.parent.y - other._y - parent.y + _y;
		pointX = Std.int((_rect.x + other._width  - 1) / _tile.width) + 1;
		pointY = Std.int((_rect.y + other._height - 1) / _tile.height) + 1;
		rectX  = Std.int(_rect.x / _tile.width);
		rectY  = Std.int(_rect.y / _tile.height);

		for (dy in rectY...pointY)
		{
			for (dx in rectX...pointX)
			{
				if (getTile(dx, dy))
				{
					return true;
				}
			}
		}
		return false;
	}

	/** @private Collides against a Pixelmask. */
	private function collidePixelmask(other:Pixelmask):Bool
	{
#if flash
		var x1:Int = Std.int(other.parent.x + other.x - parent.x - _x),
			y1:Int = Std.int(other.parent.y + other.y - parent.y - _y),
			x2:Int = Std.int((x1 + other.width - 1) / _tile.width),
			y2:Int = Std.int((y1 + other.height - 1) / _tile.height);
		_point.x = x1;
		_point.y = y1;
		x1 = Std.int(x1 / _tile.width);
		y1 = Std.int(y1 / _tile.height);
		_tile.x = x1 * _tile.width;
		_tile.y = y1 * _tile.height;
		var xx:Int = x1;
		while (y1 <= y2)
		{
			if (y1 < 0 || y1 >= data.length)
			{
				y1 ++;
				continue;
			}

			while (x1 <= x2)
			{
				if (x1 < 0 || x1 >= data[0].length)
				{
					x1 ++;
					continue;
				}

				if (data[y1][x1])
				{
					if (other.data.hitTest(_point, 1, _tile)) return true;
				}
				x1 ++;
				_tile.x += _tile.width;
			}
			x1 = xx;
			y1 ++;
			_tile.x = x1 * _tile.width;
			_tile.y += _tile.height;
		}
#else
		trace('Pixelmasks will not work in targets other than flash due to hittest not being implemented in OpenFL.');
#end
		return false;
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		HXP.point.x = (_x + parent.x - HXP.camera.x) * HXP.screen.fullScaleX;
		HXP.point.y = (_y + parent.y - HXP.camera.y) * HXP.screen.fullScaleY;

		graphics.beginFill(0x0000FF, 0.3);
		var pos = HXP.point.x,
			stepX = tileWidth * HXP.screen.fullScaleX,
			stepY = tileHeight * HXP.screen.fullScaleY;
		for (i in 1...columns)
		{
			graphics.drawRect(pos, HXP.point.y, 1, _height * HXP.screen.fullScaleX);
			pos += stepX;
		}

		pos = HXP.point.y;
		for (i in 1...rows)
		{
			graphics.drawRect(HXP.point.x, pos, _width * HXP.screen.fullScaleY, 1);
			pos += stepY;
		}

		HXP.rect.y = HXP.point.y;
		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				if (data[y][x])
				{
					graphics.drawRect(HXP.rect.x, HXP.rect.y, stepX, stepY);
				}
				HXP.rect.x += stepX;
			}
			HXP.rect.x = HXP.point.x;
			HXP.rect.y += stepY;
		}
		graphics.endFill();
	}

	public function squareProjection(axis:Point, point:Point):Void
	{
		if (axis.x < axis.y)
		{
			point.x = axis.x;
			point.y = axis.y;
		}
		else
		{
			point.y = axis.x;
			point.x = axis.y;
		}
	}

	// Grid information.
	private var _tile:Rectangle;
	private var _rect:Rectangle;
	private var _point:Point;
	private var _point2:Point;
}
