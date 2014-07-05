package haxepunk.graphics;

import lime.graphics.GL;
import lime.graphics.GLBuffer;
import lime.utils.Float32Array;

class TextureAtlas
{

	public function new(texture:Texture)
	{
		_regions = new Array<Array<Int>>();
		_texCoords = new Array<Float>();
		_texture = texture;
	}

	public function bind():Void
	{
		_texture.bind();
		if (_buffer == null) _buffer = GL.createBuffer();
		if (_dirty)
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast _texCoords), GL.STATIC_DRAW);
		}
	}

	public function addTile(x:Int, y:Int, width:Int, height:Int):Int
	{
		var id = _regions.length,
			t = _texCoords.length;

		// indices for quad as a triangle strip (0, 1, 2, 3)
		var i = Std.int(t / 2);
		_regions[id] = [i, i+1, i+2, i+3];

		var left   = x / _texture.originalWidth,
			top    = y / _texture.originalHeight,
			right  = (x + width) / _texture.originalWidth,
			bottom = (y + height) / _texture.originalHeight;

		_texCoords[t++] = left;
		_texCoords[t++] = top;
		_texCoords[t++] = right;
		_texCoords[t++] = top;
		_texCoords[t++] = left;
		_texCoords[t++] = bottom;
		_texCoords[t++] = right;
		_texCoords[t++] = bottom;

		_dirty = true;
		return id;
	}

	public function addRegion(points:Array<Int>):Int
	{
		var indexCount:Int = Std.int(points.length / 2);
		// check for invalid regions
		if (points.length % 2 == 1 || indexCount < 3)
		{
			return -1;
		}

		var id = _regions.length,
			t = _texCoords.length;

		var index = Std.int(t / 2);
		var indices = new Array<Int>();
		for (i in 0...indexCount)
		{
			_texCoords[t++] = points[i*2] / _texture.width;
			_texCoords[t++] = points[i*2+1] / _texture.height;

			indices.push(index++);
		}

		_regions[id] = indices;

		_dirty = true;
		return id;
	}

	public function draw(region:Int, x:Float, y:Float):Void
	{
		if (region >= _regions.length) return;
		var r = _regions[region];
	}

	private var _regions:Array<Array<Int>>;
	private var _texCoords:Array<Float>;
	private var _dirty:Bool = false;
	private var _texture:Texture;
	private var _buffer:GLBuffer;

}
