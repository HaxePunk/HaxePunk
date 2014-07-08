package haxepunk.graphics;

import haxepunk.graphics.Mesh;
import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;
import haxepunk.renderers.Renderer;

class Shape extends Mesh
{

	public static function createCube(?material:Material)
	{
		var cube = new Shape(material);

		if (cubeVertexBuffer == null)
		{
			cubeVertexBuffer = cube.createBuffer([
				 0.5,  0.5, -0.5, 0.00, 0.00,  0,  0, -1,
				 0.5, -0.5, -0.5, 0.00, 1.00,  0,  0, -1,
				-0.5, -0.5, -0.5, 1.00, 1.00,  0,  0, -1,
				-0.5,  0.5, -0.5, 1.00, 0.00,  0,  0, -1,

				-0.5, -0.5,  0.5, 0.00, 0.00, -1,  0,  0,
				-0.5,  0.5,  0.5, 0.00, 1.00, -1,  0,  0,
				-0.5,  0.5, -0.5, 1.00, 1.00, -1,  0,  0,
				-0.5, -0.5, -0.5, 1.00, 0.00, -1,  0,  0,

				 0.5, -0.5,  0.5, 1.00, 1.00,  0,  0,  1,
				 0.5,  0.5,  0.5, 0.00, 1.00,  0,  0,  1,
				-0.5, -0.5,  0.5, 1.00, 0.00,  0,  0,  1,
				-0.5,  0.5,  0.5, 0.00, 0.00,  0,  0,  1,

				 0.5, -0.5, -0.5, 1.00, 0.00,  1,  0,  0,
				 0.5,  0.5, -0.5, 1.00, 1.00,  1,  0,  0,
				 0.5, -0.5,  0.5, 0.00, 0.00,  1,  0,  0,
				 0.5,  0.5,  0.5, 0.00, 1.00,  1,  0,  0,

				 0.5,  0.5, -0.5, 1.00, 1.00,  0,  1,  0,
				-0.5,  0.5, -0.5, 1.00, 0.00,  0,  1,  0,
				 0.5,  0.5,  0.5, 0.00, 1.00,  0,  1,  0,
				-0.5,  0.5,  0.5, 0.00, 0.00,  0,  1,  0,

				 0.5, -0.5, -0.5, 0.00, 0.00,  0, -1,  0,
				 0.5, -0.5,  0.5, 0.00, 1.00,  0, -1,  0,
				-0.5, -0.5,  0.5, 1.00, 1.00,  0, -1,  0,
				-0.5, -0.5, -0.5, 1.00, 0.00,  0, -1,  0
			]);
		}
		else
		{
			cube._vertexBuffer = cubeVertexBuffer;
		}

		if (cubeIndexBuffer == null)
		{
			cubeIndexBuffer = cube.createIndexBuffer([
				 0,  1,  2,   0,  2,  3,
				 4,  5,  6,   4,  6,  7,
				 8,  9, 10,   9, 11, 10,
				12, 13, 14,  13, 15, 14,
				16, 17, 18,  17, 19, 18,
				20, 21, 22,  20, 22, 23
			]);
		}
		else
		{
			cube._indexBuffer = cubeIndexBuffer;
			cube._numTriangles = 12;
		}

		return cube;
	}

	private static var cubeVertexBuffer:VertexBuffer;
	private static var cubeIndexBuffer:IndexBuffer;

}
