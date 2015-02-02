package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import lime.graphics.opengl.*;

class Draw
{

	public static function pixel(x:Float, y:Float, color:Color, size:Float=1):Void
	{
		var hs = size / 2;
		fillRect(x - hs, y - hs, size, size, color);
	}

	public static function rect(x:Float, y:Float, width:Float, height:Float, color:Color, thickness:Float=1):Void
	{
		var ht = thickness / 2,
			x2 = x + width,
			y2 = y + height;
		// offset values to create an inline border
		line(x, y + ht, x2, y + ht, color, thickness);
		line(x2 - ht, y, x2 - ht, y2, color, thickness);
		line(x2, y2 - ht, x, y2 - ht, color, thickness);
		line(x + ht, y2, x + ht, y, color, thickness);
	}

	public static function fillRect(x:Float, y:Float, width:Float, height:Float, color:Color):Void
	{
		var r = color.r,
			g = color.g,
			b = color.b;

		_vertices[_vIndex++] = x;
		_vertices[_vIndex++] = y;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x + width;
		_vertices[_vIndex++] = y;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x + width;
		_vertices[_vIndex++] = y + height;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x;
		_vertices[_vIndex++] = y + height;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		addRectIndices();
	}

	public static function line(x1:Float, y1:Float, x2:Float, y2:Float, color:Color, thickness:Float=1):Void
	{
		// create perpendicular delta vector
		var dx = -(x2 - x1);
		var dy = y2 - y1;
		var len = Math.sqrt(dx * dx + dy * dy);
		if (len == 0) return;
		// normalize line and set delta to half thickness
		var ht = thickness / 2;
		var tx = dx;
		dx = (dy / len) * ht;
		dy = (tx / len) * ht;

		var r = color.r,
			g = color.g,
			b = color.b;

		_vertices[_vIndex++] = x1 + dx;
		_vertices[_vIndex++] = y1 + dy;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x1 - dx;
		_vertices[_vIndex++] = y1 - dy;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x2 - dx;
		_vertices[_vIndex++] = y2 - dy;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		_vertices[_vIndex++] = x2 + dx;
		_vertices[_vIndex++] = y2 + dy;
		_vertices[_vIndex++] = r;
		_vertices[_vIndex++] = g;
		_vertices[_vIndex++] = b;

		addRectIndices();
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

	public static function flush()
	{
		if (_index <= 0) return;
		if (_shader == null)
		{
			#if flash
			_shader = new Shader("m44 op, va0, vc0\nmov v0, va1", "mov oc, v0n");
			#else
			_shader = new Shader("attribute vec2 aVertexPosition;
attribute vec3 aColor;

varying vec3 vColor;
uniform mat4 uMatrix;

void main(void)
{
	vColor = aColor;
	gl_Position = uMatrix * vec4(aVertexPosition, 0.0, 1.0);
}", "varying vec3 vColor;

void main(void)
{
	gl_FragColor = vec4(vColor, 1.0);
}");
			#end
		}
		if (_vertexBuffer == null)
		{
			_vertexBuffer = Renderer.createBuffer(5);
		}
		Renderer.setMatrix(_shader.uniform("uMatrix"), HXP.scene.camera.transform);
		Renderer.bindBuffer(_vertexBuffer);
		Renderer.updateBuffer(_vertices, STATIC_DRAW);
		Renderer.setAttribute(_shader.attribute("aVertexPosition"), 0, 2);
		Renderer.setAttribute(_shader.attribute("aColor"), 2, 3);

		_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);

		Renderer.draw(_indexBuffer, Std.int(_iIndex / 3));
		_iIndex = _vIndex = _index = 0;
	}

	private static var _vIndex:Int = 0;
	private static var _iIndex:Int = 0;
	private static var _index:Int = 0;
	private static var _vertices:FloatArray = new FloatArray();
	private static var _indices:IntArray = new IntArray();
	private static var _vertexBuffer:VertexBuffer;
	private static var _indexBuffer:IndexBuffer;
	private static var _shader:Shader;
}
