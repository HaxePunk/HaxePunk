package haxepunk.graphics;

import haxepunk.renderers.Renderer;

@:access(haxepunk.graphics.SpriteBatch)
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

		SpriteBatch.addVertex(x, y, 0, 0, r, g, b);
		SpriteBatch.addVertex(x + width, y, 0, 0, r, g, b);
		SpriteBatch.addVertex(x + width, y + height, 0, 0, r, g, b);
		SpriteBatch.addVertex(x, y + height, 0, 0, r, g, b);
		SpriteBatch.addRectIndices();
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

		SpriteBatch.addVertex(x1 + dx, y1 + dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x1 - dx, y1 - dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x2 - dx, y2 - dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x2 + dx, y2 + dy, 0, 0, r, g, b);
		SpriteBatch.addRectIndices();
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
