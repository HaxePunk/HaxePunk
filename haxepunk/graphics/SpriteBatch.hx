package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import haxepunk.math.*;
import lime.utils.*;

enum BatchType {
	TRIANGLE;
	TRIANGLE_STRIP;
}

private class Batch
{
	public var material:Material;

	public function new(material:Material)
	{
		_indices = new Array<Int>();
		_vertices = new Array<Float>();
		_uvs = new Array<Float>();

		if (!Std.is(material.getTexture(0), TextureAtlas))
		{
			throw "Must be a texture atlas!";
		}

		this.material = material;
		_atlas = cast(material.getTexture(0), TextureAtlas);

		_modelViewMatrixUniform = material.shader.uniform("uMatrix");
		_vertexAttribute = material.shader.attribute("aVertexPosition");
		_uvAttribute = material.shader.attribute("aTexCoord");

		_uvBuffer = Renderer.createBuffer(2);
		_vertexBuffer = Renderer.createBuffer(3);
	}

	public inline function clear()
	{
		_spriteIndex = 0;
	}

	public function updateTexCoord(index:Int)
	{
		_atlas.copyRegionInto(index, _uvs, _spriteIndex);

		#if true
			index = _spriteIndex * 6;
			_indices[index++] = _spriteIndex * 4;
			_indices[index++] = _spriteIndex * 4 + 1;
			_indices[index++] = _spriteIndex * 4 + 2;

			_indices[index++] = _spriteIndex * 4 + 1;
			_indices[index++] = _spriteIndex * 4 + 2;
			_indices[index++] = _spriteIndex * 4 + 3;
		#else
			index = _spriteIndex * 6;
			_indices[index++] = _spriteIndex * 4;
			_indices[index++] = _spriteIndex * 4 + 1;
			_indices[index++] = _spriteIndex * 4 + 2;
			_indices[index++] = _spriteIndex * 4 + 3;
			_indices[index++] = _spriteIndex * 4 + 3;
			_indices[index++] = _spriteIndex * 4 + 4;
		#end

		_updateVBOs = true;
	}

	public function updateVertex(position:Vector3)
	{
		var index = _spriteIndex * 3 * 4;
		var width = 32, height = 32;

		_vertices[index++] = position.x;
		_vertices[index++] = position.y;
		_vertices[index++] = position.z;

		_vertices[index++] = position.x + width;
		_vertices[index++] = position.y;
		_vertices[index++] = position.z;

		_vertices[index++] = position.x;
		_vertices[index++] = position.y + height;
		_vertices[index++] = position.z;

		_vertices[index++] = position.x + width;
		_vertices[index++] = position.y + height;
		_vertices[index++] = position.z;

		_spriteIndex += 1;
	}

	public function draw(camera:Camera)
	{
		if (_indices.length == 0 || _uvs.length == 0) return;

		material.use();

		Renderer.setMatrix(_modelViewMatrixUniform, camera.transform);

		if (_updateVBOs)
		{
			if (_spriteIndex > _lastSpriteIndex)
				_indexBuffer = Renderer.updateIndexBuffer(new Int16Array(_indices), STATIC_DRAW, _indexBuffer);

			Renderer.bindBuffer(_uvBuffer);
			Renderer.setAttribute(_uvAttribute, 0, 2);
			Renderer.updateBuffer(new Float32Array(_uvs), STATIC_DRAW);

			_updateVBOs = false;
		}
		else
		{
			Renderer.bindBuffer(_uvBuffer);
			Renderer.setAttribute(_uvAttribute, 0, 2);
		}

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.updateBuffer(new Float32Array(_vertices), DYNAMIC_DRAW);

		Renderer.draw(_indexBuffer, _spriteIndex * 2);
		_lastSpriteIndex = _spriteIndex;
	}

	private var _indices:Array<Int>;
	private var _vertices:Array<Float>;
	private var _uvs:Array<Float>;
	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _uvBuffer:VertexBuffer;
	private var _modelViewMatrixUniform:Location;

	private var _vertexAttribute:Int;
	private var _uvAttribute:Int;
	private var _updateVBOs:Bool = true;
	private var _spriteIndex:Int;
	private var _lastSpriteIndex:Int = 0;
	private var _atlas:TextureAtlas;

}

class SpriteBatch
{

	public function new()
	{
		_batches = new Map<Material, Batch>();
	}

	public function begin()
	{
		for (batch in _batches)
		{
			batch.clear();
		}
	}

	public function draw(material:Material, position:Vector3, id:Int=-1)
	{
		var batch:Batch;
		if (_batches.exists(material))
		{
			batch = _batches.get(material);
		}
		else
		{
			batch = new Batch(material);
			_batches.set(material, batch);
		}
		if (id != -1) batch.updateTexCoord(id);
		batch.updateVertex(position);

	}

	public function end(camera:Camera)
	{
		for (batch in _batches)
		{
			batch.draw(camera);
		}
	}

	private var _batches:Map<Material, Batch>;

}
