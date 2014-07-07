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
import haxepunk.scene.Camera;

class Image implements Graphic
{

	public var material:Material;

	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the image.
	 */
	public var scale:Vector3D;

	/**
	 * Origin of the image.
	 */
	public var origin:Vector3D;

	/**
	 * Flip image on the x-axis
	 * NOTE: This changes the image's scale value. By modifying scale.x you may unintentionally update flippedX.
	 */
	public var flippedX(get, set):Bool;
	private inline function get_flippedX():Bool { return scale.x < 0; }
	private function set_flippedX(value:Bool):Bool {
		scale.x = Math.abs(scale.x) * (value ? -1 : 1);
		return value;
	}

	/**
	 * Flip image on the y-axis
	 * NOTE: This changes the image's scale value. By modifying scale.y you may unintentionally update flippedY.
	 */
	public var flippedY(get, set):Bool;
	private inline function get_flippedY():Bool { return scale.y < 0; }
	private function set_flippedY(value:Bool):Bool {
		scale.y = Math.abs(scale.y) * (value ? -1 : 1);
		return value;
	}

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

	public function new(id:String)
	{
		scale = new Vector3D(1, 1, 1);
		origin = new Vector3D();
		_matrix = new Matrix3D();

#if !unit_test
		_texture = Texture.create(id);
		material = new Material();
		material.addTexture(_texture);

		createBuffer();
#end
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
		origin.x = -(width / 2);
		origin.y = -(height / 2);
	}

	#if !flash
	private inline function drawBuffer(camera:Camera, offset:Vector3D, buffer:GLBuffer, tileOffset:Int=0):Void
	{
		if (buffer != null)
		{
			origin *= scale;
			origin += offset;

			_matrix.identity();
			_matrix.scale(width, height, 1);
			_matrix.translateVector3D(origin);
			_matrix.scaleVector3D(scale);
			if (angle != 0) _matrix.rotateZ(angle);

			origin -= offset;
			origin /= scale;

			GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
			material.use(camera.transform.float32Array, _matrix.float32Array);
			GL.drawArrays(GL.TRIANGLE_STRIP, tileOffset << 2, 4);
		}
	}
	#end

	public function draw(camera:Camera, offset:Vector3D):Void
	{
		switch (HXP.context)
		{
			case OPENGL(gl):
			#if !flash
				drawBuffer(camera, offset, _vertexBuffer);
			#end
			case FLASH(stage):
			#if flash
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
	private var _texture:Texture;
#if flash
	private var _bitmap:Bitmap;
	private var _buffer:BitmapData;
	private var _bufferRect:Rectangle;
#else
	private static var _vertexBuffer:GLBuffer;
#end

}
