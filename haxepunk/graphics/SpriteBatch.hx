package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import haxepunk.math.*;

private class Batch
{
	public var material:Material;

	public function new(material:Material)
	{
		_indices = new IntArray();
		_vertices = new FloatArray();
		_uvs = new FloatArray();

		var pass = material.firstPass;
		var texture = pass.getTexture(0);
		if (Std.is(texture, TextureAtlas))
		{
			_atlas = cast texture;
		}
		else
		{
			updateTexCoord(0);
		}

		this.material = material;

		_modelViewMatrixUniform = pass.shader.uniform("uMatrix");
		_vertexAttribute = pass.shader.attribute("aVertexPosition");
		_uvAttribute = pass.shader.attribute("aTexCoord");

		_uvBuffer = Renderer.createBuffer(2);
		_vertexBuffer = Renderer.createBuffer(3);
		_position = new Vector3(); // temporary vector for calculating vertex positions
	}

	public inline function clear()
	{
		_spriteIndex = 0;
	}

	public function updateTexCoord(index:Int)
	{
		if (_atlas == null)
		{
			index = _spriteIndex * 8;
			_uvs[index++] = 0;
			_uvs[index++] = 0;
			_uvs[index++] = 1;
			_uvs[index++] = 0;
			_uvs[index++] = 0;
			_uvs[index++] = 1;
			_uvs[index++] = 1;
			_uvs[index++] = 1;
		}
		else
		{
			_atlas.copyRegionInto(index, _uvs, _spriteIndex);
		}

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

	public function updateVertex(matrix:Matrix4)
	{
		var index = _spriteIndex * 3 * 4;

		_position.x = _position.y = _position.z = 0;
		_position *= matrix;
		_vertices[index++] = _position.x;
		_vertices[index++] = _position.y;
		_vertices[index++] = _position.z;

		_position.x = 1;
		_position.z = _position.y = 0;
		_position *= matrix;
		_vertices[index++] = _position.x;
		_vertices[index++] = _position.y;
		_vertices[index++] = _position.z;

		_position.y = 1;
		_position.z = _position.x = 0;
		_position *= matrix;
		_vertices[index++] = _position.x;
		_vertices[index++] = _position.y;
		_vertices[index++] = _position.z;

		_position.x = _position.y = 1;
		_position.z = 0;
		_position *= matrix;
		_vertices[index++] = _position.x;
		_vertices[index++] = _position.y;
		_vertices[index++] = _position.z;

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
				_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);

			Renderer.bindBuffer(_uvBuffer);
			Renderer.setAttribute(_uvAttribute, 0, 2);
			Renderer.updateBuffer(_uvs, STATIC_DRAW);
			#if flash
			Renderer.setAttribute(_uvAttribute, 0, 2);
			#end

			_updateVBOs = false;
		}
		else
		{
			Renderer.bindBuffer(_uvBuffer);
			Renderer.setAttribute(_uvAttribute, 0, 2);
		}

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.updateBuffer(_vertices, DYNAMIC_DRAW);
		#if flash
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		#end

		Renderer.draw(_indexBuffer, _spriteIndex * 2);
		_lastSpriteIndex = _spriteIndex;
	}

	private var _indices:IntArray;
	private var _vertices:FloatArray;
	private var _uvs:FloatArray;
	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _uvBuffer:VertexBuffer;
	private var _modelViewMatrixUniform:Location;

	private var _vertexAttribute:Int;
	private var _uvAttribute:Int;
	private var _updateVBOs:Bool = true;
	private var _spriteIndex:Int = 0;
	private var _lastSpriteIndex:Int = 0;
	private var _atlas:TextureAtlas;

	private var _position:Vector3;

}

class SpriteBatch
{

	public var drawCount(default, null) = 0;

	public function new()
	{
		_drawList = new Array<Batch>();
	}

	public function draw(material:Material, matrix:Matrix4, id:Int = -1)
	{
		var batch:Batch;
		if (drawCount > 0)
		{
			batch = _drawList[drawCount - 1];
			if (batch.material != material)
			{
				batch = new Batch(material);
				_drawList[drawCount++] = batch;
			}
		}
		else
		{
			batch = new Batch(material);
			_drawList[drawCount++] = batch;
		}
		if (id != -1) batch.updateTexCoord(id);
		batch.updateVertex(matrix);
	}

	public function flush(camera:Camera)
	{
		for (i in 0...drawCount)
		{
			_drawList[i].draw(camera);
		}
		drawCount = 0;
	}

	private var _drawList:Array<Batch>;

}
