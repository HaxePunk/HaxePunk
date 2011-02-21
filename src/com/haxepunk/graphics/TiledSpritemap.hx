package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import net.flashpunk.FP;
	
	/**
	 * Special Spritemap object that can display blocks of animated sprites.
	 */
	public class TiledSpritemap extends Spritemap
	{
		/**
		 * Constructs the tiled spritemap.
		 * @param	source			Source image.
		 * @param	frameWidth		Frame width.
		 * @param	frameHeight		Frame height.	
		 * @param	width			Width of the block to render.
		 * @param	height			Height of the block to render.
		 * @param	callback		Optional callback function for animation end.
		 */
		public function TiledSpritemap(source:*, frameWidth:uint = 0, frameHeight:uint = 0, width:uint = 0, height:uint = 0, callback:Function = null) 
		{
			_imageWidth = width;
			_imageHeight = height;
			super(source, frameWidth, frameHeight, callback);
		}
		
		/** @private Creates the buffer. */
		override protected function createBuffer():void 
		{
			if (!_imageWidth) _imageWidth = _sourceRect.width;
			if (!_imageHeight) _imageHeight = _sourceRect.height;
			_buffer = new BitmapData(_imageWidth, _imageHeight, true, 0);
			_bufferRect = _buffer.rect;
		}
		
		/** @private Updates the buffer. */
		override public function updateBuffer(clearBefore:Boolean = false):void 
		{
			// get position of the current frame
			_rect.x = _rect.width * _frame;
			_rect.y = uint(_rect.x / _width) * _rect.height;
			_rect.x %= _width;
			if (_flipped) _rect.x = (_width - _rect.width) - _rect.x;
			
			// render it repeated to the buffer
			var xx:int = int(_offsetX) % _imageWidth,
				yy:int = int(_offsetY) % _imageHeight;
			if (xx >= 0) xx -= _imageWidth;
			if (yy >= 0) yy -= _imageHeight;
			FP.point.x = xx;
			FP.point.y = yy;
			while (FP.point.y < _imageHeight)
			{
				while (FP.point.x < _imageWidth)
				{
					_buffer.copyPixels(_source, _sourceRect, FP.point);
					FP.point.x += _sourceRect.width;
				}
				FP.point.x = xx;
				FP.point.y += _sourceRect.height;
			}
			
			// tint the buffer
			if (_tint) _buffer.colorTransform(_bufferRect, _tint);
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
		
		/** @private */ private var _graphics:Graphics = FP.sprite.graphics;
		/** @private */ private var _imageWidth:uint;
		/** @private */ private var _imageHeight:uint;
		/** @private */ private var _offsetX:Number = 0;
		/** @private */ private var _offsetY:Number = 0;
	}
}