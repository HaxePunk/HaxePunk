package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.scene.Scene;

class SpriteBatch
{

	public function new(scene:Scene)
	{
		_vertices = new FloatArray();
		_indices = new IntArray();

		// TODO: pull scene from HXP?
		_scene = scene;
	}

	public function draw(material:Material, x:Float, y:Float, width:Float, height:Float,
		texX:Float, texY:Float, texWidth:Float, texHeight:Float, flipX:Bool=false, flipY:Bool=false,
		originX:Float=0, originY:Float=0, scaleX:Float=1, scaleY:Float=1, angle:Float=0)
	{
		if (material != _material)
		{
			flush();
			_material = material;
			var tex = material.firstPass.getTexture(0);
			_invTexWidth = 1 / tex.width;
			_invTexHeight = 1 / tex.height;
		}

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

		var index = Std.int(_indexIndex / 6) * 4;
		_indices[_indexIndex++] = index;
		_indices[_indexIndex++] = index+1;
		_indices[_indexIndex++] = index+2;

		_indices[_indexIndex++] = index;
		_indices[_indexIndex++] = index+2;
		_indices[_indexIndex++] = index+3;

		_vertices[_vertexIndex++] = x1;
		_vertices[_vertexIndex++] = y1;
		_vertices[_vertexIndex++] = u1;
		_vertices[_vertexIndex++] = v1;

		_vertices[_vertexIndex++] = x2;
		_vertices[_vertexIndex++] = y2;
		_vertices[_vertexIndex++] = u1;
		_vertices[_vertexIndex++] = v2;

		_vertices[_vertexIndex++] = x3;
		_vertices[_vertexIndex++] = y3;
		_vertices[_vertexIndex++] = u2;
		_vertices[_vertexIndex++] = v2;

		_vertices[_vertexIndex++] = x4;
		_vertices[_vertexIndex++] = y4;
		_vertices[_vertexIndex++] = u2;
		_vertices[_vertexIndex++] = v1;
	}

	public function flush()
	{
		if (_vertexIndex == 0) return;
		_renderCalls++;

		_material.use();

		var pass = _material.firstPass;
		Renderer.setMatrix(pass.shader.uniform("uMatrix"), _scene.camera.transform);

		if (_vertexBuffer == null)
		{
			_vertexBuffer = Renderer.createBuffer(4);
		}
		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(pass.shader.attribute("aVertexPosition"), 0, 2);
		Renderer.setAttribute(pass.shader.attribute("aTexCoord"), 2, 2);
		Renderer.updateBuffer(_vertices, STATIC_DRAW);

		_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);

		Renderer.draw(_indexBuffer, Std.int(_indexIndex / 3));

		_vertexIndex = _indexIndex = 0;
	}

	private var _indexIndex:Int = 0;
	private var _vertexIndex:Int = 0;

	private var _vertices:FloatArray;
	private var _indices:IntArray;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;
	private var _renderCalls:Float = 0;
	private var _invTexWidth:Float = 0;
	private var _invTexHeight:Float = 0;
	private var _material:Material;
	private var _scene:Scene;

}
