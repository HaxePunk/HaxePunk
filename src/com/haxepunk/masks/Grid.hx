package net.flashpunk.masks
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.*;
	
	/**
	 * Uses a hash grid to determine collision, faster than
	 * using hundreds of Entities for tiled levels, etc.
	 */
	public class Grid extends Hitbox
	{
		/**
		 * If x/y positions should be used instead of columns/rows.
		 */
		public var usePositions:Boolean;
		
		/**
		 * Constructor.
		 * @param	width			Width of the grid, in pixels.
		 * @param	height			Height of the grid, in pixels.
		 * @param	tileWidth		Width of a grid tile, in pixels.
		 * @param	tileHeight		Height of a grid tile, in pixels.
		 * @param	x				X offset of the grid.
		 * @param	y				Y offset of the grid.
		 */
		public function Grid(width:uint, height:uint, tileWidth:uint, tileHeight:uint, x:int = 0, y:int = 0) 
		{
			// check for illegal grid size
			if (!width || !height || !tileWidth || !tileHeight) throw new Error("Illegal Grid, sizes cannot be 0.");
			
			// set grid properties
			_columns = width / tileWidth;
			_rows = height / tileHeight;
			_data = new BitmapData(_columns, _rows, true, 0);
			_tile = new Rectangle(0, 0, tileWidth, tileHeight);
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			
			// set callback functions
			_check[Type.getClassName(Mask)] = collideMask;
			_check[Type.getClassName(Hitbox)] = collideHitbox;
			_check[Type.getClassName(Pixelmask)] = collidePixelmask;
		}
		
		/**
		 * Sets the value of the tile.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @param	solid		If the tile should be solid.
		 */
		public function setTile(column:uint = 0, row:uint = 0, solid:Boolean = true):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			_data.setPixel32(column, row, solid ? 0xFFFFFFFF : 0);
		}
		
		/**
		 * Makes the tile non-solid.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 */
		public function clearTile(column:uint = 0, row:uint = 0):void
		{
			setTile(column, row, false);
		}
		
		/**
		 * Gets the value of a tile.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @return	tile value.
		 */
		public function getTile(column:uint = 0, row:uint = 0):Boolean
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			return _data.getPixel32(column, row) > 0;
		}
		
		/**
		 * Sets the value of a rectangle region of tiles.
		 * @param	column		First column.
		 * @param	row			First row.
		 * @param	width		Columns to fill.
		 * @param	height		Rows to fill.
		 * @param	fill		Value to fill.
		 */
		public function setRect(column:uint = 0, row:uint = 0, width:int = 1, height:int = 1, solid:Boolean = true):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
				width /= _tile.width;
				height /= _tile.height;
			}
			_rect.x = column;
			_rect.y = row;
			_rect.width = width;
			_rect.height = height;
			_data.fillRect(_rect, solid ? 0xFFFFFFFF : 0);
		}
		
		/**
		 * Makes the rectangular region of tiles non-solid.
		 * @param	column		First column.
		 * @param	row			First row.
		 * @param	width		Columns to fill.
		 * @param	height		Rows to fill.
		 */
		public function clearRect(column:uint = 0, row:uint = 0, width:int = 1, height:int = 1):void
		{
			setRect(column, row, width, height, false);
		}
		
		/**
		* Loads the grid data from a string.
		* @param str			The string data, which is a set of tile values (0 or 1) separated by the columnSep and rowSep strings.
		* @param columnSep		The string that separates each tile value on a row, default is ",".
		* @param rowSep			The string that separates each row of tiles, default is "\n".
		*/
		public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			var row:Array = str.split(rowSep),
				rows:int = row.length,
				col:Array, cols:int, x:int, y:int;
			for (y = 0; y < rows; y ++)
			{
				if (row[y] == '') continue;
				col = row[y].split(columnSep),
				cols = col.length;
				for (x = 0; x < cols; x ++)
				{
					if (col[x] == '') continue;
					setTile(x, y, uint(col[x]) > 0);
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
				x:int, y:int;
			for (y = 0; y < _rows; y ++)
			{
				for (x = 0; x < _columns; x ++)
				{
					s += String(getTile(x, y));
					if (x != _columns - 1) s += columnSep;
				}
				if (y != _rows - 1) s += rowSep;
			}
			return s;
		}
		
		/**
		 * The tile width.
		 */
		public function get tileWidth():uint { return _tile.width; }
		
		/**
		 * The tile height.
		 */
		public function get tileHeight():uint { return _tile.height; }
		
		/**
		 * How many columns the grid has
		 */
		public function get columns():uint { return _columns; }
		
		/**
		 * How many rows the grid has.
		 */
		public function get rows():uint { return _rows; }
		
		/**
		 * The grid data.
		 */
		public function get data():BitmapData { return _data; }
		
		/** @private Collides against an Entity. */
		private function collideMask(other:Mask):Boolean
		{
			_rect.x = other.parent.x - other.parent.originX - parent.x + parent.originX;
			_rect.y = other.parent.y - other.parent.originY - parent.y + parent.originY;
			_point.x = int((_rect.x + other.parent.width - 1) / _tile.width) + 1;
			_point.y = int((_rect.y + other.parent.height -1) / _tile.height) + 1;
			_rect.x = int(_rect.x / _tile.width);
			_rect.y = int(_rect.y / _tile.height);
			_rect.width = _point.x - _rect.x;
			_rect.height = _point.y - _rect.y;
			return _data.hitTest(FP.zero, 1, _rect);
		}
		
		/** @private Collides against a Hitbox. */
		private function collideHitbox(other:Hitbox):Boolean
		{
			_rect.x = other.parent.x + other._x - parent.x - _x;
			_rect.y = other.parent.y + other._y - parent.y - _y;
			_point.x = int((_rect.x + other._width - 1) / _tile.width) + 1;
			_point.y = int((_rect.y + other._height -1) / _tile.height) + 1;
			_rect.x = int(_rect.x / _tile.width);
			_rect.y = int(_rect.y / _tile.height);
			_rect.width = _point.x - _rect.x;
			_rect.height = _point.y - _rect.y;
			return _data.hitTest(FP.zero, 1, _rect);
		}
		
		/** @private Collides against a Pixelmask. */
		private function collidePixelmask(other:Pixelmask):Boolean
		{
			var x1:int = other.parent.x + other._x - parent.x - _x,
				y1:int = other.parent.y + other._y - parent.y - _y,
				x2:int = ((x1 + other._width - 1) / _tile.width),
				y2:int = ((y1 + other._height - 1) / _tile.height);
			_point.x = x1;
			_point.y = y1;
			x1 /= _tile.width;
			y1 /= _tile.height;
			_tile.x = x1 * _tile.width;
			_tile.y = y1 * _tile.height;
			var xx:int = x1;
			while (y1 <= y2)
			{
				while (x1 <= x2)
				{
					if (_data.getPixel32(x1, y1))
					{
						if (other._data.hitTest(_point, 1, _tile)) return true;
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
		}
		
		// Grid information.
		/** @private */ private var _data:BitmapData;
		/** @private */ private var _columns:uint;
		/** @private */ private var _rows:uint;
		/** @private */ private var _tile:Rectangle;
		/** @private */ private var _rect:Rectangle = FP.rect;
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _point2:Point = FP.point2;
	}
}