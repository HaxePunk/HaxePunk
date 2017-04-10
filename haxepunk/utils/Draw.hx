package haxepunk.utils;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.Text;
import haxepunk.utils.Color;

/**
 * Static class with access to miscellanious drawing functions.
 * These functions are not meant to replace Graphic components
 * for Entities, but rather to help with testing and debugging.
 */
class Draw
{
	/**
	 * The blending mode used by Draw functions. This will not
	 * apply to Draw.line(), but will apply to Draw.linePlus().
	 */
	public static var blend:BlendMode;

	@:dox(hide)
	public static function init()
	{
		var sprite = new Sprite();
		HXP.stage.addChild(sprite);
		_graphics = sprite.graphics;
		_rect = HXP.rect;
	}

	/**
	 * Sets the drawing target for Draw functions.
	 * @param	target		The buffer to draw to.
	 * @param	camera		The camera offset (use null for none).
	 * @param	blend		The blend mode to use.
	 */
	public static function setTarget(target:BitmapData, camera:Camera = null, blend:BlendMode = null)
	{
		_target = target;
		_camera = (camera != null) ? camera : HXP.camera;
		Draw.blend = blend;
	}

	static inline function drawToScreen()
	{
		if (blend == null)
		{
			_target.draw(HXP.sprite);
		}
		else
		{
			_target.draw(HXP.sprite, null, null, blend);
		}
	}

	/**
	 * Draws a pixelated, non-antialiased line.
	 * @param	x1		Starting x position.
	 * @param	y1		Starting y position.
	 * @param	x2		Ending x position.
	 * @param	y2		Ending y position.
	 * @param	color	Color of the line.
	 */
	public static function line(x1:Int, y1:Int, x2:Int, y2:Int, color:Color = 0xFFFFFF)
	{
		linePlus(x1, y1, x2, y2, color);
	}

	/**
	 * Draws a smooth, antialiased line with optional alpha and thickness.
	 * @param	x1		Starting x position.
	 * @param	y1		Starting y position.
	 * @param	x2		Ending x position.
	 * @param	y2		Ending y position.
	 * @param	color	Color of the line.
	 * @param	alpha	Alpha of the line.
	 * @param	thick	The thickness of the line.
	 */
	public static function linePlus(x1:Int, y1:Int, x2:Int, y2:Int, color:Color = 0xFF000000, alpha:Float = 1, thick:Float = 1)
	{
		_graphics.lineStyle(thick, color, alpha, false, LineScaleMode.NONE);
		_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
		_graphics.lineTo(x2 - _camera.x, y2 - _camera.y);
		_graphics.lineStyle(0);
	}

	/**
	 * Draws a filled rectangle.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @param	color		Color of the rectangle.
	 * @param	alpha		Alpha of the rectangle.
	 */
	public static function rect(x:Int, y:Int, width:Int, height:Int, color:Color = 0xFFFFFF, alpha:Float = 1)
	{
		_graphics.beginFill(color, alpha);
		_graphics.drawRect(x - _camera.x, y - _camera.y, width, height);
		_graphics.endFill();
	}

	/**
	 * Draws a rectangle.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @param	color		Color of the rectangle.
	 * @param	alpha		Alpha of the rectangle.
	 * @param	fill		If the rectangle should be filled with the color (true) or just an outline (false).
	 * @param	thick		How thick the outline should be (only applicable when fill = false).
	 * @since	2.5.2
	 */
	public static function rectPlus(x:Float, y:Float, width:Float, height:Float, color:Color = 0xFFFFFF, alpha:Float = 1, fill:Bool = true, thick:Float = 1)
	{
		color = 0xFFFFFF & color;

		if (fill)
		{
			_graphics.beginFill(color, alpha);
		}
		else
		{
			_graphics.lineStyle(thick, color, alpha);
		}

		_graphics.drawRect(x - _camera.x, y - _camera.y, width, height);
		_graphics.endFill();
		_graphics.lineStyle(0);
	}

	/**
	 * Draws a non-filled, pixelated circle.
	 * @param	x			Center x position.
	 * @param	y			Center y position.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 */
	public static function circle(x:Int, y:Int, radius:Int, color:Color = 0xFFFFFF)
	{
		circlePlus(x, y, radius, color, 1.0, false);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 * @param	alpha		Alpha of the circle.
	 * @param	fill		If the circle should be filled with the color (true) or just an outline (false).
	 * @param	thick		How thick the outline should be (only applicable when fill = false).
	 */
	public static function circlePlus(x:Int, y:Int, radius:Float, color:Color = 0xFFFFFF, alpha:Float = 1, fill:Bool = true, thick:Int = 1)
	{
		if (fill)
		{
			_graphics.beginFill(color & 0xFFFFFF, alpha);
			_graphics.drawCircle(x - _camera.x, y - _camera.y, radius);
			_graphics.endFill();
		}
		else
		{
			_graphics.lineStyle(thick, color & 0xFFFFFF, alpha);
			_graphics.drawCircle(x - _camera.x, y - _camera.y, radius);
			_graphics.lineStyle(0);
		}
	}

	/**
	 * Draws the Entity's hitbox.
	 * @param	e			The Entity whose hitbox is to be drawn.
	 * @param	outline		If just the hitbox's outline should be drawn.
	 * @param	color		Color of the hitbox.
	 * @param	alpha		Alpha of the hitbox.
	 */
	public static function hitbox(e:Entity, outline:Bool = true, color:Color = 0xFFFFFF, alpha:Float = 1)
	{
		_graphics.beginFill(color, alpha);
		_graphics.drawRect(e.x - e.originX - _camera.x, e.y - e.originY - _camera.y, e.width, e.height);
		_graphics.endFill();
	}

	/**
	 * Draws a quadratic curve.
	 * @param	x1		X start.
	 * @param	y1		Y start.
	 * @param	x2		X control point, used to determine the curve.
	 * @param	y2		Y control point, used to determine the curve.
	 * @param	x3		X finish.
	 * @param	y3		Y finish.
	 * @param	thick	The thickness of the curve.
	 * @param	color	Color of the curve
	 * @param	alpha	Alpha transparency.
	 */
	public static function curve(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, thick:Float = 1, color:Color = 0, alpha:Float = 1)
	{
		_graphics.lineStyle(thick, color, alpha);
		_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
		_graphics.curveTo(x2 - _camera.x, y2 - _camera.y, x3 - _camera.x, y3 - _camera.y);
		_graphics.lineStyle(0);
	}

	/**
	 * Draws text.
	 * @param  text    The text to render.
	 * @param  x       X position.
	 * @param  y       Y position.
	 * @param  options Options (see Text constructor).
	 */
	public static function text(text:String, ?x:Float = 0, ?y:Float = 0, ?options:TextOptions)
	{
		var textGfx:Text = new Text(text, x, y, 0, 0, options);
		// textGfx.render(_target, HXP.zero, _camera);
		// TODO: re-enable??
	}

	// Drawing information.
	static var _target:BitmapData;
	static var _camera:Camera;
	static var _graphics:Graphics;
	static var _rect:Rectangle;
	static var _matrix:Matrix = new Matrix();
}
