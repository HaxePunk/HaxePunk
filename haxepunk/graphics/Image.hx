package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Vector3D;
import lime.utils.Matrix3D;

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

	public var width(get, never):Float;
	private inline function get_width():Float { return _texture.width; }

	public var height(get, never):Float;
	private inline function get_height():Float { return _texture.height; }

	public function new(name:String)
	{
		_texture = new Texture(name);
		material = new Material();
		material.addTexture(_texture);

		initBuffer();
	}

	private inline function initBuffer():Void
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
		}
	}

	public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		modelViewMatrix.prependRotation(angle, Vector3D.Z_AXIS);
		modelViewMatrix.prependScale(scale * scaleX, scale * scaleY, 1);
		modelViewMatrix.prependTranslation(originX, originY, 0);
		modelViewMatrix.prependScale(_texture.width, _texture.height, 1);

		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		material.use(projectionMatrix, modelViewMatrix);
		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		material.disable();
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	private var _texture:Texture;
	private static var _vertexBuffer:GLBuffer;

}
