package com.haxepunk.masks;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Mask;

enum TileType
{
	Empty;
	Solid;
	AboveSlope;
	BelowSlope;
	// quick types
	TopLeft;
	TopRight;
	BottomLeft;
	BottomRight;
}

typedef Tile = {
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
#if (neko || cpp) // initialize to false instead of null
			for (y in 0...columns)
			{
				data[x][y] = _emptyTile;
			}
#end
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
	@:allow(com.haxepunk.masks.Circle)
	private inline function collidePointInSlope(x1:Float, y1:Float, px:Float, py:Float, tile:Tile):Bool
	{
		y1 += tile.yOffset;

		var yoff = tile.slope * _tile.width;

		var x2 = x1 + yoff / tile.slope,
			y2 = y1 + yoff;

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

	private inline function checkTile(column:Int, row:Int):Bool
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
		if ( ! checkTile(column, row) )
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
	private inline function get_tileWidth():Int { return Std.int(_tile.width); }

	/**
	 * The tile height.
	 */
	public var tileHeight(get, never):Int;
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
	public var data(default, null):Array<Array<Tile>>;

	private function collideBox(opx:Float, opy:Float, opw:Float, oph:Float, px:Float, py:Float):Bool
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

						x = HXP.clamp(x, xx, xx + tileWidth);
						y = HXP.clamp(y, yy, yy + tileHeight);

						if (collidePointInSlope(xx, yy, x, y, tile))
						{
							return true;
						}
					case AboveSlope:
						var x = opx, y = opy;
						if (tile.slope > 0) x += opw;

						x = HXP.clamp(x, xx, xx + tileWidth);
						y = HXP.clamp(y, yy, yy + tileHeight);

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
	override private function collideMask(other:Mask):Bool
	{
		var x:Float = _x + _parent.x, 
			y:Float = _y + _parent.y;
			
		return collideBox(other._parent.x - other._parent.originX,
				other._parent.y - other._parent.originY,
				other._parent.width, other._parent.height,
				_parent.x + _parent.originX, _parent.y + _parent.originY);
	}

	/** @private Collides against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		var x:Float = _x + _parent.x, 
			y:Float = _y + _parent.y,
			ox:Float = other._x + other._parent.x, 
			oy:Float = other._y + other._parent.y;
		
		return collideBox(ox, oy, other._width, other._height, x, y);
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		var cellX:Float, cellY:Float,
			stepX = tileWidth * scaleX,
			stepY = tileHeight * scaleY;

		// determine drawing location
		var px = _x + _parent.x - HXP.camera.x;
		var py = _y + _parent.y - HXP.camera.y;

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

		var row:Array<Tile>;
		cellY = py;
		for (y in starty...desty)
		{
			cellX = px;
			row = data[y];
			for (x in startx...destx)
			{
				var tile = row[x];
				if (tile == null || tile.type == null)
				{
				}
				else if (tile.type == Solid)
				{
					graphics.lineStyle(1, 0xFFFFFF, 0.3);
					graphics.drawRect(cellX, cellY, stepX, stepY);

					if (x < columns - 1 && row[x + 1].type == Empty)
					{
						graphics.lineStyle(1, 0x0000FF);
						graphics.moveTo(cellX + stepX, cellY);
						graphics.lineTo(cellX + stepX, cellY + stepY);
					}
					if (x > 0 && row[x - 1].type == Empty)
					{
						graphics.lineStyle(1, 0x0000FF);
						graphics.moveTo(cellX, cellY);
						graphics.lineTo(cellX, cellY + stepY);
					}
					if (y < rows - 1 && data[y + 1][x].type == Empty)
					{
						graphics.lineStyle(1, 0x0000FF);
						graphics.moveTo(cellX, cellY + stepY);
						graphics.lineTo(cellX + stepX, cellY + stepY);
					}
					if (y > 0 && data[y - 1][x].type == Empty)
					{
						graphics.lineStyle(1, 0x0000FF);
						graphics.moveTo(cellX, cellY);
						graphics.lineTo(cellX + stepX, cellY);
					}
				}
				else if (tile.type == BelowSlope || tile.type == AboveSlope)
				{
					var offset = tile.yOffset * scaleY;
					var xpos = cellX,
						endx = stepX,
						ypos = cellY + offset,
						endy = tile.slope * endx;

					// draw a flat line if slope goes past tile boundaries
					if (offset < 0)
					{
						var fx = -offset / tile.slope; // find x where y = 0
						endx = stepX - fx;
						xpos = cellX + fx;
						ypos = cellY;

						// only draw line if next to solid
						if (y <= 0 || data[y - 1][x].type == Solid)
						{
							graphics.moveTo(cellX, ypos);
							graphics.lineTo(xpos, ypos);
						}
					}
					else if (offset > tileHeight)
					{
						var fx = -(offset - tileWidth) / tile.slope; // find x where y = 0
						endx = stepX - fx;
						xpos = cellX + fx;
						ypos = cellY + stepY;

						// only draw line if next to solid
						if (y >= rows - 1 || data[y + 1][x].type == Solid)
						{
							graphics.moveTo(cellX, ypos);
							graphics.lineTo(xpos, ypos);
						}
					}
					else if (offset + endy < 0)
					{
						var fx = -offset / tile.slope; // find x where y = 0
						endx = fx;

						// only draw line if next to solid
						if (y <= 0 || data[y - 1][x].type == Solid)
						{
							graphics.moveTo(cellX + fx, cellY);
							graphics.lineTo(cellX + stepX, cellY);
						}
					}
					else if (offset + endy > tileHeight)
					{
						var fx = -(offset - tileWidth) / tile.slope; // find x where y = 0
						endx = fx;

						// only draw line if next to solid
						if (y >= rows - 1 || data[y + 1][x].type == Solid)
						{
							graphics.moveTo(cellX + fx, cellY + stepY);
							graphics.lineTo(cellX + stepX, cellY + stepY);
						}
					}

					// recalculate if there's a new endx
					endy = tile.slope * endx;

					graphics.lineStyle(1, 0x0000FF);
					graphics.moveTo(xpos, ypos);
					graphics.lineTo(xpos + endx, ypos + endy);
				}

				cellX += stepX;
			}
			cellY += stepY;
		}
	}

	// Grid information.
	private var _tile:Rectangle;
	private var _rect:Rectangle;
	private var _point:Point;
	private var _point2:Point;

	private static var _emptyTile:Tile = { type: Empty }; // prevent recreation of empty tile
}
