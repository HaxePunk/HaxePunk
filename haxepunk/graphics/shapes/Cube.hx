package haxepunk.graphics.shapes;

import haxepunk.graphics.Mesh;
import lime.gl.GLBuffer;
import lime.utils.Matrix3D;
import lime.utils.Vector3D;

class Cube extends Mesh
{

	public var scale:Float = 0;
	public var rotation:Vector3D;

	public function new(material:Material)
	{
		rotation = new Vector3D();

		createBuffers(); // create or reuse buffers
		_vertexBuffer = defaultVertexBuffer;
		_indexBuffer = defaultIndexBuffer;
		super(null, null, material);
		_indexSize = 36;
	}

	private inline function createBuffers()
	{
		// point, tex, normal
		if (defaultVertexBuffer == null)
		{
			defaultVertexBuffer = createBuffer([
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

	override public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		modelViewMatrix.prependScale(scale, scale, scale);
		modelViewMatrix.prependRotation(rotation.z, Vector3D.Z_AXIS);
		modelViewMatrix.prependRotation(rotation.y, Vector3D.Y_AXIS);
		modelViewMatrix.prependRotation(rotation.x, Vector3D.X_AXIS);
		super.draw(projectionMatrix, modelViewMatrix);
	}

	private static var defaultVertexBuffer:GLBuffer;
	private static var defaultIndexBuffer:GLBuffer;
}
