package haxepunk.graphics;

import haxepunk.math.*;
import haxepunk.scene.Camera;
import haxepunk.renderers.Renderer;

class Mesh
{

	/**
	 * Create a new mesh
	 * @param data An array of data containing the following for each index <vertex x, y, z> <texCoord u, v> <normal x, y, z>
	 * @param indices An array referencing the vertex, textCoord, and normal
	 * @param material The material to apply to this mesh
	 */
	public function new()
	{
	}

	/**
	 * Draw the mesh
	 * @param projectionMatrix The projection matrix to apply
	 * @param modelViewMatrix The model view matrix to apply
	 */
	public function draw(vertexAttrib:Int, texCoordAttrib:Int, normalAttrib:Int):Void
	{
		if (_indexBuffer == null) return;

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(vertexAttrib, 0, 3);
		Renderer.setAttribute(texCoordAttrib, 3, 2);
		Renderer.setAttribute(normalAttrib, 5, 3);

		Renderer.draw(_indexBuffer, _numTriangles);
	}

	public function createBuffer(data:FloatArray):VertexBuffer
	{
		if (data == null) throw "Vertex data buffer must not be null";
		_vertexBuffer = Renderer.createBuffer(8);
		Renderer.bindBuffer(_vertexBuffer);
		Renderer.updateBuffer(data);
		return _vertexBuffer;
	}

	public function createIndexBuffer(data:IntArray):IndexBuffer
	{
		if (data == null) throw "Index buffer must not be null";
		_numTriangles = Std.int(data.length / 3);
		return _indexBuffer = Renderer.updateIndexBuffer(data);
	}

	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _numTriangles:Int = 0;

}

class Model implements Graphic
{

	/**
	 * The mesh's material
	 */
	public var material:Material;

	public var transform:Matrix4;
	public var lightPos:Vector3;

	public function new(?material:Material)
	{
		this.material = (material == null ? new Material() : material);

		var shader = material.firstPass.shader;
		_modelViewMatrixUniform = shader.uniform("uMatrix");
		_lightUniform = shader.uniform("uLightPos");
		_vertexAttribute = shader.attribute("aVertexPosition");
		_texCoordAttribute = shader.attribute("aTexCoord");
		_normalAttribute = shader.attribute("aNormal");

		transform = new Matrix4();
		lightPos = new Vector3(1, 1, 1);

		_meshes = new Array<Mesh>();
	}

	public function addMesh(mesh:Mesh):Void
	{
		_meshes.push(mesh);
	}

	public function update(elapsed:Float):Void { }

	public function draw(camera:Camera, offset:Vector3):Void
	{
		material.use();

		Renderer.setVector3(_lightUniform, lightPos);

		transform.identity();
		transform.translateVector3(offset);
		transform.multiply(camera.transform);
		Renderer.setMatrix(_modelViewMatrixUniform, transform);

		for (i in 0..._meshes.length)
		{
			_meshes[i].draw(_vertexAttribute, _texCoordAttribute, _normalAttribute);
		}
	}

	private var _meshes:Array<Mesh>;
	private var _modelViewMatrixUniform:Location;
	private var _lightUniform:Location;
	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;
}
