package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Vector3D;
import lime.utils.Matrix3D;

class Image implements Graphic
{

	public var material:Material;

	public var angle:Float = 0;

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
				 1,  1, 0, 1.00, 0.00, 0, 0, -1,
				 1, -1, 0, 1.00, 1.00, 0, 0, -1,
				-1,  1, 0, 0.00, 0.00, 0, 0, -1,
				-1, -1, 0, 0.00, 1.00, 0, 0, -1
			];
			_vertexBuffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		}
	}

	public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		modelViewMatrix.appendScale(_texture.width, _texture.height, 1);
		modelViewMatrix.appendRotation(-angle, Vector3D.Z_AXIS);

		material.use(projectionMatrix, modelViewMatrix);

		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

		material.disable();
	}

	private var _texture:Texture;
	private static var _vertexBuffer:GLBuffer;

}
