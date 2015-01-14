package haxepunk2d.graphics;

typedef TileMapConfig = {
	> GraphicConfig,
	@:optional tileSpacingWidth:Int,
	@:optional tileSpacingHeight:Int
};

/**
 * A graphic made of tiles from a tileset.
 * Way faster than creating hundreds of graphics.
 */
class TileMap extends Graphic
{
	/** Default values for newly created tile maps when config options are ommited. Config options inherited from GraphicConfig may be left null to use the values from Graphic's defaultConfig. */
	public static var defaultConfig : TileMapConfig;

	/** The tile width. */
	public var tileWidth(default, null):Int;

	/** The tile height. */
	public var tileHeight(default, null):Int;

	/** The number of columns the grid has. */
	public var columns(default, null):Int;

	/** The number of rows the grid has. */
	public var rows(default, null):Int;

	/** The grid data. */
	public var data : Array<Array<Int>>;

	/** How many tiles the tilemap has. */
	public var tileCount(default, null) : Int;

	/** The tileset vertical spacing of tile. */
	public var tileSpacingHeight(default, null) : Int;

	/** The tileset horizontal spacing of tile. */
	public var tileSpacingWidth(default, null) : Int;

	/**
	 * Create a new tilemap of size [width] by [height] using
	 * the tileset(s) [tileset] which has tiles of size [tileWidth]
	 * by [tileHeight].
	 * If multiple tilesets are used they must have the same tile size, indexes will be
	 * contiguous in the order of the tilesets array.
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public function new(tileset:Either<String, Array<String>>, width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?config:TileMapConfig);

	/**
	 * Sets the tile map tile index data from a string.
	 * The implicit array should not be bigger than the tile map, if it is
	 * smaller the tiles outside of it will be reset to -1 (no tile) if [clear]
	 * otherwise they'll keep their current value.
	 * Invalid indexes will be ignored and the tile will be set to either -1 (no tile)
	 * if [clear] otherwise they'll keep their current value.
	 */
	public function setFromString(data:String, columnSep:String=",", rowSep:String="\n", clear:Bool=false):Void;

	/**
	 * Return the index of the tile located at [column]-[row].
	 * An index of -1 indicate an empty tile.
	 */
	public function getTile(column:Int, row:Int) : Int;

	/**
	 * Sets the index value of the tile located at [colum]-[row].
	 */
	public function setTile(column:Int, row:Int, index:Int) : Void;

	/**
	 * Clear the tile located a [column]-[row], making it empty.
	 * Equivalent to `setTile(column, row, -1)`.
	 */
	public function clearTile(column:Int, row:Int) : Void;

	/**
	 * Return the collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function getRectangle(column:Int, row:Int, width:Int, height:Int) : Array<Array<Int>>;

	/**
	 * Sets the index value of a collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function setRectangle(column:Int, row:Int, width:Int, height:Int, index:Int) : Void;

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
	public function getRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int) : Array<Array<Int>>;

	/**
	 * Sets the index value of a collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int, index:Int) : Void;

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
