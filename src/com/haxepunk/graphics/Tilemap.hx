package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.atlas.TileAtlas;
import com.haxepunk.masks.Grid;


typedef Array2D = Array<Array<Int>>
/**
 * A canvas to which Tiles can be drawn for fast multiple tile rendering.
 */
class Tilemap extends Canvas
{
	/**
	 * If x/y positions should be used instead of columns/rows.
	 */
	public var usePositions:Bool;

	/**
	 * Constructor.
	 * @param	tileset			The source tileset image.
	 * @param	width			Width of the tilemap, in pixels.
	 * @param	height			Height of the tilemap, in pixels.
	 * @param	tileWidth		Tile width.
	 * @param	tileHeight		Tile height.
	 */
	public function new(tileset:Dynamic, width:Int, height:Int, tileWidth:Int, tileHeight:Int)
	{
		_rect = HXP.rect;

		// set some tilemap information
		_width = width - (width % tileWidth);
		_height = height - (height % tileHeight);
		_columns = Std.int(_width / tileWidth);
		_rows = Std.int(_height / tileHeight);
		if (_columns == 0 || _rows == 0) throw "Cannot create a bitmapdata of width/height = 0";

		// create the canvas
#if neko
		_maxWidth = 4000 - 4000 % tileWidth;
		_maxHeight = 4000 - 4000 % tileHeight;
#else
		_maxWidth -= _maxWidth % tileWidth;
		_maxHeight -= _maxHeight % tileHeight;
#end

		super(_width, _height);

		// initialize map
		_tile = new Rectangle(0, 0, tileWidth, tileHeight);
		_map = new Array2D();
		for (y in 0..._rows)
		{
			_map[y] = new Array<Int>();
			for (x in 0..._columns)
			{
				_map[y][x] = -1;
			}
		}

		// load the tileset graphic
		if (Std.is(tileset, TileAtlas))
		{
			_blit = false;
			_atlas = cast(tileset, TileAtlas);
		}
#if flash
		if (Std.is(tileset, BitmapData))
		{
			_blit = true;
			_set = tileset;
		}
		else
		{
			_blit = true;
			_set = HXP.getBitmap(tileset);
		}
#else // force hardware acceleration
		else
		{
			_blit = false;
			_atlas = new TileAtlas(tileset, tileWidth, tileHeight);
		}
#end

		if (_set == null && _atlas == null) throw "Invalid tileset graphic provided.";

		if (_blit)
		{
			_setColumns = Std.int(_set.width / tileWidth);
			_setRows = Std.int(_set.height / tileHeight);
		}
		else
		{
			_setColumns = Std.int(_atlas.width / tileWidth);
			_setRows = Std.int(_atlas.height / tileHeight);
		}
		_setCount = _setColumns * _setRows;
	}

