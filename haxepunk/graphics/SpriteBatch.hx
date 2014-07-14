package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import haxepunk.math.*;
import lime.utils.*;

interface Sprite
{
	public var position:Vector3;
	public var texRect:Rectangle;
}

class SpriteBatch
{

	public function new(texture:Texture)
	{
		_indices = new Array<Int>();
		_vertices = new Array<Float>();
		_texture = texture;
	}

	public function add(sprite:Sprite)
	{
		_children.push(sprite);
		updateVertex(sprite);

		_updateVBOs = true;
	}

	public function remove(sprite:Sprite)
	{
		_updateVBOs = true;
	}

	private function updateVertex(child:Sprite)
	{
		var texRect = child.texRect;
		var pos = child.position;

		var left   = texRect.x / _texture.width;
		var top    = texRect.y / _texture.height;
		var right  = left + texRect.width / _texture.width;
		var bottom = top + texRect.height / _texture.height;

		var index = _numTriangles * 10;
		_vertices[index++] = pos.x;
		_vertices[index++] = pos.y;
		_vertices[index++] = pos.z;
		_vertices[index++] = left;
		_vertices[index++] = top;

		_vertices[index++] = pos.x;
		_vertices[index++] = pos.y + texRect.height;
		_vertices[index++] = pos.z;
		_vertices[index++] = left;
		_vertices[index++] = bottom;

		_vertices[index++] = pos.x + texRect.width;
		_vertices[index++] = pos.y;
		_vertices[index++] = pos.z;
		_vertices[index++] = right;
		_vertices[index++] = top;

		_vertices[index++] = pos.x + texRect.width;
		_vertices[index++] = pos.y + texRect.height;
		_vertices[index++] = pos.z;
		_vertices[index++] = right;
		_vertices[index++] = bottom;

		index = _numTriangles * 3;
		var i:Int = _vertices.length;
		_indices[index++] = i;
		_indices[index++] = i + 1;
		_indices[index++] = i + 2;

		_indices[index++] = i + 1;
		_indices[index++] = i + 2;
		_indices[index++] = i + 3;

		_numTriangles += 2;
	}

	public function update()
	{
		if (_children.length == 0) return;

		_numTriangles = 0;

		for (child in _children)
		{
			updateVertex(child);
		}
	}

	public function draw(camera:Camera)
	{
		if (_children.length == 0) return;

		Renderer.setMatrix(_matrixUniform, camera.transform);

		if (_updateVBOs)
		{
			Renderer.updateIndexBuffer(new Int16Array(_indices), STATIC_DRAW, _indexBuffer);
			Renderer.updateBuffer(new Float32Array(_vertices), 5, DYNAMIC_DRAW, _vertexBuffer);
			_updateVBOs = false;
		}

		// vertex buffer should already be bound
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.setAttribute(_uvAttribute, 3, 2);

		Renderer.draw(_indexBuffer, _numTriangles);
	}

	private var _indices:Array<Int>;
	private var _vertices:Array<Float>;
	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _updateVBOs:Bool = true;

	private var _texture:Texture;
	private var _matrixUniform:Location;
	private var _vertexAttribute:Int;
	private var _uvAttribute:Int;
	private var _numTriangles:Int = 0;

	private var _children:Array<Sprite>;

}
