package com.haxepunk.graphics;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

/**
 * Creates a pre-rotated Image strip to increase runtime performance for rotating graphics.
 */
class PreRotation extends Image
{
	/**
	 * Current angle to fetch the pre-rotated frame from.
	 */
	public var frameAngle:Float;

	/**
	 * Constructor.
	 * @param	source			The source image to be rotated.
	 * @param	frameCount		How many frames to use. More frames result in smoother rotations.
	 * @param	smooth			Make the rotated graphic appear less pixelly.
	 */
	public function new(source:Dynamic, frameCount:Int = 36, smooth:Bool = false)
	{
		frameAngle = 0;
		_last = _current = -1;

		if (HXP.renderMode.has(RenderMode.BUFFER))
		{
			var name:String = '';
			if (Std.is(source, String))
				name = source;
			else
				name = Type.getClassName(source);

			var r:BitmapData = _rotated.get(name);
			_size = _sizes.get(name);
			_frame = new Rectangle(0, 0, _size, _size);

			if (r == null)
			{
				// produce a rotated bitmap strip
				var temp:BitmapData = HXP.getBitmap(source);
				_size = Math.ceil(HXP.distance(0, 0, temp.width, temp.height));
				_sizes.set(name, _size);
				_frame.width = _frame.height = _size;
				var width:Int = Std.int(_frame.width * frameCount),
					height:Int = Std.int(_frame.height);
				if (width > _MAX_WIDTH)
				{
					width = Std.int(_MAX_WIDTH - (_MAX_WIDTH % _frame.width));
					height = Std.int(Math.ceil(frameCount / (width / _frame.width)) * _frame.height);
				}
				r = HXP.createBitmap(width, height, true);
				_rotated.set(name, r);
				var m:Matrix = HXP.matrix,
					a:Float = 0,
					aa:Float = Math.PI * 2 / -frameCount,
					ox:Int = Std.int(temp.width / 2),
					oy:Int = Std.int(temp.height / 2),
					o:Int = Std.int(_frame.width / 2),
					x:Int = 0,
					y:Int = 0;
				while (y < height)
				{
					while (x < width)
					{
						m.identity();
						m.translate(-ox, -oy);
						m.rotate(a);
						m.translate(o + x, o + y);
						r.draw(temp, m, null, null, null, smooth);
						x = Std.int(x + _frame.width);
						a += aa;
					}
					x = 0;
					y = Std.int(y + _frame.height);
				}
			}
			_width = r.width;
			_frameCount = frameCount;
			super(r, _frame);
		}
		else
		{
			super(source);
			_size = Math.ceil(HXP.distance(0, 0, _region.width, _region.height));
		}
	}

	/** Renders the PreRotated graphic. */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		if (_blit)
		{
			frameAngle %= 360;
			if (frameAngle < 0) frameAngle += 360;
			_current = Math.floor(_frameCount * frameAngle / 360);
			if (_last != _current)
			{
				_last = _current;
				_frame.x = _frame.width * _last;
				_frame.y = Std.int(_frame.x / _size) * _frame.height;
				_frame.x %= _size;
				updateBuffer();
			}
			super.render(target, point, camera);
		}
		else
		{
			var sin = Math.sin(angle * HXP.RAD),
				cos = Math.cos(angle * HXP.RAD),
				ox = (_size - _region.width) / 2 - originX,
				oy = (_size - _region.height) / 2 - originY,
				offsetX = cos * ox + sin * ox,
				offsetY = -sin * oy + cos * oy;
			originX -= offsetX;
			originY -= offsetY;
			super.render(target, point, camera);
			originX += offsetX;
			originY += offsetY;
		}
	}

	/**
	 * Width of the image.
	 */
	private override function get_width():Int { return _size; }

	/**
	 * Height of the image.
	 */
	private override function get_height():Int { return _size; }

	// Rotation information.
	private var _size:Int;
	private var _width:Int;
	private var _frame:Rectangle;
	private var _frameCount:Int;
	private var _last:Int;
	private var _current:Int;

	// Global information.
#if haxe3
	private static var _rotated:Map<String,BitmapData> = new Map<String,BitmapData>();
	private static var _sizes:Map<String,Int> = new Map<String,Int>();
#else
	private static var _rotated:Hash<BitmapData> = new Hash<BitmapData>();
	private static var _sizes:Hash<Int> = new Hash<Int>();
#end

	private static inline var _MAX_WIDTH:Int = 3000;
	private static inline var _MAX_HEIGHT:Int = 4000;
}
