package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Vector3D;
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

		initBuffer();
	}

	private function initBuffer():Void
	{
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
	}

	public function centerOrigin():Void
	{
		_texture.onload = function() {
			originX = -(_texture.width / 2);
			originY = -(_texture.height / 2);
			_matrixDirty = true;
		}
	}

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
			GL.drawArrays(GL.TRIANGLE_STRIP, offset, 4);
			material.disable();
			GL.bindBuffer(GL.ARRAY_BUFFER, null);
		}
	}

	public function draw(projectionMatrix:Float32Array, modelViewMatrix:Matrix3D):Void
	{
		drawBuffer(projectionMatrix, modelViewMatrix, _vertexBuffer);
	}

	private var _matrix:Matrix3D;
	private var _matrixDirty:Bool = true;
	private var _texture:Texture;
	private static var _vertexBuffer:GLBuffer;

}