	/**
	 * Sets the index of the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	index		Tile index.
	 */
	public function setTile(column:Int, row:Int, index:Int = 0)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		index %= _setCount;
		column %= _columns;
		row %= _rows;
		_tile.x = (index % _setColumns) * _tile.width;
		_tile.y = Std.int(index / _setColumns) * _tile.height;
		_map[row][column] = index;
		if (_blit) draw(Std.int(column * _tile.width), Std.int(row * _tile.height), _set, _tile);
	}

	/**
	 * Clears the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public function clearTile(column:Int, row:Int)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		column %= _columns;
		row %= _rows;
		_tile.x = column * _tile.width;
		_tile.y = row * _tile.height;
		if (_blit) fill(_tile, 0, 0);
	}

	/**
	 * Gets the tile index at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	The tile index.
	 */
	public function getTile(column:Int, row:Int):Int
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		return _map[row % _rows][column % _columns];
	}

	/**
	 * Sets a rectangular region of tiles to the index.
	 * @param	column		First tile column.
	 * @param	row			First tile row.
	 * @param	width		Width in tiles.
	 * @param	height		Height in tiles.
	 * @param	index		Tile index.
	 */
	public function setRect(column:Int, row:Int, width:Int = 1, height:Int = 1, index:Int = 0)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
			width = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}
		column %= _columns;
		row %= _rows;
		var c:Int = column,
			r:Int = column + width,
			b:Int = row + height,
			u:Bool = usePositions;
		usePositions = false;
		while (row < b)
		{
			while (column < r)
			{
				setTile(column, row, index);
				column ++;
			}
			column = c;
			row ++;
		}
		usePositions = u;
	}

	/**
	 * Clears the rectangular region of tiles.
	 * @param	column		First tile column.
	 * @param	row			First tile row.
	 * @param	width		Width in tiles.
	 * @param	height		Height in tiles.
	 */
	public function clearRect(column:Int, row:Int, width:Int = 1, height:Int = 1)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
			width = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}
		column %= _columns;
		row %= _rows;
		var c:Int = column,
			r:Int = column + width,
			b:Int = row + height,
			u:Bool = usePositions;
		usePositions = false;
		while (row < b)
		{
			while (column < r)
			{
				clearTile(column, row);
				column ++;
			}
			column = c;
			row ++;
		}
		usePositions = u;
	}

	public function loadFrom2DArray(array:Array2D):Void
	{
		// for (x in 0...array.length)
		// {
		// 	for (y in 0...array[0].length)
		// 	{
		// 		setTile(x, y, array[x][y]);
		// 	}
		// }
		_map = array;
	}

	/**
	* Loads the Tilemap tile index data from a string.
	* @param str			The string data, which is a set of tile values separated by the columnSep and rowSep strings.
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
				setTile(x, y, Std.parseInt(col[x]));
			}
		}
	}

	/**
	* Saves the Tilemap tile index data to a string.
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
	 * Gets the index of a tile, based on its column and row in the tileset.
	 * @param	tilesColumn		Tileset column.
	 * @param	tilesRow		Tileset row.
	 * @return	Index of the tile.
	 */
	public inline function getIndex(tilesColumn:Int, tilesRow:Int):Int
	{
		return (tilesRow % _setRows) * _setColumns + (tilesColumn % _setColumns);
	}

	/**
	 * Shifts all the tiles in the tilemap.
	 * @param	columns		Horizontal shift.
	 * @param	rows		Vertical shift.
	 * @param	wrap		If tiles shifted off the canvas should wrap around to the other side.
	 */
	public function shiftTiles(columns:Int, rows:Int, wrap:Bool = false)
	{
		if (usePositions)
		{
			columns = Std.int(columns / _tile.width);
			rows = Std.int(rows / _tile.height);
		}

		if (columns != 0)
		{
			for (y in 0..._rows)
			{
				var row = _map[y];
				if (columns > 0)
				{
					for (x in 0...columns)
					{
						var tile:Int = row.pop();
						if (wrap) row.unshift(tile);
					}
				}
				else
				{
					for (x in 0...Std.int(Math.abs(columns)))
					{
						var tile:Int = row.shift();
						if (wrap) row.push(tile);
					}
				}
			}
			_columns = _map[Std.int(y)].length;

#if flash
			shift(Std.int(columns * _tile.width), 0);
			_rect.x = columns > 0 ? 0 : _columns + columns;
			_rect.y = 0;
			_rect.width = Math.abs(columns);
			_rect.height = _rows;
			updateRect(_rect, !wrap);
#end
		}

		if (rows != 0)
		{
			if (rows > 0)
			{
				for (y in 0...rows)
				{
					var row:Array<Int> = _map.pop();
					if (wrap) _map.unshift(row);
				}
			}
			else
			{
				for (y in 0...Std.int(Math.abs(rows)))
				{
					var row:Array<Int> = _map.shift();
					if (wrap) _map.push(row);
				}
			}
			_rows = _map.length;

#if flash
			shift(0, Std.int(rows * _tile.height));
			_rect.x = 0;
			_rect.y = rows > 0 ? 0 : _rows + rows;
			_rect.width = _columns;
			_rect.height = Math.abs(rows);
			updateRect(_rect, !wrap);
#end
		}
	}

	/** @private Used by shiftTiles to update a rectangle of tiles from the tilemap. */
	private function updateRect(rect:Rectangle, clear:Bool)
	{
		var x:Int = Std.int(rect.x),
			y:Int = Std.int(rect.y),
			w:Int = Std.int(x + rect.width),
			h:Int = Std.int(y + rect.height),
			u:Bool = usePositions;
		usePositions = false;
		if (clear)
		{
			while (y < h)
			{
				while (x < w) clearTile(x ++, y);
				x = Std.int(rect.x);
				y ++;
			}
		}
		else
		{
			while (y < h)
			{
				while (x < w) updateTile(x ++, y);
				x = Std.int(rect.x);
				y ++;
			}
		}
		usePositions = u;
	}

	public override function render(target:BitmapData, point:Point, camera:Point, layer:Int=HXP.BASELAYER)
	{
		if (_blit)
		{
			super.render(target, point, camera, layer);
		}
		else
		{
			var wx:Float = 0, wy:Float = point.y - camera.y, tile:Int = 0,
			tw:Int = tileWidth, th:Int = tileHeight; // call properties once

			// determine start and end tiles to draw (optimization)
			var dx = camera.x - point.x,
				dy = camera.y - point.y,
				sx = Math.floor(dx / tileWidth),
				sy = Math.floor(dy / tileHeight),
				ex = Math.ceil((dx + HXP.width) / tileWidth),
				ey = Math.ceil((dy + HXP.height) / tileHeight);

			if (sx < 0) sx = 0;
			if (ex > _columns) ex = _columns;
			if (sy < 0) sy = 0;
			if (ey > _rows) ey = _rows;

			for (y in sy...ey)
			{
				wx = point.x - camera.x;
				for (x in sx...ex)
				{
					tile = getTile(x, y);
					if (tile >= 0)
					{
						_atlas.prepareTile(tile, wx, wy, layer,
							HXP.screen.fullScaleX, HXP.screen.fullScaleY, 0,
							HXP.getRed(color)/255, HXP.getGreen(color)/255, HXP.getBlue(color)/255, alpha);
					}

					wx += tileWidth;
				}
				wy += tileHeight;
			}
		}
	}

	/** @private Used by shiftTiles to update a tile from the tilemap. */
	private function updateTile(column:Int, row:Int)
	{
		setTile(column, row, _map[row % _rows][column % _columns]);
	}

	/**
	 * The tile width.
	 */
	public var tileWidth(getTileWidth, never):Int;
	private function getTileWidth():Int { return Std.int(_tile.width); }

	/**
	 * The tile height.
	 */
	public var tileHeight(getTileHeight, never):Int;
	private function getTileHeight():Int { return Std.int(_tile.height); }

	/**
	 * How many columns the tilemap has.
	 */
	public var columns(getColumns, null):Int;
	private function getColumns():Int { return _columns; }

	/**
	 * How many rows the tilemap has.
	 */
	public var rows(getRows, null):Int;
	private function getRows():Int { return _rows; }

	// Tilemap information.
	private var _map:Array2D;
	private var _columns:Int;
	private var _rows:Int;

	// Tileset information.
	private var _set:BitmapData;
	private var _atlas:TileAtlas;
	private var _setColumns:Int;
	private var _setRows:Int;
	private var _setCount:Int;
	private var _tile:Rectangle;
}