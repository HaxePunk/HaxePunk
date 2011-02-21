package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import net.flashpunk.FP;
	
	/**
	 * Special Image object that can display blocks of tiles.
	 */
	public class TiledImage extends Image
	{
		/**
		 * Constructs the TiledImage.
		 * @param	texture		Source texture.
		 * @param	width		The width of the image (the texture will be drawn to fill this area).
		 * @param	height		The height of the image (the texture will be drawn to fill this area).
		 * @param	clipRect	An optional area of the source texture to use (eg. a tile from a tileset).
		 */
		public function TiledImage(texture:*, width:uint = 0, height:uint = 0, clipRect:Rectangle = null)
		{
			_width = width;
			_height = height;
			super(texture, clipRect);
		}
		
		/** @private Creates the buffer. */
		override protected function createBuffer():void 
		{
			if (!_width) _width = _sourceRect.width;
			if (!_height) _height = _sourceRect.height;
			_buffer = new BitmapData(_width, _height, true, 0);
			_bufferRect = _buffer.rect;
		}
		
		/** @private Updates the buffer. */
		override public function updateBuffer(clearBefore:Boolean = false):void
		{
			if (!_source) return;
			if (!_texture)
			{
				_texture = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
				_texture.copyPixels(_source, _sourceRect, FP.zero);
			}
			_buffer.fillRect(_bufferRect, 0);
			_graphics.clear();
			if (_offsetX != 0 || _offsetY != 0)
			{
				FP.matrix.identity();
				FP.matrix.tx = Math.round(_offsetX);
				FP.matrix.ty = Math.round(_offsetY);
				_graphics.beginBitmapFill(_texture, FP.matrix);
			}
			else _graphics.beginBitmapFill(_texture);
			_graphics.drawRect(0, 0, _width, _height);
			_buffer.draw(FP.sprite, null, _tint);
		}
		
		/**
		 * The x-offset of the texture.
		 */
		public function get offsetX():Number { return _offsetX; }
		public function set offsetX(value:Number):void
		{
			if (_offsetX == value) return;
			_offsetX = value;
			updateBuffer();
		}
		
		/**
		 * The y-offset of the texture.
		 */
		public function get offsetY():Number { return _offsetY; }
		public function set offsetY(value:Number):void
		{
			if (_offsetY == value) return;
			_offsetY = value;
			updateBuffer();
		}
		
		/**
		 * Sets the texture offset.
		 * @param	x		The x-offset.
		 * @param	y		The y-offset.
		 */
		public function setOffset(x:Number, y:Number):void
		{
			if (_offsetX == x && _offsetY == y) return;
			_offsetX = x;
			_offsetY = y;
			updateBuffer();
		}
		
		// Drawing information.
		/** @private */ private var _graphics:Graphics = FP.sprite.graphics;
		/** @private */ private var _texture:BitmapData;
		/** @private */ private var _width:uint;
		/** @private */ private var _height:uint;
		/** @private */ private var _offsetX:Number = 0;
		/** @private */ private var _offsetY:Number = 0;
	}
}