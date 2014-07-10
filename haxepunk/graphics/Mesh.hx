package haxepunk.graphics;

import lime.utils.Int16Array;
import lime.utils.Float32Array;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;
import haxepunk.renderers.Renderer;

class Mesh implements Graphic
{

	/**
	 * The mesh's material
	 */
	public var material:Material;

	public var transform:Matrix4;

	/**
	 * Create a new mesh
	 * @param data An array of data containing the following for each index <vertex x, y, z> <texCoord u, v> <normal x, y, z>
	 * @param indices An array referencing the vertex, textCoord, and normal
	 * @param material The material to apply to this mesh
	 */
	public function new(?material:Material)
	{
		transform = new Matrix4();
		this.material = (material == null ? new Material() : material);

		// check that the buffers aren't already loaded from a super class
		// if (_vertexBuffer == null) createBuffer(data);
		// if (_indexBuffer == null) createIndexBuffer(indices);
	}

	public function update(elapsed:Float):Void {}

	/**
	 * Draw the mesh
	 * @param projectionMatrix The projection matrix to apply
	 * @param modelViewMatrix The model view matrix to apply
	 */
	public function draw(camera:Camera, offset:Vector3):Void
	{
		transform.translateVector3(offset);

		Renderer.bindBuffer(_vertexBuffer);
		material.use(camera.transform, transform);
		Renderer.draw(_indexBuffer, _numTriangles);

		// Renderer.bindIndexBuffer(null);
		// material.disable();
		// Renderer.bindBuffer(null);
	}

	public function createBuffer(data:Array<Float>):VertexBuffer
	{
		if (data == null) throw "Vertex data buffer must not be null";
		return _vertexBuffer = Renderer.createBuffer(new Float32Array(cast data));
	}

	public function createIndexBuffer(data:Array<Int>):IndexBuffer
	{
		if (data == null) throw "Index buffer must not be null";
		_numTriangles = Std.int(data.length / 3);
		return _indexBuffer = Renderer.createIndexBuffer(new Int16Array(cast data));
	}

	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _numTriangles:Int = 0;

}
