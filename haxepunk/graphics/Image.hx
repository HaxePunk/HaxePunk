package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Matrix3D;

class Image implements Graphic
{

	public var material:Material;

	public function new(name:String)
	{
		var texture = new Texture(name);
		material = new Material();
		material.addTexture(texture);

		initBuffer();
	}

	private inline function initBuffer():Void
	{
		if (_vertexBuffer == null)
		{
			var data = [
				/* vertex | tex coord | normal */
				 1,  1, 0, 0.00, 0.00, 0, 0, -1,
				 1, -1, 0, 0.00, 1.00, 0, 0, -1,
				-1,  1, 0, 1.00, 0.00, 0, 0, -1,
				-1, -1, 0, 1.00, 1.00, 0, 0, -1
			];
			_vertexBuffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		}
	}

	public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		material.use(projectionMatrix, modelViewMatrix);

		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

		material.disable();
	}

	private static var _vertexBuffer:GLBuffer;

}
