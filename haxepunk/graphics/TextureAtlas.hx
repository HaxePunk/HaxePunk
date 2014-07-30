package haxepunk.graphics;

import lime.utils.Float32Array;
import haxepunk.renderers.Renderer;

class TextureAtlas extends Texture
{

	public function new(image:lime.media.Image)
	{
		super();
#if !unit_test
		loadFromImage(image);
#end
		_index = new Array<Int>();
		_uvs = new FloatArray();
	}

	public function copyRegionInto(id:Int, into:FloatArray, offset:Int=0):Void
	{
		// #if cpp
		// cpp.NativeArray.blit(into, offset * 8, _uvs, id * 8, 8);
		// #else
		var index = _index[id];
		var end = index + 8;
		offset = offset * 8;
		while (index < end)
		{
			into[offset++] = _uvs[index++];
		}
		// #end
	}

	public function generateTiles(width:Int, height:Int):Array<Int>
	{
		var tiles = new Array<Int>();
		var x = 0, y = 0;
		while (y + height <= sourceHeight)
		{
			if (x + width > sourceWidth)
			{
				x = 0;
				y += height;
				if (y + height > sourceHeight)
				{
					break;
				}
			}

			tiles.push(addTile(x, y, width, height));
			x += width;
		}
		return tiles;
	}

	public function addTile(x:Int, y:Int, width:Int, height:Int):Int
	{
		var left   = x / sourceWidth,
			top    = y / sourceHeight,
			right  = (x + width) / sourceWidth,
			bottom = (y + height) / sourceHeight;

		return insertPoints([left, top, right, top, left, bottom, right, bottom]);
	}

	public function addQuad(points:Array<Float>):Int
	{
		if (points.length != 8) return -1;

		for (i in 0...4)
		{
			points[i*2] /= width;
			points[i*2+1] /= height;
		}

		return insertPoints(points);
	}

	private function insertPoints(points:Array<Float>):Int
	{
		var u = 0;

		var len = points.length;

		// search for the points in the _uvs array
		while (u < _uvs.length)
		{
			var found = true;
			for (i in 0...len)
			{
				if (_uvs[u + i] != points[i])
				{
					found = false;
				}
			}

			if (found)
			{
				return Std.int(u / len);
			}
			u += len;
		}

		_index.push(u);

		for (i in 0...len)
		{
			_uvs[u++] = points[i];
		}

		return _index.length - 1;
	}

	private var _index:Array<Int>;
	private var _uvs:FloatArray;

}
