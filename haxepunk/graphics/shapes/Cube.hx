package haxepunk.graphics.shapes;

import haxepunk.graphics.Mesh;
import lime.gl.GLBuffer;

class Cube extends Mesh
{
	public function new()
	{
		createBuffers(); // create or reuse buffers
		_vertexBuffer = defaultVertexBuffer;
		_indexBuffer = defaultIndexBuffer;
		_indexSize = 36;
		super();
	}

	private inline function createBuffers()
	{
		// point, tex, normal
		if (defaultVertexBuffer == null)
		{
			defaultVertexBuffer = createBuffer([
				 1,  1, -1, 0.00, 0.00,  0,  0, -1,
				 1, -1, -1, 0.00, 1.00,  0,  0, -1,
				-1, -1, -1, 1.00, 1.00,  0,  0, -1,
				-1,  1, -1, 1.00, 0.00,  0,  0, -1,

				-1, -1,  1, 0.00, 0.00, -1,  0,  0,
				-1,  1,  1, 0.00, 1.00, -1,  0,  0,
				-1,  1, -1, 1.00, 1.00, -1,  0,  0,
				-1, -1, -1, 1.00, 0.00, -1,  0,  0,

				 1, -1,  1, 1.00, 1.00,  0,  0,  1,
				 1,  1,  1, 0.00, 1.00,  0,  0,  1,
				-1, -1,  1, 1.00, 0.00,  0,  0,  1,
				-1,  1,  1, 0.00, 0.00,  0,  0,  1,

				 1, -1, -1, 1.00, 0.00,  1,  0,  0,
				 1,  1, -1, 1.00, 1.00,  1,  0,  0,
				 1, -1,  1, 0.00, 0.00,  1,  0,  0,
				 1,  1,  1, 0.00, 1.00,  1,  0,  0,

				 1,  1, -1, 1.00, 1.00,  0,  1,  0,
				-1,  1, -1, 1.00, 0.00,  0,  1,  0,
				 1,  1,  1, 0.00, 1.00,  0,  1,  0,
				-1,  1,  1, 0.00, 0.00,  0,  1,  0,

				 1, -1, -1, 0.00, 0.00,  0, -1,  0,
				 1, -1,  1, 0.00, 1.00,  0, -1,  0,
				-1, -1,  1, 1.00, 1.00,  0, -1,  0,
				-1, -1, -1, 1.00, 0.00,  0, -1,  0
			]);
		}
		if (defaultIndexBuffer == null)
		{
			defaultIndexBuffer = createIndexBuffer([
				 0,  1,  2,   0,  2,  3,
				 4,  5,  6,   4,  6,  7,
				 8,  9, 10,   9, 11, 10,
				12, 13, 14,  13, 15, 14,
				16, 17, 18,  17, 19, 18,
				20, 21, 22,  20, 22, 23
			]);
		}
	}

	private static var defaultVertexBuffer:GLBuffer;
	private static var defaultIndexBuffer:GLBuffer;
}
