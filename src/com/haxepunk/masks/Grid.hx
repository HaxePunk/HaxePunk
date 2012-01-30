package com.haxepunk.masks;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Mask;


#if !flash
typedef Array2D = Array<Array<Int>>;
#end
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
		if (width == 0 ||
			height == 0 ||
			tileWidth == 0 ||
			tileHeight == 0)
			throw "Illegal Grid, sizes cannot be 0.";
		
		_rect = HXP.rect;
		_point = HXP.point;
		_point2 = HXP.point2;
		
		// set grid properties
		_columns = Std.int(width / tileWidth);
		_rows = Std.int(height / tileHeight);
		
		_tile = new Rectangle(0, 0, tileWidth, tileHeight);
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		
		// set callback functions
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Pixelmask), collidePixelmask);
		
		#if flash
		_data = new BitmapData(_columns, _rows, true, 0);
		#else
		_grid = new Array2D();
		for (x in 0..._columns)
		{
			_grid[x] = new Array();
		}
		#end
	}
	
	/**
	 * Sets the value of the tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	solid		If the tile should be solid.
	 */
	public function setTile(column:Int = 0, row:Int = 0, solid:Bool = true)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		#if flash
		_data.setPixel32(column, row, solid ? 0xFFFFFFFF : 0);
		#else
		_grid[column][row] = (solid ? 1:0);
		#end
	}
	
	/**
	 * Makes the tile non-solid.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public function clearTile(column:Int = 0, row:Int = 0)
	{
		setTile(column, row, false);
	}
	
	/**
	 * Gets the value of a tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	 */
	public function getTile(column:Int = 0, row:Int = 0):Bool
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		return 
		#if flash
		_data.getPixel32(column, row) > 0;
		#else
		_grid[column][row] == 1;
		#end
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
			row = Std.int(row / _tile.height);
			width = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}
		#if flash
		_rect.x = column;
		_rect.y = row;
		_rect.width = width;
		_rect.height = height;
		_data.fillRect(_rect, solid ? 0xFFFFFFFF : 0);
		#else
		var setTo = solid ? 1:0;
		for (xx in column...column + width) 
		{
			for (yy in row...row + height) 
			{
				_grid[xx][yy] = setTo;
			}
		}
		#end
	}
	
	/**
	 * Makes the rectangular region of tiles non-solid.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 */
	public function clearRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1)
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
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				s += Std.string(getTile(x, y));
				if (x != _columns - 1) s += columnSep;
			}
			if (y != _rows - 1) s += rowSep;
		}
		return s;
	}
	
	/**
	 * The tile width.
	 */
	public var tileWidth(getTileWidth, null):Int;
	private function getTileWidth():Int { return Std.int(_tile.width); }
	
	/**
	 * The tile height.
	 */
	public var tileHeight(getTileHeight, null):Int;
	private function getTileHeight():Int { return Std.int(_tile.height); }
	
	/**
	 * How many columns the grid has
	 */
	public var columns(getColumns, null):Int;
	private function getColumns():Int { return _columns; }
	
	/**
	 * How many rows the grid has.
	 */
	public var rows(getRows, null):Int;
	private function getRows():Int { return _rows; }
	
	/**
	 * The grid data.
	 */
	#if flash
	public var data(getData, null):BitmapData;
	private inline function getData():BitmapData { return _data; }
	#else
	public var data(getData, null):Array2D;
	private inline function getData():Array2D { return _grid; }
	#end
	
	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		#if flash
		_rect.x = other.parent.x - other.parent.originX - parent.x + parent.originX;
		_rect.y = other.parent.y - other.parent.originY - parent.y + parent.originY;
		_point.x = Std.int((_rect.x + other.parent.width - 1) / _tile.width) + 1;
		_point.y = Std.int((_rect.y + other.parent.height -1) / _tile.height) + 1;
		_rect.x = Std.int(_rect.x / _tile.width);
		_rect.y = Std.int(_rect.y / _tile.height);
		_rect.width = _point.x - _rect.x;
		_rect.height = _point.y - _rect.y;
		return _data.hitTest(HXP.zero, 1, _rect);
		
		
		#else
		var rectX = Std.int(other.parent.x - other.parent.originX - parent.x + parent.originX);
		var rectY = Std.int(other.parent.y - other.parent.originY - parent.y + parent.originY);
		var pX:Int = Std.int((rectX + other.parent.width - 1) / _tile.width) + 1;
		var pY:Int = Std.int((rectY + other.parent.height -1) / _tile.height) + 1;
		rectX = Std.int(rectX / _tile.width);
		rectY = Std.int(rectY / _tile.height);
		var rectWidth:Int = pX - rectX;
		var rectHeight:Int = pY - rectY;

		for (dx in 0...rectWidth) 
		{
			for (dy in 0...rectHeight) 
			{
				if (_grid[rectX + dx][rectY + dy] == 1) return true;
			}
		}
		return false;
		#end
	}
	
	/** @private Collides against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		_rect.x = other.parent.x + other._x - parent.x - _x;
		_rect.y = other.parent.y + other._y - parent.y - _y;
		_point.x = Std.int((_rect.x + other._width - 1) / _tile.width) + 1;
		_point.y = Std.int((_rect.y + other._height -1) / _tile.height) + 1;
		_rect.x = Std.int(_rect.x / _tile.width);
		_rect.y = Std.int(_rect.y / _tile.height);
		_rect.width = _point.x - _rect.x;
		_rect.height = _point.y - _rect.y;
		#if flash
		return _data.hitTest(HXP.zero, 1, _rect);
		#else
		var xx = Std.int(_rect.x);
		var yy = Std.int(_rect.y);
		var ww = Std.int(_rect.y +_rect.height);
		var hh = Std.int(_rect.x +_rect.width);
		if (_grid[xx][yy] == 1) 
		{
			return true;
		}
		if (_grid[xx][yy + hh] == 1) 
		{
			return true;
		}
		if (_grid[xx + ww][yy] == 1) 
		{
			return true;
		}
		if (_grid[xx + ww][yy + hh] == 1) 
		{
			return true;
		}
		return false;
		#end
	}
	
	/** @private Collides against a Pixelmask. */
	private function collidePixelmask(other:Pixelmask):Bool
	{
		#if !flash
		trace('Pixelmasks will not work in targets other than flash due to hittest not being implemented in NME.');
		return true;
		#else
		
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
			while (x1 <= x2)
			{
				if (_data.getPixel32(x1, y1) != 0)
				{
					#if flash
					if (other.data.hitTest(_point, 1, _tile)) return true;
					#end
				}
				x1 ++;
				_tile.x += _tile.width;
			}
			x1 = xx;
			y1 ++;
			_tile.x = x1 * _tile.width;
			_tile.y += _tile.height;
		}
		return false;
		#end
	}
	
	override public function debugDraw(graphics:Graphics):Void //Not 100% tested
	{
		#if flash
		HXP.matrix.b = HXP.matrix.c = 0;
		HXP.matrix.a = tileWidth;//Scale X
		HXP.matrix.d = tileHeight;//Scale Y
		HXP.matrix.tx = -_x * HXP.matrix.a;//Translation X
		HXP.matrix.ty = -_y * HXP.matrix.d;//Translation Y
		//if (angle != 0) HXP.matrix.rotate(angle * HXP.RAD); //Rotation
		HXP.matrix.tx += _x + parent.x - HXP.camera.x;
		HXP.matrix.ty += _y + parent.y - HXP.camera.y;
		HXP.buffer.draw(_data, HXP.matrix);
		#end
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
	
	private var _columns:Int;
	private var _rows:Int;
	private var _tile:Rectangle;
	private var _rect:Rectangle;
	private var _point:Point;
	private var _point2:Point;
	
	#if flash
	private var _data:BitmapData;
	#else
	private var _grid:Array2D;
	#end
}