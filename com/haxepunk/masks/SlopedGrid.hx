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
			HXP.throwError("Illegal Grid, sizes cannot be 0.");
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
				data[x][y] = { type: Empty };
			}
#end
		}
	}

	/**
	 * Sets the value of the tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	type		The type of the tile
	 * @param	slope		The slope of the tile
	 * @param	yOffset		The y offset of the tile
	 */
	public function setTile(column:Int = 0, row:Int = 0, ?type:TileType, slope:Float = 0, yOffset:Float=0)
	{
		if ( ! checkTile(column, row) ) return;

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
	public inline function clearTile(column:Int = 0, row:Int = 0)
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
			return { type: Empty };
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
	public var data(default, null):Array<Array<Tile>>;

	private function collideBox(opx:Float, opy:Float, opw:Float, oph:Float, px:Float, py:Float):Bool
	{
		var rectX:Int, rectY:Int, pointX:Int, pointY:Int;
		_rect.x = opx - px;
		_rect.y = opy - py;
		pointX  = Std.int((_rect.x + opw - 1) / _tile.width) + 1;
		pointY  = Std.int((_rect.y + oph -1) / _tile.height) + 1;
		rectX   = Std.int(_rect.x / _tile.width);
		rectY   = Std.int(_rect.y / _tile.height);

		var collide:Bool = false;
		for (dy in rectY...pointY)
		{
			for (dx in rectX...pointX)
			{
				var tile = getTile(dx, dy);
				if (tile == null || tile.type == null) continue;
				switch (tile.type)
				{
					case Solid:
						collide = true;
					case BelowSlope:
						var y = _rect.y - tile.yOffset - (dy * tileHeight);
						var x = _rect.x - (dx * tileWidth);
						var end = x + opw;
						while (x < end)
						{
							var mx = tile.slope * x;
							if (y > mx || y + oph > mx)
							{
								collide = true;
								break;
							}
							x += 1;
						}
					case AboveSlope:
						var y = _rect.y - tile.yOffset - (dy * tileHeight);
						var x = _rect.x - (dx * tileWidth);
						var end = x + opw;
						while (x < end)
						{
							var mx = tile.slope * x;
							if (y < mx || y + oph < mx)
							{
								collide = true;
								break;
							}
							x += 1;
						}
					default:
				}
				// early out if we collided with something
				if (collide)
				{
					break;
				}
			}
		}
		return collide;
	}

	/** @private Collides against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		return collideBox(other.parent.x - other.parent.originX,
			other.parent.y - other.parent.originY,
			other.parent.width, other.parent.height,
			parent.x + parent.originX, parent.y + parent.originY);
	}

	/** @private Collides against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		return collideBox(other.parent.x - other._x,
			other.parent.y - other._y,
			other._width, other._height,
			parent.x + _x, parent.y + _y);
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		HXP.point.x = (_x + parent.x - HXP.camera.x) * HXP.screen.fullScaleX;
		HXP.point.y = (_y + parent.y - HXP.camera.y) * HXP.screen.fullScaleY;

		graphics.beginFill(0x0000FF, 0.3);
		var stepX = tileWidth * HXP.screen.fullScaleX,
			stepY = tileHeight * HXP.screen.fullScaleY,
			pos = HXP.point.x + stepX;

		for (i in 1...columns)
		{
			graphics.drawRect(pos, HXP.point.y, 1, _height * HXP.screen.fullScaleX);
			pos += stepX;
		}

		pos = HXP.point.y + stepY;
		for (i in 1...rows)
		{
			graphics.drawRect(HXP.point.x, pos, _width * HXP.screen.fullScaleY, 1);
			pos += stepY;
		}

		var ry = HXP.point.y;
		for (y in 0...rows)
		{
			var rx = HXP.point.x;
			for (x in 0...columns)
			{
				var tile = data[y][x];
				if (tile == null || tile.type == null)
				{
				}
				else if (tile.type == Solid)
				{
					graphics.drawRect(rx, ry, stepX, stepY);
				}
				else if (tile.type == BelowSlope || tile.type == AboveSlope)
				{
					var ypos = ry + tile.yOffset * HXP.screen.fullScaleY;
					graphics.moveTo(rx, ypos);
					graphics.lineTo(rx + stepX, ypos + tile.slope * stepX);
				}
				rx += stepX;
			}
			ry += stepY;
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
