package haxepunk.graphics;

#if flash
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
#end
import lime.graphics.GL;
import lime.graphics.GLBuffer;
import lime.utils.Float32Array;
import haxepunk.math.Vector3D;
import haxepunk.math.Matrix3D;

class Image implements Graphic
{

	public var material:Material;

	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the image, effects both x and y scale.
	 */
	public var scale:Float = 1;

	/**
	 * X scale of the image.
	 */
	public var scaleX:Float = 1;

	/**
	 * Y scale of the image.
	 */
	public var scaleY:Float = 1;

	/**
	 * X origin of the image, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originX:Float = 0;

	/**
	 * Y origin of the image, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originY:Float = 0;

	/**
	 * Width of the image.
	 */
	public var width(get, never):Float;
	private function get_width():Float { return _texture.width; }

	/**
	 * Height of the image.
	 */
	public var height(get, never):Float;
	private function get_height():Float { return _texture.height; }

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(default, set):Float;
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		return (alpha == value) ? value : alpha = value;
	}

	public function new(path:String)
	{
		_matrix = new Matrix3D();
		_texture = Texture.create(path);
		material = new Material();
		material.addTexture(_texture);

		createBuffer();
	}

	public function update(elapsed:Float) {}

#if flash
	/**
	 * Creates BitmapData based on platform specifics
	 *
	 * @param	width			BitmapData's width.
	 * @param	height			BitmapData's height.
	 * @param	transparent		If the BitmapData can have transparency.
	 * @param	color			BitmapData's color.
	 *
	 * @return	The BitmapData.
	 */
	public static function createBitmap(width:Int, height:Int, ?transparent:Bool = false, ?color:Int = 0):BitmapData
	{
	#if flash8
		var sizeError:Bool = (width > 2880 || height > 2880);
	#else
		var sizeError:Bool = (width * height > 16777215 || width > 8191 || height > 8191); // flash 10 requires size to be under 16,777,215
	#end
		if (sizeError)
		{
			trace("BitmapData is too large (" + width + ", " + height + ")");
			return null;
		}

		return new BitmapData(width, height, transparent, color);
	}
#end // flash

	/** @private Creates the buffer. */
	private function createBuffer():Void
	{
#if flash
		_buffer = createBitmap(_texture.width, _texture.height, true);
		_bufferRect = _buffer.rect;
		_bitmap.bitmapData = _buffer;
#else
		if (_vertexBuffer == null)
		{
			var data = [
				/* vertex | tex coord | normal */
				0, 0, 0, 0.00, 0.00, 0, 0, -1,
				0, 1, 0, 0.00, 1.00, 0, 0, -1,
				1, 0, 0, 1.00, 0.00, 0, 0, -1,
				1, 1, 0, 1.00, 1.00, 0, 0, -1
			];
			_vertexBuffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		}
#end
	}

	public function centerOrigin():Void
	{
		originX = -(width / 2);
		originY = -(height / 2);
		_matrixDirty = true;
	}

	#if !flash
	private inline function drawBuffer(projectionMatrix:Float32Array, modelViewMatrix:Matrix3D, buffer:GLBuffer, offset:Int=0):Void
	{
		if (buffer != null)
		{
			if (_matrixDirty)
			{
				_matrix.identity();
				_matrix.scale(width, height, 1);
				_matrix.translate(originX, originY, 0);
				_matrix.scale(scale * scaleX, scale * scaleY, 1);
				_matrix.rotateZ(angle);
				_matrixDirty = false;
			}

			GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
			material.use(projectionMatrix, _matrix.clone().multiply(modelViewMatrix));
			GL.drawArrays(GL.TRIANGLE_STRIP, offset << 2, 4);
			// material.disable();
		}
	}
	#end

	public function draw(projectionMatrix:Float32Array, modelViewMatrix:Matrix3D):Void
	{
		switch (HXP.context)
		{
			case OPENGL(gl):
			#if !flash
				drawBuffer(projectionMatrix, modelViewMatrix, _vertexBuffer);
			#end
			case FLASH(stage):
			#if flash
				var sx = scale * scaleX,
					sy = scale * scaleY;

				// determine drawing location
				// var point = new flash.geom.Point(point.x + x - originX - camera.x * scrollX, point.y + y - originY - camera.y * scrollY);

				// if (angle == 0 && sx == 1 && sy == 1)
				// {
				// 	// render without transformation
				// 	stage.copyPixels(_buffer, _bufferRect, _point, null, null, true);
				// }
				// else
				// {
				// 	// render with transformation
				// 	_matrix.b = _matrix.c = 0;
				// 	_matrix.a = sx;
				// 	_matrix.d = sy;
				// 	_matrix.tx = -originX * sx;
				// 	_matrix.ty = -originY * sy;
				// 	if (angle != 0) _matrix.rotate(angle * HXP.RAD);
				// 	_matrix.tx += originX + _point.x;
				// 	_matrix.ty += originY + _point.y;
				// 	stage.draw(_bitmap, _matrix, null, blend, null, _bitmap.smoothing);
				// }
			#end
			default:
				throw "Unsupported render context!";
		}
	}

	private var _matrix:Matrix3D;
	private var _matrixDirty:Bool = true;
	private var _texture:Texture;
#if flash
	private var _bitmap:Bitmap;
	private var _buffer:BitmapData;
	private var _bufferRect:Rectangle;
#else
	private static var _vertexBuffer:GLBuffer;
#end

}
