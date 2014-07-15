package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import haxepunk.math.*;
import lime.utils.*;

class SpriteBatch
{

	public function new(texture:Texture)
	{
		_indices = new Array<Int>();
		_vertices = new Array<Float>();
		_texture = texture;
	}

	public function begin()
	{

	}

	public function add(atlas:TextureAtlas, position:Vector3, id:Int)
	{
		var region = atlas.getRegion(id);

		var index = _numTriangles * 10;
		for (i in 0...Std.int(region.length/2))
		{
			var s = region[i*2];
			var t = region[i*2+1];
			_vertices[index++] = position.x + s * atlas.width;
			_vertices[index++] = position.y + t * atlas.height;
			_vertices[index++] = position.z;
			_vertices[index++] = s;
			_vertices[index++] = t;
		}

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

	public function draw(camera:Camera)
	{
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

}
