package haxepunk.masks;

import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.Mask;
import haxepunk.utils.MathUtil;

@:enum
abstract TileType(Int)
{
	var Empty = 0;
	var Solid = 1;
	var AboveSlope = 2;
	var BelowSlope = 3;
	// quick types
	var TopLeft = 4;
	var TopRight = 5;
	var BottomLeft = 6;
	var BottomRight = 7;
}

typedef Tile =
{
	var type:TileType;
	@:optional var slope:Float;
	@:optional var yOffset:Float;
}

/**
 * Uses a hash grid to determine collision, faster than
 * using hundreds of Entities for tiled levels, etc.
 */
class SlopedGrid extends Hitbox
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

		data = new Array<Array<Tile>>();
		for (x in 0...rows)
		{
			data.push(new Array<Tile>());
			for (y in 0...columns)
			{
				data[x][y] = _emptyTile;
			}
		}
	}

	/**
	 * Checks collision against SlopedGrid from a point
	 * @param cx  x-axis of the collision point
	 * @param cy  y-axis of the collision point
	 * @return If the point collides with SlopedGrid
	 */
	public function collidePoint(cx:Float, cy:Float):Bool
	{
		var px:Float = _x + _parent.x,
			py:Float = _y + _parent.y;

		var column = Std.int((cx - px) / _tile.width),
			row = Std.int((cy - py) / _tile.height),
			x = px + column * _tile.width,
			y = py + row * _tile.height;

		var tile = getTile(column, row);
		if (tile != null)
		{
			if (tile.type == Solid)
			{
				return true;
			}
			else if (tile.type == AboveSlope || tile.type == BelowSlope)
			{
				if (collidePointInSlope(x, y, cx, cy, tile)) return true;
			}
		}
		return false;
	}

	/**
	 * Checks collision against a specific slope tile
	 * Does not test if tile is a slope so this must be done before calling the method
	 * @param x1    x-axis value of the tile (world coordinates)
	 * @param y1    y-axis value of the tile (world coordinates)
	 * @param px    x-axis of the collisions point (world coordinates)
	 * @param py    y-axis of the collisions point (world coordinates)
	 * @param tile  tile data for this position of SlopedGrid, saves an extra lookup
	 * @return If the point collides with a slope
	 */
	@:allow(haxepunk.masks.Circle)
	inline function collidePointInSlope(x1:Float, y1:Float, px:Float, py:Float, tile:Tile):Bool
	{
		y1 += tile.yOffset;

		var x2 = x1 + _tile.width,
			y2 = y1 + tile.slope * _tile.width;

		var left:Bool = (x2 - x1) * (py - y1) > (y2 - y1) * (px - x1);

		return (tile.type == AboveSlope && !left) || (tile.type == BelowSlope && left);
	}

	/**
	 * Sets the value of a tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	type		The type of the tile
	 * @param	slope		The slope of the tile
	 * @param	yOffset		The y offset of the tile
	 */
	public function setTile(column:Int = 0, row:Int = 0, ?type:TileType, slope:Float = 0, yOffset:Float=0):Void
	{
		if (!checkTile(column, row)) return;

		if (type == null) type = Solid;

		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}

		switch (type)
		{
			case TopLeft:
				data[row][column] = {
					type: AboveSlope,
					slope: -1,
					yOffset: _tile.height
				};
			case TopRight:
				data[row][column] = {
					type: AboveSlope,
					slope: 1,
					yOffset: 0
				};
			case BottomLeft:
				data[row][column] = {
					type: BelowSlope,
					slope: 1,
					yOffset: 0
				};
			case BottomRight:
				data[row][column] = {
					type: BelowSlope,
					slope: -1,
					yOffset: _tile.height
				};
			default:
				data[row][column] = {
					type: type,
					slope: slope,
					yOffset: yOffset * _tile.height
				};
		}

	}

	/**
	 * Makes the tile non-solid.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public inline function clearTile(column:Int = 0, row:Int = 0):Void
	{
		setTile(column, row, Empty);
	}

	inline function checkTile(column:Int, row:Int):Bool
	{
		// check that tile is valid
		return (column >= 0 && column < columns && row >= 0 && row < rows);
	}

	/**
	 * Gets the value of a tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	 */
	public inline function getTile(column:Int = 0, row:Int = 0):Tile
	{
		if (!checkTile(column, row))
		{
			return _emptyTile;
		}
		else
		{
			if (usePositions)
			{
				column = Std.int(column / _tile.width);
				row = Std.int(row / _tile.height);
			}
			return data[row][column];
		}
	}

	/**
	 * Sets the value of a rectangle region of tiles.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 * @param	type		The type of the tiles
	 * @param	slope		The slope of the tiles
	 * @param	yOffset		The y offset of the tiles
	 */
	public function setRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1, ?type:TileType, slope:Float = 0, yOffset:Float = 0)
	{
		if (type == null) type = Solid;

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
				setTile(xx, yy, type, slope, yOffset);
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
		setRect(column, row, width, height, Empty);
	}

	/**
	 * The tile width.
	 */
	public var tileWidth(get, never):Int;
	inline function get_tileWidth():Int return Std.int(_tile.width);

	/**
	 * The tile height.
	 */
	public var tileHeight(get, never):Int;
	inline function get_tileHeight():Int return Std.int(_tile.height);

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
	public var data(default, null):Array<Array<Tile>>;

	function collideBox(opx:Float, opy:Float, opw:Float, oph:Float, px:Float, py:Float):Bool
	{
		_rect.x = opx - px;
		_rect.y = opy - py;
		var startx = Std.int(_rect.x / _tile.width),
			starty = Std.int(_rect.y / _tile.height),
			endx = Std.int((_rect.x + opw - 1) / _tile.width) + 1,
			endy = Std.int((_rect.y + oph - 1) / _tile.height) + 1;
		// trace(startx + ", " + starty + " : " + endx + ", " + endy);

		var yy = py + starty * _tile.height;
		for (dy in starty...endy)
		{
			var xx = px + startx * _tile.width;
			for (dx in startx...endx)
			{
				var tile = getTile(dx, dy);
				if (tile == null) continue;
				switch (tile.type)
				{
					case Solid:
						return true;
					case BelowSlope:
						var x = opx, y = opy + oph;
						if (tile.slope < 0) x += opw;

						x = MathUtil.clamp(x, xx, xx + tileWidth);
						y = MathUtil.clamp(y, yy, yy + tileHeight);

						if (collidePointInSlope(xx, yy, x, y, tile))
						{
							return true;
						}
					case AboveSlope:
						var x = opx, y = opy;
						if (tile.slope > 0) x += opw;

						x = MathUtil.clamp(x, xx, xx + tileWidth);
						y = MathUtil.clamp(y, yy, yy + tileHeight);

						if (collidePointInSlope(xx, yy, x, y, tile))
						{
							return true;
						}
					default:
				}
				xx += _tile.width;
			}
			yy += _tile.height;
		}
		return false;
	}

	/** @private Collides against an Entity. */
	override function collideMask(other:Mask):Bool
	{
		var x:Float = _x + _parent.x,
			y:Float = _y + _parent.y;

		return collideBox(other._parent.x - other._parent.originX,
				other._parent.y - other._parent.originY,
				other._parent.width, other._parent.height,
				_parent.x + _parent.originX, _parent.y + _parent.originY);
	}

	/** @private Collides against a Hitbox. */
	override function collideHitbox(other:Hitbox):Bool
	{
		var x:Float = _x + _parent.x,
			y:Float = _y + _parent.y,
			ox:Float = other._x + other._parent.x,
			oy:Float = other._y + other._parent.y;

		return collideBox(ox, oy, other._width, other._height, x, y);
	}

	@:dox(hide)
	override public function debugDraw(camera:Camera):Void
	{
		var dc = Mask.drawContext,
			scaleX = camera.fullScaleX,
			scaleY = camera.fullScaleY;
		var cellX:Float, cellY:Float,
			stepX = tileWidth * scaleX,
			stepY = tileHeight * scaleY;

		// determine drawing location
		var px = _x + _parent.x - camera.x;
		var py = _y + _parent.y - camera.y;

		// determine start and end tiles to draw (optimization)
		var startx = Math.floor( -px / tileWidth),
			starty = Math.floor( -py / tileHeight),
			destx = startx + 1 + Math.ceil(HXP.width / tileWidth),
			desty = starty + 1 + Math.ceil(HXP.height / tileHeight);

		// nothing will render if we're completely off screen
		if (startx > columns || starty > rows || destx < 0 || desty < 0)
			return;

		// clamp values to boundaries
		if (startx < 0) startx = 0;
		if (destx > columns) destx = columns;
		if (starty < 0) starty = 0;
		if (desty > rows) desty = rows;

		px = (px + (startx * tileWidth)) * scaleX;
		py = (py + (starty * tileHeight)) * scaleY;

		dc.lineThickness = 2;

		var row:Array<Tile>;
		cellY = py;
		for (y in starty...desty)
		{
			cellX = px;
			row = data[y];
			for (x in startx...destx)
			{
				var tile = row[x];
				if (tile == null || tile.type == null) {}
				else if (tile.type == Solid)
				{
					dc.setColor(0xffffff, 0.3);
					dc.rect(cellX, cellY, stepX, stepY);
					dc.setColor(0x0000ff, 1);

					if (x < columns - 1 && row[x + 1].type == Empty)
					{
						dc.line(cellX + stepX, cellY, cellX + stepX, cellY + stepY);
					}
					if (x > 0 && row[x - 1].type == Empty)
					{
						dc.line(cellX, cellY, cellX, cellY + stepY);
					}
					if (y < rows - 1 && data[y + 1][x].type == Empty)
					{
						dc.line(cellX, cellY + stepY, cellX + stepX, cellY + stepY);
					}
					if (y > 0 && data[y - 1][x].type == Empty)
					{
						dc.line(cellX, cellY, cellX + stepX, cellY);
					}
				}
				else if (tile.type == BelowSlope || tile.type == AboveSlope)
				{
					var offset:Float = tile.yOffset * scaleY;
					var slope = tile.slope * scaleY / scaleX;
					var xpos:Float = cellX,
						endx:Float = stepX,
						ypos:Float = cellY + offset,
						endy:Float = slope * endx;

					// draw a flat line if slope goes past tile boundaries
					if (offset < 0)
					{
						var fx = -offset / slope; // find x where y = 0
						endx = stepX - fx;
						xpos = cellX + fx;
						ypos = cellY;

						// only draw line if next to solid
						if (y <= 0 || data[y - 1][x].type == Solid)
						{
							dc.line(cellX, ypos, xpos, ypos);
						}
					}
					else if (offset > stepY)
					{
						var fx = -(offset - stepX) / slope; // find x where y = 0
						endx = stepX - fx;
						xpos = cellX + fx;
						ypos = cellY + stepY;

						// only draw line if next to solid
						if (y >= rows - 1 || data[y + 1][x].type == Solid)
						{
							dc.line(cellX, ypos, xpos, ypos);
						}
					}
					else if (offset + endy < 0)
					{
						var fx = -offset / slope; // find x where y = 0
						endx = fx;

						// only draw line if next to solid
						if (y <= 0 || data[y - 1][x].type == Solid)
						{
							dc.line(cellX + fx, cellY, cellX + stepX, cellY);
						}
					}
					else if (offset + endy > stepY)
					{
						var fx = -(offset - stepX) / slope; // find x where y = 0
						endx = fx;

						// only draw line if next to solid
						if (y >= rows - 1 || data[y + 1][x].type == Solid)
						{
							dc.line(cellX + fx, cellY + stepY, cellX + stepX, cellY + stepY);
						}
					}

					// recalculate if there's a new endx
					endy = slope * endx;

					dc.line(xpos, ypos, xpos + endx, ypos + endy);
				}

				cellX += stepX;
			}
			cellY += stepY;
		}
	}

	// Grid information.
	var _tile:Rectangle;
	var _rect:Rectangle;
	var _point:Point;
	var _point2:Point;

	static var _emptyTile:Tile = { type: Empty }; // prevent recreation of empty tile
}
