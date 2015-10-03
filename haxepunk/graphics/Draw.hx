package haxepunk.graphics;

import haxepunk.renderers.Renderer;

/**
 * Draws colored primitives to the screen.
 */
@:access(haxepunk.graphics.SpriteBatch)
class Draw
{

	private static var _defaultMaterial:Material;

	/**
	 * Resets SpriteBatch to be able to draw solid colors
	 */
	public static inline function begin()
	{
		if (_defaultMaterial == null)
		{
			_defaultMaterial = new Material();
			var vert = Assets.getText("hxp/shaders/default.vert");
			var frag = Assets.getText("hxp/shaders/color.frag");
			_defaultMaterial.firstPass.shader = new Shader(vert, frag);
		}
		SpriteBatch.material = _defaultMaterial;
	}

	/**
	 * Draws a single pixel to the screen
	 * @param x the x-axis value of the pixel
	 * @param y the y-axis value of the pixel
	 * @param color the color of the pixel
	 * @param size the overall size of the pixel square
	 */
	public static function pixel(x:Float, y:Float, color:Color, size:Float=1):Void
	{
		var hs = size / 2;
		fillRect(x - hs, y - hs, size, size, color);
	}

	/**
	 * Draws a non-filled rectangle to the screen
	 * @param x the x-axis value of the rectangle
	 * @param y the y-axis value of the rectangle
	 * @param width the width of the rectangle
	 * @param height the height of the rectangle
	 * @param color the color of the rectangle
	 * @param thickness the line thickness of the rectangle
	 */
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

	/**
	 * Draws a filled rectangle to the screen
	 * @param x the x-axis value of the rectangle
	 * @param y the y-axis value of the rectangle
	 * @param width the width of the rectangle
	 * @param height the height of the rectangle
	 * @param color the color of the rectangle
	 */
	public static function fillRect(x:Float, y:Float, width:Float, height:Float, color:Color):Void
	{
		var r = color.r,
			g = color.g,
			b = color.b;

		SpriteBatch.addTriFan(2);
		SpriteBatch.addVertex(x, y, 0, 0, r, g, b);
		SpriteBatch.addVertex(x + width, y, 0, 0, r, g, b);
		SpriteBatch.addVertex(x + width, y + height, 0, 0, r, g, b);
		SpriteBatch.addVertex(x, y + height, 0, 0, r, g, b);
	}

	/**
	 * Draws a line to the screen
	 * @param x1 the first x-axis value of the line
	 * @param y1 the first y-axis value of the line
	 * @param x2 the second x-axis value of the line
	 * @param y2 the second y-axis value of the line
	 * @param color the color of the line
	 * @param thickness the thickness of the line
	 */
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

		SpriteBatch.addTriFan(2);
		SpriteBatch.addVertex(x1 + dx, y1 + dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x1 - dx, y1 - dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x2 - dx, y2 - dy, 0, 0, r, g, b);
		SpriteBatch.addVertex(x2 + dx, y2 + dy, 0, 0, r, g, b);
	}

	/**
	 * Draws a grid to the screen
	 * @param gx x-axis value of the grid
	 * @param gy y-axis value of the grid
	 * @param gw width of the grid
	 * @param gh height of the grid
	 * @param color the color of the grid lines
	 */
	public static function grid(gx:Float, gy:Float, gw:Float, gh:Float, cellX:Int, cellY:Int, color:Color)
    {
        var offset = gx,
            step = gw / cellX; // horizontal offset
        for (i in 0...cellX+1)
        {
            Draw.line(offset, gy, offset, gy + gh, color);
            offset += step;
        }
        offset = gy; // vertical offset
        step = gh / cellY;
        for (i in 0...cellY+1)
        {
            Draw.line(gx, offset, gx + gw, offset, color);
            offset += step;
        }
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
