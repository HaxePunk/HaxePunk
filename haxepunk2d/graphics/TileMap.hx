package haxepunk2d.graphics;

typedef TileMapConfig = {
	> GraphicConfig,
	tileSpacingWidth:Int,
	tileSpacingHeight:Int
};

/**
 * A graphic made of tiles from a tileset.
 * Way faster than creating hundreds of graphics.
 */
class TileMap extends Graphic
{
	/** The tile width. */
	public var tileWidth:Int;

	/** The tile height. */
	public var tileHeight:Int;

	/** The number of columns the grid has. */
	public var columns:Int;

	/** The number of rows the grid has. */
	public var rows:Int;

	/** The grid data. */
	public var data : Array<Array<Tile>>;

	/** How many tiles the tilemap has. */
	public var tileCount : Int;

	/** The tileset vertical spacing of tile. */
	public var tileSpacingHeight : Int;

	/** The tileset horizontal spacing of tile. */
	public var tileSpacingWidth : Int;

	/**
	 * Create a new tilemap of size [width] by [height] using
	 * the tileset [tileset] which has tiles of size [tileWidth]
	 * by [tileHeight].
	 */
	public function new(tileset:String, width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?config:TileMapConfig);

	/**
	 * Return the index of the tile located at [column]-[row].
	 * An index of -1 indicate an empty tile.
	 */
	public function getTile(column:Int, row:Int) : Tile;

	/**
	 * Sets the index value of the tile located at [colum]-[row].
	 */
	public function setTile(column:Int, row:Int, index:Int) : Void;

	/**
	 * Sets the index sequence of the animated tile located at [colum]-[row].
	 */
	public function setTileAnimation(column:Int, row:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Clear the tile located a [column]-[row], making it empty.
	 * Equivalent to `setTile(column, row, -1)`.
	 */
	public function clearTile(column:Int, row:Int) : Void;

	/**
	 * Return the collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function getRectangle(column:Int, row:Int, width:Int, height:Int) : Array<Array<Tile>>;

	/**
	 * Sets the index value of a collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function setRectangle(column:Int, row:Int, width:Int, height:Int, index:Int) : Void;

	/**
	 * Sets the index sequence of a collection of animated tiles located
	 * in the rectangle starting at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleAnimation(column:Int, row:Int, width:Int, height:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Clear the collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height], making them empty.
	 */
	public function clearRectangle(column:Int, row:Int, width:Int, height:Int) : Void;

	/**
	 * Return the collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function getRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int) : Array<Array<Tile>>;

	/**
	 * Sets the index value of a collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int, index:Int) : Void;

	/**
	 * Sets the index sequence of a collection of animated tiles located
	 * in the outline of thickness [outlineThickness] of the rectangle
	 * starting at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleOutlineAnimation(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Clear the collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height], making them empty.
	 */
	public function clearRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int) : Void;

	/**
	 * Shift all the tiles in the tilemap by [columns] columns
	 * and [rows] rows. Will wrap if [wrap] otherwise the new
	 * tiles will be empty.
	 */
	public function shift(columns:Int, rows:Int, wrap:Bool);
}

enum Tile
{
	Empty;
	Static(index:Int);
	Animated(frames:Array<Int>, frameRate:Float);
}
