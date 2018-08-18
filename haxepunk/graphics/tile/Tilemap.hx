package haxepunk.graphics.tile;

import haxepunk.math.Rectangle;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.masks.Grid;
import haxepunk.math.Vector2;

/**
 * A rendered grid of tiles.
 */
class Tilemap extends Graphic
{
	/**
	 * If x/y positions should be used instead of columns/rows.
	 */
	public var usePositions:Bool;

	/**
	 * Rotation of the tilemap, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the tilemap, effects both x and y scale.
	 */
	public var scale:Float = 1;

	/**
	 * X scale of the tilemap.
	 */
	public var scaleX:Float = 1;

	/**
	 * Y scale of the tilemap.
	 */
	public var scaleY:Float = 1;

	/**
	 * Width of the tilemap.
	 */
	public var width(default, null):Int;

	/**
	 * Height of the tilemap.
	 */
	public var height(default, null):Int;

	/**
	 * Constructor.
	 * @param	tileset				The source tileset image.
	 * @param	width				Width of the tilemap, in pixels.
	 * @param	height				Height of the tilemap, in pixels.
	 * @param	tileWidth			Tile width.
	 * @param	tileHeight			Tile height.
	 * @param	tileMarginWidth		Tile horizontal spacing.
	 * @param	tileMarginHeight	Tile vertical spacing.
	 */
	public function new(tileset:TileType, width:Int, height:Int, ?tileWidth:Int, ?tileHeight:Int, tileMarginWidth:Int=0, tileMarginHeight:Int=0, tileOffsetX:Int=0, tileOffsetY:Int=0)
	{
		// set some tilemap information
		super();

		// load the tileset graphic
		_atlas = tileset;

		if (_atlas == null)
			throw "Invalid tileset graphic provided.";

		// prepare the tileset if needed
		if (_atlas.tileWidth == 0 || _atlas.tileHeight == 0)
		{
			if (tileWidth == null || tileHeight == null)
			{
				throw "Invalid tileset graphic provided.\nThe tileset must be prepared or valid tile dimensions must be passed to the Tilemap constructor.";
			}
			else
			{
				_atlas.prepare(tileWidth, tileHeight, tileMarginWidth, tileMarginHeight, tileOffsetX, tileOffsetY);
			}
		}
		else
		{
			tileWidth = _atlas.tileWidth;
			tileHeight = _atlas.tileHeight;
		}

		this.width = width - (width % tileWidth);
		this.height = height - (height % tileHeight);
		_columns = Std.int(this.width / tileWidth);
		_rows = Std.int(this.height / tileHeight);

		if (_columns == 0 || _rows == 0)
			throw "Cannot create a texture of width/height = 0";

		_maxWidth -= _maxWidth % tileWidth;
		_maxHeight -= _maxHeight % tileHeight;

		// initialize map
		_map = new Array<Array<Int>>();
		for (y in 0..._rows)
		{
			_map[y] = new Array<Int>();
			for (x in 0..._columns)
			{
				_map[y][x] = -1;
			}
		}

		pixelSnapping = true;
	}

	/**
	 * Sets the index of the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	index		Tile index from the tileset to show. (Or -1 to show the tile as blank.)
	 */
	public function setTile(column:Int, row:Int, index:Int = 0)
	{
		if (usePositions)
		{
			column = Std.int(column / tileWidth);
			row = Std.int(row / tileHeight);
		}
		if (index > -1) index %= tileCount;
		column %= _columns;
		row %= _rows;
		_map[row][column] = index;

	}

	/**
	 * Clears the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public function clearTile(column:Int, row:Int)
	{
		setTile(column, row, -1);
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
			column = Std.int(column / tileWidth);
			row = Std.int(row / tileHeight);
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
			column = Std.int(column / tileWidth);
			row = Std.int(row / tileHeight);
			width = Std.int(width / tileWidth);
			height = Std.int(height / tileHeight);
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
				column++;
			}
			column = c;
			row++;
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
			column = Std.int(column / tileWidth);
			row = Std.int(row / tileHeight);
			width = Std.int(width / tileWidth);
			height = Std.int(height / tileHeight);
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
				column++;
			}
			column = c;
			row++;
		}
		usePositions = u;
	}

	/**
	 * Set the tiles from an array.
	 * The array must be of the same size as the Tilemap.
	 *
	 * @param	array	The array to load from.
	 */
	public function loadFrom2DArray(array:Array<Array<Int>>):Void
	{
		for (y in 0...array.length)
		{
			for (x in 0...array[y].length)
			{
				setTile(x, y, array[y][x]);
			}
		}
	}

