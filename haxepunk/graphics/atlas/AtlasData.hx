package haxepunk.graphics.atlas;

import haxepunk.assets.AssetCache;
import haxepunk.graphics.shader.Shader;
import haxepunk.graphics.hardware.DrawCommandBatch;
import haxepunk.graphics.hardware.Texture;
import haxepunk.math.Degrees;
import haxepunk.math.MathUtil;
import haxepunk.math.Radians;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;
import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;

class AtlasData
{
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var texture:Texture;

	/**
	 * Creates a new AtlasData class
	 *
	 * **NOTE**: Only create one instance of AtlasData per name. An error will be thrown if you try to create a duplicate.
	 *
	 * @param texture Texture image to use for rendering
	 * @param name    A reference to the image data, used with destroy and for setting rendering flags
	 */
	public function new(texture:Texture, ?name:String)
	{
		this.texture = texture;

		_name = name;

		width = texture.width;
		height = texture.height;
	}

	/**
	 * String representation of AtlasData
	 * @return the name of the AtlasData
	 */
	public inline function toString():String
	{
		return (_name == null ? "AtlasData" : _name);
	}

	/**
	 * Sets the scene object
	 * @param	scene	The scene object to set
	 */
	@:allow(haxepunk.Scene)
	static inline function startScene(batch:DrawCommandBatch):Void
	{
		_batch = batch;
		batch.recycle();
	}

	/**
	 * Creates a new AtlasRegion
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	center	Positions the local center point to pivot on (not used)
	 *
	 * @return The new AtlasRegion object.
	 */
	public inline function createRegion(rect:Rectangle, ?center:Vector2):AtlasRegion
	{
		return new AtlasRegion(this, rect.clone());
	}

	/**
	 * Prepares a tile to be drawn using a matrix
	 * @param  rect   The source rectangle to draw
	 * @param  tx    X-Axis translation
	 * @param  ty    Y-Axis translation
	 * @param  a     Top-left
	 * @param  b     Top-right
	 * @param  c     Bottom-left
	 * @param  d     Bottom-right
	 * @param  red   Red color value
	 * @param  green Green color value
	 * @param  blue  Blue color value
	 * @param  alpha Alpha value
	 */
	public inline function prepareTileMatrix(
		rect:Rectangle,
		tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		color:Color, alpha:Float,
		shader:Shader, smooth:Bool=false, blend:BlendMode, ?clipRect:Rectangle,
		flexibleLayer:Bool = false)
	{
		_batch.addRect(
			texture, shader, smooth, blend, clipRect,
			rect.x, rect.y, rect.width, rect.height,
			a, b, c, d, tx, ty,
			color, alpha, flexibleLayer
		);
	}

	/**
	 * Prepares a tile to be drawn
	 * @param  rect   The source rectangle to draw
	 * @param  x      The x-axis value
	 * @param  y      The y-axis value
	 * @param  scaleX X-Axis scale
	 * @param  scaleY Y-Axis scale
	 * @param  angle  Angle (in degrees)
	 * @param  red    Red color value
	 * @param  green  Green color value
	 * @param  blue   Blue color value
	 * @param  alpha  Alpha value
	 */
	public inline function prepareTile(
		rect:Rectangle, tx:Float, ty:Float,
		scaleX:Float, scaleY:Float, angle:Degrees,
		color:Color, alpha:Float,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle,
		flexibleLayer:Bool = false):Void
	{
		var a:Float, b:Float, c:Float, d:Float;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			a = scaleX; // m00
			b = 0; // m01
			c = 0; // m10
			d = scaleY; // m11
		}
		else
		{
			var rads:Radians = -angle;
			var cos = Math.cos(rads),
				sin = Math.sin(rads);
			a = cos * scaleX; // m00
			b = -sin * scaleY; // m10
			c = sin * scaleX; // m01
			d = cos * scaleY; // m11
		}

		_batch.addRect(texture, shader, smooth, blend, clipRect, rect.x, rect.y, rect.width, rect.height, a, b, c, d, tx, ty, color, alpha, flexibleLayer);
	}

	/**
	 * Prepares a triangle draw command
	 * @param  tx1    The first vertex x position
	 * @param  ty1    The first vertex y position
	 * @param  uvx1   The first vertex uv x coord (0-1)
	 * @param  uvy1   The first vertex uv y coord (0-1)
	 * @param  tx2    The second vertex x position
	 * @param  ty2    The second vertex y position
	 * @param  uvx2   The second vertex uv x coord (0-1)
	 * @param  uvy2   The second vertex uv y coord (0-1)
	 * @param  tx3    The third vertex x position
	 * @param  ty3    The third vertex y position
	 * @param  uvx3   The third vertex uv x coord (0-1)
	 * @param  uvy3   The third vertex uv y coord (0-1)
	 * @param  red    Red color value
	 * @param  green  Green color value
	 * @param  blue   Blue color value
	 * @param  alpha  Alpha value
	 * @param  shader Shader to use for rendering
	 * @param  smooth Enables linear smoothing on texture
	 * @param  blend  Blend mode to use for rendering
	 * @param  clipRect The rectangle used for clipping
	 */
	public function prepareTriangle(
		tx1:Float, ty1:Float, uvx1:Float, uvy1:Float,
		tx2:Float, ty2:Float, uvx2:Float, uvy2:Float,
		tx3:Float, ty3:Float, uvx3:Float, uvy3:Float,
		color:Color, alpha:Float,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle,
		flexibleLayer:Bool = false):Void
	{
		_batch.addTriangle(texture, shader, smooth, blend, clipRect, tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, color, alpha, flexibleLayer);
	}

	// used for pooling
	var _name:String;

	static var _batch:DrawCommandBatch;
	static var _uniqueId:Int = 0; // allows for unique names
	static var _rect:Rectangle = new Rectangle();
}
