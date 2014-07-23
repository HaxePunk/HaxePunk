package haxepunk.graphics;

import haxepunk.scene.Camera;
import haxepunk.math.Vector3;

class Tilemap implements Graphic
{

	public function new(material:Material, width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?tileSpacingWidth:Int=0, ?tileSpacingHeight:Int=0)
	{
		_width = width - (width % tileWidth);
		_height = height - (height % tileHeight);
		_columns = Std.int(_width / tileWidth);
		_rows = Std.int(_height / tileHeight);

		_map = new Array<Int>();
		for (i in 0...(_rows * _columns))
		{
			_map[i] = -1;
		}

		var texture = material.firstPass.getTexture(0);
		_setColumns = Std.int(texture.width / tileWidth);
		_setRows = Std.int(texture.height / tileHeight);
		_setCount = _setColumns * _setRows;
	}

	/**
	* Loads the Tilemap tile index data from a string.
	* The implicit array should not be bigger than the Tilemap.
	* @param data             The string data, which is a set of tile values separated by the columnDelimiter and rowDelimiter strings.
	* @param columnDelimiter  The string that separates each tile value on a row, default is ",".
	* @param rowDelimiter     The string that separates each row of tiles, default is "\n".
	*/
	public function fromString(data:String, columnDelimiter:String = ",", rowDelimiter:String = "\n"):Void
	{
		var rows:Array<String> = data.split(rowDelimiter),
			columns:Array<String>;
		for (y in 0...rows.length)
		{
			if (rows[y] == '') continue;
			columns = rows[y].split(columnDelimiter);
			for (x in 0...columns.length)
			{
				if (columns[x] == '') continue;
				setTile(x, y, Std.parseInt(columns[x]));
			}
		}
	}

	/**
	* Saves the Tilemap tile index data to a string.
	* @param columnDelimiter  The string that separates each tile value on a row, default is ",".
	* @param rowDelimiter     The string that separates each row of tiles, default is "\n".
	* @return  The string version of the array.
	*/
	public function toString(columnDelimiter:String = ",", rowDelimiter:String = "\n"):String
	{
		var s:String = '',
			x:Int, y:Int;
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				s += Std.string(getTile(x, y));
				if (x != _columns - 1) s += columnDelimiter;
			}
			if (y != _rows - 1) s += rowDelimiter;
		}
		return s;
	}

	/**
	 * Gets the tile index at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	The tile index.
	 */
	public inline function getTile(column:Int, row:Int):Int
	{
		return _map[(row % _rows) * _columns + (column % _columns)];
	}

	/**
	 * Sets the index of the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	index		Tile index.
	 */
	public inline function setTile(column:Int, row:Int, index:Int = 0)
	{
		_map[(row % _rows) * _columns + (column % _columns)] = index % _setCount;
	}

	/**
	 * Clears the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public inline function clearTile(column:Int, row:Int)
	{
		_map[(row % _rows) * _columns + (column % _columns)] = -1;
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
		for (y in row...(row + height))
		{
			for (x in column...(column + width))
			{
				setTile(x, y, index);
			}
		}
	}

	/**
	 * Clears the rectangular region of tiles.
	 * @param column  First tile column.
	 * @param row     First tile row.
	 * @param width   Width in tiles.
	 * @param height  Height in tiles.
	 */
	public function clearRect(column:Int, row:Int, width:Int = 1, height:Int = 1)
	{
		for (y in row...(row + height))
		{
			for (x in column...(column + width))
			{
				clearTile(x, y);
			}
		}
	}

	/**
	 * Set the tiles from a 2D array.
	 * The array must be of the same size as the Tilemap.
	 *
	 * @param array  The array to load from.
	 */
	public function loadFrom2DArray(array:Array<Array<Int>>):Void
	{
		var data:Array<Int>;
		for (y in 0...array.length)
		{
			data = array[y];
			for (x in 0...data.length)
			{
				setTile(x, y, data[x]);
			}
		}
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

	public function update(elapsed:Float):Void
	{

	}

	public function draw(camera:Camera, offset:Vector3):Void
	{
		var startx = 0, starty = 0, destx = _columns, desty = _rows;
		// for (y in starty...desty)
		// {
		// 	wx = sx;
		// 	// ensure no vertical overlap between this and next tile
		// 	scy = (Math.floor(wy+stepy) - Math.floor(wy)) / tileHeight;

		// 	for (x in startx...destx)
		// 	{
		// 		tile = getTile(x, y);
		// 		if (tile >= 0)
		// 		{
		// 			// ensure no horizontal overlap between this and next tile
		// 			scx = (Math.floor(wx+stepx) - Math.floor(wx)) / tileWidth;

		// 			// HXP.spriteBatch.draw();
		// 		}
		// 		wx += stepx;
		// 	}
		// 	wy += stepy;
		// }
	}

	// Tilemap information.
	private var _map:Array<Int>;
	private var _columns:Int;
	private var _rows:Int;

	private var _width:Int;
	private var _height:Int;

	private var _setColumns:Int;
	private var _setRows:Int;
	private var _setCount:Int;

}