	/**
	* Loads the Tilemap tile index data from a string.
	* The implicit array should not be bigger than the Tilemap.
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
				if (col[x] != '')
				{
					setTile(x, y, Std.parseInt(col[x]));
				}
			}
		}
	}

	/**
	* Saves the Tilemap tile index data to a string.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*
	* @return	The string version of the array.
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
	 * Shifts all the tiles in the tilemap.
	 * @param	columns		Horizontal shift.
	 * @param	rows		Vertical shift.
	 * @param	wrap		If tiles shifted off the canvas should wrap around to the other side.
	 */
	public function shiftTiles(columns:Int, rows:Int, wrap:Bool = false)
	{
		if (usePositions)
		{
			columns = Std.int(columns / tileWidth);
			rows = Std.int(rows / tileHeight);
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
		}
	}

	/**
	 *  Centers the origin of the tilemap based on it's full width/height.
	 */
	override public function centerOrigin():Void
	{
		originX = width * 0.5;
		originY = height * 0.5;
	}
	
	@:dox(hide)
	override public function render(point:Vector2, camera:Camera)
	{
		var fullScaleX:Float = camera.screenScaleX,
			fullScaleY:Float = camera.screenScaleY;

		// determine drawing location
		_point.x = (point.x + x - originX - camera.x * scrollX - HXP.halfWidth) * fullScaleX + HXP.halfWidth;
		_point.y = (point.y + y - originY - camera.y * scrollY - HXP.halfHeight) * fullScaleX + HXP.halfHeight;

		var scx = scale * scaleX,
			scy = scale * scaleY,
			tw = tileWidth * scx * fullScaleX,
			th = tileHeight * scy * fullScaleY;

		// determine start and end tiles to draw (optimization)
		var startx = Math.floor(-_point.x / tw),
			starty = Math.floor(-_point.y / th),
			destx = startx + 1 + Math.ceil(HXP.width / tw),
			desty = starty + 1 + Math.ceil(HXP.height / th);

		// nothing will render if we're completely off screen
		if (startx > _columns || starty > _rows || destx < 0 || desty < 0)
			return;

		// clamp values to boundaries
		if (startx < 0) startx = 0;
		if (destx > _columns) destx = _columns;
		if (starty < 0) starty = 0;
		if (desty > _rows) desty = _rows;

		var tile:Int = 0;
		
		for (y in starty...desty)
		{
			for (x in startx...destx)
			{
				tile = _map[y % _rows][x % _columns];
				if (tile >= 0)
				{
					drawTile(
						tile, x, y,
						_point.x + x * tw,
						_point.y + y * th,
						scx * fullScaleX, scy * fullScaleY
					);
				}
			}
		}
	}

