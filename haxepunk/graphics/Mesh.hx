package haxepunk.graphics;

import lime.graphics.GL;
import lime.graphics.GLBuffer;
import lime.utils.Int16Array;
import lime.utils.Float32Array;
import haxepunk.math.Vector3D;
import haxepunk.math.Matrix3D;
import haxepunk.scene.Camera;

class Mesh implements Graphic
{

	/**
	 * The mesh's material
	 */
	public var material:Material;

	public var transform:Matrix3D;

	/**
	 * Create a new mesh
	 * @param data An array of data containing the following for each index <vertex x, y, z> <texCoord u, v> <normal x, y, z>
	 * @param indices An array referencing the vertex, textCoord, and normal
	 * @param material The material to apply to this mesh
	 */
	public function new(?material:Material)
	{
		transform = new Matrix3D();
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
	public function draw(camera:Camera, offset:Vector3D):Void
	{
		transform.translateVector3D(offset);

		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		material.use(camera.transform.float32Array, transform.float32Array);

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
		GL.drawElements(GL.TRIANGLES, _indexSize, GL.UNSIGNED_SHORT, 0);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

		material.disable();
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function createBuffer(data:Array<Float>):GLBuffer
	{
		if (data == null) throw "Vertex data buffer must not be null";
		_vertexBuffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		return _vertexBuffer;
	}

	public function createIndexBuffer(indices:Array<Int>):GLBuffer
	{
		if (indices == null) throw "Index buffer must not be null";
		_indexSize = indices.length;
		_indexBuffer = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(cast indices), GL.STATIC_DRAW);
		return _indexBuffer;
	}

	private var _indexBuffer:GLBuffer;
	private var _vertexBuffer:GLBuffer;
	private var _indexSize:Int = 0;

}
