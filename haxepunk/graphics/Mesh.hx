package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
#if lime_html5
import js.html.Int16Array;
#else
import lime.utils.Int16Array;
#end
import lime.utils.Float32Array;
import lime.utils.Matrix3D;

class Mesh implements Graphic
{

	/**
	 * The mesh's material
	 */
	public var material:Material;

	/**
	 * Create a new mesh
	 * @param data An array of data containing the following for each index <vertex x, y, z> <texCoord u, v> <normal x, y, z>
	 * @param indices An array referencing the vertex, textCoord, and normal
	 * @param material The material to apply to this mesh
	 */
	public function new(?data:Array<Float>, ?indices:Array<Int>, ?material:Material)
	{
		this.material = (material == null ? new Material() : material);

		// check that the buffers aren't already loaded from a super class
		if (_vertexBuffer == null) createBuffer(data);
		if (_indexBuffer == null) createIndexBuffer(indices);
	}

	/**
	 * Draw the mesh
	 * @param projectionMatrix The projection matrix to apply
	 * @param modelViewMatrix The model view matrix to apply
	 */
	public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		material.use(projectionMatrix, modelViewMatrix);

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
		GL.drawElements(GL.TRIANGLES, _indexSize, GL.UNSIGNED_SHORT, 0);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);

		material.disable();
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	private function createBuffer(data:Array<Float>):GLBuffer
	{
		if (data == null) throw "Vertex data buffer must not be null";
		_vertexBuffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, _vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		return _vertexBuffer;
	}

	private function createIndexBuffer(indices:Array<Int>):GLBuffer
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