	@:dox(hide)
	override public function pixelPerfectRender(point:Vector2, camera:Camera)
	{
		var fullScaleX:Float = camera.screenScaleX,
			fullScaleY:Float = camera.screenScaleY;

		var scx = scale * scaleX,
			scy = scale * scaleY,
			tw = tileWidth * scx,
			th = tileHeight * scy;

		// determine drawing location
		_point.x = point.x + floorX(camera, x) - floorX(camera, originX * scx) - floorX(camera, camera.x * scrollX);
		_point.x = (_point.x - HXP.halfWidth) * fullScaleX + HXP.halfWidth;
		_point.y = point.y + floorY(camera, y) - floorY(camera, originY * scy) - floorY(camera, camera.y * scrollY);
		_point.y = (_point.y - HXP.halfHeight) * fullScaleY + HXP.halfHeight;

		// determine start and end tiles to draw (optimization)
		var startx = Math.floor(-_point.x / tw / fullScaleX),
			starty = Math.floor(-_point.y / th / fullScaleY),
			destx = startx + 1 + Math.ceil(HXP.width / tw / fullScaleX),
			desty = starty + 1 + Math.ceil(HXP.height / th / fullScaleY);

		// nothing will render if we're completely off screen
		if (startx > _columns || starty > _rows || destx < 0 || desty < 0)
			return;

		// clamp values to boundaries
		if (startx < 0) startx = 0;
		if (destx > _columns) destx = _columns;
		if (starty < 0) starty = 0;
		if (desty > _rows) desty = _rows;

		var wx:Float, wy:Float, nx:Float, ny:Float,
			tile:Int = 0;

		wy = floorY(camera, starty * th) * fullScaleY;
		for (y in starty...desty)
		{
			ny = floorY(camera, (y + 1) * th) * fullScaleY;
			// ensure no vertical overlap between this and next tile
			scy = (ny - wy) / tileHeight;
			wx = floorX(camera, startx * tw) * fullScaleX;

			for (x in startx...destx)
			{
				nx = floorX(camera, (x + 1) * tw) * fullScaleX;
				tile = _map[y % _rows][x % _columns];
				if (tile >= 0)
				{
					// ensure no horizontal overlap between this and next tile
					scx = (nx - wx) / tileWidth;
					drawTile(tile, x, y, _point.x + wx, _point.y + wy, scx, scy);
				}
				wx = nx;
			}

			wy = ny;
		}
	}

	function drawTile(tile:Int, tx:Int, ty:Int, x:Float, y:Float, scx:Float, scy:Float)
	{
		var region = _atlas.getRegion(tile);
		region.draw(
			x, y,
			scx, scy, 0,
			color, alpha,
			shader, smooth, blend
		);
	}

	/**
	 * Create a Grid object from this tilemap.
	 * @param solidTiles	Array of tile indexes that should be solid.
	 * @param grid			A grid to use instead of creating a new one, the function won't check if the grid is of correct dimension.
	 * @return The grid with a tile solid if the tile index is in [solidTiles].
	*/
	public function createGrid(solidTiles:Array<Int>, ?grid:Grid)
	{
		if (grid == null)
		{
			grid = new Grid(width, height, Std.int(tileWidth), Std.int(tileHeight));
		}

		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				if (solidTiles.indexOf(getTile(x, y)) != -1)
				{
					grid.setTile(x, y, true);
				}
			}
		}

		return grid;
	}

	/** @private Used by shiftTiles to update a tile from the tilemap. */
	function updateTile(column:Int, row:Int)
	{
		setTile(column, row, _map[row % _rows][column % _columns]);
	}

	/**
	 * The tile width.
	 */
	public var tileWidth(get, never):Int;
	inline function get_tileWidth():Int return _atlas.tileWidth;

	/**
	 * The tile height.
	 */
	public var tileHeight(get, never):Int;
	inline function get_tileHeight():Int return _atlas.tileHeight;

	/**
	 * The tile horizontal margin of tile.
	 */
	public var tileMarginWidth(get, never):Int;
	inline function get_tileMarginWidth():Int return _atlas.tileMarginWidth;

	/**
	 * The tile vertical margin of tile.
	 */
	public var tileMarginHeight(default, null):Int;
	inline function get_tileMarginHeight():Int return _atlas.tileMarginHeight;

	/**
	 * How many tiles the tilemap has.
	 */
	public var tileCount(get, never):Int;
	inline function get_tileCount():Int return _atlas.tileCount;

	/**
	 * How many columns the tilemap has.
	 */
	public var columns(get, null):Int;
	inline function get_columns():Int return _columns;

	/**
	 * How many rows the tilemap has.
	 */
	public var rows(get, null):Int;
	inline function get_rows():Int return _rows;

	// Tilemap information.
	var _map:Array<Array<Int>>;
	var _columns:Int;
	var _rows:Int;

	var _maxWidth:Int = 4000;
	var _maxHeight:Int = 4000;

	// Tileset information.
	var _atlas:TileAtlas;
}
