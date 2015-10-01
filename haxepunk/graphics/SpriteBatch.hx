package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;

class SpriteBatch
{

	public static var material(get, set):Material;
	private static function get_material():Material
	{
		// always make sure we return a valid material
		if (_material == null)
		{
			_material = new Material();
			_material.firstPass;
		}
		return _material;
	}
	private static function set_material(value:Material):Material
	{
		if (value != _material)
		{
			flush();
			if (value != null)
			{
				var tex = value.firstPass.getTexture(0);
				if (tex != null)
				{
					_invTexWidth = 1 / tex.width;
					_invTexHeight = 1 / tex.height;
				}
			}
		}
		return _material = value;
	}

	/**
	 * Adds a sprite to be drawn. Sprites are batched by material to reduce the number of draw calls.
	 * @param material the Material to be used (includes shader and texture passes)
	 * @param x the sprite's x-axis value
	 * @param y the sprite's y-axis value
	 * @param width the sprite's width
	 * @param height the sprite's height
	 * @param texX the sprite's uv rect x value
	 * @param texY the sprite's uv rect y value
	 * @param texWidth the sprite's uv rect width value
	 * @param texHeight the sprite's uv rect height value
	 * @param flipX flips sprite's uv coordinates on x-axis
	 * @param flipY flips sprite's uv coordinates on y-axis
	 * @param originX the sprite's x-axis anchor point for rotation
	 * @param originY the sprite's y-axis anchor point for rotation
	 * @param scaleX the sprite's x-axis scale value
	 * @param scaleY the sprite's y-axis scale value
	 * @param angle the sprite's rotation in radians
	 * @param tint the sprite's tint color
	 */
	public static function draw(material:Material, x:Float, y:Float, width:Float, height:Float,
		texX:Float, texY:Float, texWidth:Float, texHeight:Float, flipX:Bool=false, flipY:Bool=false,
		originX:Float=0, originY:Float=0, scaleX:Float=1, scaleY:Float=1, angle:Float=0, ?tint:Color):Void
	{
		SpriteBatch.material = material;

		var worldOriginX = x + originX;
		var worldOriginY = y + originY;

		var fx1 = -originX;
		var fy1 = -originY;
		var fx2 = width - originX;
		var fy2 = height - originY;

		if (scaleX != 1 || scaleY != 1)
		{
			fx1 *= scaleX;
			fy1 *= scaleY;
			fx2 *= scaleX;
			fy2 *= scaleY;
		}

		var x1 = fx1, y1 = fy1,
			x2 = fx1, y2 = fy2,
			x3 = fx2, y3 = fy2,
			x4 = fx2, y4 = fy1;

		if (angle != 0)
		{
			var cos = Math.cos(angle);
			var sin = Math.sin(angle);

			var tmp = x1;
			x1 = cos * tmp - sin * y1;
			y1 = sin * tmp + cos * y1;

			tmp = x2;
			x2 = cos * tmp - sin * y2;
			y2 = sin * tmp + cos * y2;

			tmp = x3;
			x3 = cos * tmp - sin * y3;
			y3 = sin * tmp + cos * y3;

			x4 = x1 + (x3 - x2);
			y4 = y3 - (y2 - y1);
		}

		x1 += worldOriginX; y1 += worldOriginY;
		x2 += worldOriginX; y2 += worldOriginY;
		x3 += worldOriginX; y3 += worldOriginY;
		x4 += worldOriginX; y4 += worldOriginY;

		var u1, u2;
		if (flipX)
		{
			u1 = (texX + texWidth) * _invTexWidth;
			u2 = texX * _invTexWidth;
		}
		else
		{
			u1 = texX * _invTexWidth;
			u2 = (texX + texWidth) * _invTexWidth;
		}

		var v1, v2;
		if (flipY)
		{
			v1 = (texY + texHeight) * _invTexHeight;
			v2 = texY * _invTexHeight;
		}
		else
		{
			v1 = texY * _invTexHeight;
			v2 = (texY + texHeight) * _invTexHeight;
		}

		var r, g, b, a;
		if (tint != null)
		{
			r = tint.r;
			g = tint.g;
			b = tint.b;
			a = tint.a;
		}
		else
		{
			r = g = b = a = 0;
		}

		addRectIndices();
		addVertex(x1, y1, u1, v1, r, g, b, a);
		addVertex(x2, y2, u1, v2, r, g, b, a);
		addVertex(x3, y3, u2, v2, r, g, b, a);
		addVertex(x4, y4, u2, v1, r, g, b, a);
	}

	inline private static function addRectIndices()
	{
		_indices[_iIndex++] = _index;
		_indices[_iIndex++] = _index+1;
		_indices[_iIndex++] = _index+2;

		_indices[_iIndex++] = _index;
		_indices[_iIndex++] = _index+2;
		_indices[_iIndex++] = _index+3;
		_index += 4;
	}

	inline private static function addVertex(x:Float=0, y:Float=0, u:Float=0, v:Float=0, r:Float=1, g:Float=1, b:Float=1, a:Float=1):Void
	{
		_vertices[_vIndex++] = x;
		_vertices[_vIndex++] = y;
		_vertices[_vIndex++] = u;
		_vertices[_vIndex++] = v;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;
		_vertices[_vIndex++] = a;
	}

	/**
	 * Flushes the last batch of sprites.
	 */
	public static function flush():Void
	{
		if (_index == 0) return;

		// update buffers
		if (_vertexBuffer == null)
		{
			_vertexBuffer = Renderer.createBuffer(8);
		}
		Renderer.bindBuffer(_vertexBuffer);
		Renderer.updateBuffer(_vertices, STATIC_DRAW);

		_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);

		// grab the camera transform
		var cameraTransform = HXP.scene.camera.transform;
		var numIndices = Std.int(_iIndex / 3);

		// loop material passes
		for (pass in material.passes)
		{
			pass.use();
			Renderer.setMatrix(pass.shader.uniform("uMatrix"), cameraTransform);
			Renderer.setAttribute(pass.shader.attribute("aVertexPosition"), 0, 2);
			Renderer.setAttribute(pass.shader.attribute("aTexCoord"), 2, 2);
			Renderer.setAttribute(pass.shader.attribute("aColor"), 4, 4);
			Renderer.draw(_indexBuffer, numIndices);
		}

		_vIndex = _iIndex = _index = 0;
	}

	private static var _index:Int = 0;
	private static var _iIndex:Int = 0;
	private static var _vIndex:Int = 0;

	private static var _vertices:FloatArray = new FloatArray();
	private static var _indices:IntArray = new IntArray();
	private static var _vertexBuffer:VertexBuffer;
	private static var _indexBuffer:IndexBuffer;
	private static var _invTexWidth:Float = 0;
	private static var _invTexHeight:Float = 0;
	private static var _material:Material;

}
