package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import lime.utils.*;

class SpriteBatch
{

	public function new()
	{
		_children = new Array<Image>();
		_indices = new Int16Array(0);
		_vertices = new Float32Array(0);
		_uvs = new Float32Array(0);
	}

	public function add(sprite:Image)
	{
		var id = _children.length;
		_children.push(sprite);

		var index:Int = _vertices.length;
		var i = _indices.length;
		_indices[i++] = index;
		_indices[i++] = index + 1;
		_indices[i++] = index + 2;
		_indices[i++] = index + 1;
		_indices[i++] = index + 2;
		_indices[i++] = index + 3;

		_updateVBOs = true;
	}

	public function remove(sprite:Image)
	{
		_updateVBOs = true;
	}

	public function update()
	{
		if (_children.length == 0) return;

		for (child in _children)
		{
			// updateVertexData(child);
		}
	}

	public function draw(camera:Camera)
	{
		if (_children.length == 0) return;

		_material.use();

		Renderer.setMatrix(_projectionMatrix, camera.transform);

		if (_updateVBOs)
		{
			_indexBuffer = Renderer.updateIndexBuffer(_indices);

			_uvBuffer = Renderer.updateBuffer(_uvs);
			Renderer.setAttribute(_uvAttribute, 0, 2, 2);

			_vertexBuffer = Renderer.updateBuffer(_vertices, DYNAMIC_DRAW);
			_updateVBOs = false;
		}
		else
		{
			Renderer.bindBuffer(_uvBuffer);
			Renderer.setAttribute(_uvAttribute, 0, 2, 2);

			Renderer.updateBuffer(_vertices, _vertexBuffer);
		}

		// vertex buffer should already be bound
		Renderer.setAttribute(_vertexAttribute, 0, 3, 3);

		Renderer.draw(_indexBuffer, Std.int(_indices.length / 3));
	}

	private var _indices:Int16Array;
	private var _vertices:Float32Array;
	private var _uvs:Float32Array;

	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _uvBuffer:VertexBuffer;
	private var _updateVBOs:Bool = true;

	private var _material:Material;
	private var _projectionMatrix:Location;
	private var _vertexAttribute:Int;
	private var _uvAttribute:Int;

	private var _children:Array<Image>;

}
