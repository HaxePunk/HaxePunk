package com.haxepunk.utils;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.atlas.AtlasData;

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

	public static function init()
	{
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			var sprite = new Sprite();
			HXP.stage.addChild(sprite);
			_graphics = sprite.graphics;
		}
		else
		{
			_graphics = HXP.sprite.graphics;
		}
		_rect = HXP.rect;
	}

	/**
	 * Sets the drawing target for Draw functions.
	 * @param	target		The buffer to draw to.
	 * @param	camera		The camera offset (use null for none).
	 * @param	blend		The blend mode to use.
	 */
	public static function setTarget(target:BitmapData, camera:Point = null, blend:BlendMode = null)
	{
		_target = target;
		_camera = (camera != null) ? camera : HXP.zero;
		Draw.blend = blend;
	}

	/**
	 * Resets the drawing target to the default. The same as calling Draw.setTarget(HXP.buffer, HXP.camera).
	 */
	public static function resetTarget()
	{
		_target = HXP.buffer;
		_camera = HXP.camera;
		Draw.blend = null;
		_graphics.clear();
	}

	private static inline function drawToScreen()
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
	public static function line(x1:Int, y1:Int, x2:Int, y2:Int, color:Int = 0xFFFFFF)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			color = 0xFF000000 | (0xFFFFFF & color);

			// get the drawing difference
			var screen:BitmapData = _target,
				X:Float = Math.abs(x2 - x1),
				Y:Float = Math.abs(y2 - y1),
				xx:Int,
				yy:Int;

			// get drawing positions
			x1 -= Std.int(_camera.x);
			y1 -= Std.int(_camera.y);
			x2 -= Std.int(_camera.x);
			y2 -= Std.int(_camera.y);

			// draw a single pixel
			if (X == 0)
			{
				if (Y == 0)
				{
					screen.setPixel32(x1, y1, color);
					return;
				}
				// draw a straight vertical line
				yy = y2 > y1 ? 1 : -1;
				while (y1 != y2)
				{
					screen.setPixel32(x1, y1, color);
					y1 += yy;
				}
				screen.setPixel32(x2, y2, color);
				return;
			}

			if (Y == 0)
			{
				// draw a straight horizontal line
				xx = x2 > x1 ? 1 : -1;
				while (x1 != x2)
				{
					screen.setPixel32(x1, y1, color);
					x1 += xx;
				}
				screen.setPixel32(x2, y2, color);
				return;
			}

			xx = x2 > x1 ? 1 : -1;
			yy = y2 > y1 ? 1 : -1;
			var c:Float = 0,
				slope:Float;

			if (X > Y)
			{
				slope = Y / X;
				c = .5;
				while (x1 != x2)
				{
					screen.setPixel32(x1, y1, color);
					x1 += xx;
					c += slope;
					if (c >= 1)
					{
						y1 += yy;
						c -= 1;
					}
				}
				screen.setPixel32(x2, y2, color);
			}
			else
			{
				slope = X / Y;
				c = .5;
				while (y1 != y2)
				{
					screen.setPixel32(x1, y1, color);
					y1 += yy;
					c += slope;
					if (c >= 1)
					{
						x1 += xx;
						c -= 1;
					}
				}
				screen.setPixel32(x2, y2, color);
			}
		}
		else
		{
			linePlus(x1, y1, x2, y2, color);
		}
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
	public static function linePlus(x1:Int, y1:Int, x2:Int, y2:Int, color:Int = 0xFF000000, alpha:Float = 1, thick:Float = 1)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_graphics.clear();
			_graphics.lineStyle(thick, color, alpha, false, LineScaleMode.NONE);
			_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
			_graphics.lineTo(x2 - _camera.x, y2 - _camera.y);
			drawToScreen();
		}
		else
		{
			_graphics.lineStyle(thick, color, alpha, false, LineScaleMode.NONE);
			_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
			_graphics.lineTo(x2 - _camera.x, y2 - _camera.y);
			_graphics.lineStyle(0);
		}
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
	public static function rect(x:Int, y:Int, width:Int, height:Int, color:Int = 0xFFFFFF, alpha:Float = 1)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			if (alpha >= 1 && blend == null)
			{
				color = 0xFF000000 | (0xFFFFFF & color);
				_rect.x = x - _camera.x;
				_rect.y = y - _camera.y;
				_rect.width = width;
				_rect.height = height;
				_target.fillRect(_rect, color);
				return;
			}
			_graphics.clear();
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(x - _camera.x, y - _camera.y, width, height);
			drawToScreen();
		}
		else
		{
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(x - _camera.x, y - _camera.y, width, height);
			_graphics.endFill();
		}
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
	 */
	public static function rectPlus(x:Float, y:Float, width:Float, height:Float, color:Int = 0xFFFFFF, alpha:Float = 1, fill:Bool = true, thick:Float = 1)
	{
		color = 0xFFFFFF & color;
		
		if (HXP.renderMode == RenderMode.BUFFER) _graphics.clear();
		
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
		
		HXP.renderMode == RenderMode.BUFFER ? drawToScreen() : _graphics.lineStyle(0);
	}
		
	/**
	 * Draws a non-filled, pixelated circle.
	 * @param	x			Center x position.
	 * @param	y			Center y position.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 */
	public static function circle(x:Int, y:Int, radius:Int, color:Int = 0xFFFFFF)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			color = 0xFF000000 | (0xFFFFFF & color);
			x -= Std.int(_camera.x);
			y -= Std.int(_camera.y);
			var f:Int = 1 - radius,
				fx:Int = 1,
				fy:Int = -2 * radius,
				xx:Int = 0,
				yy:Int = radius;
			_target.setPixel32(x, y + radius, color);
			_target.setPixel32(x, y - radius, color);
			_target.setPixel32(x + radius, y, color);
			_target.setPixel32(x - radius, y, color);
			while (xx < yy)
			{
				if (f >= 0)
				{
					yy --;
					fy += 2;
					f += fy;
				}
				xx ++;
				fx += 2;
				f += fx;
				_target.setPixel32(x + xx, y + yy, color);
				_target.setPixel32(x - xx, y + yy, color);
				_target.setPixel32(x + xx, y - yy, color);
				_target.setPixel32(x - xx, y - yy, color);
				_target.setPixel32(x + yy, y + xx, color);
				_target.setPixel32(x - yy, y + xx, color);
				_target.setPixel32(x + yy, y - xx, color);
				_target.setPixel32(x - yy, y - xx, color);
			}
		}
		else
		{
			circlePlus(x, y, radius, color, 1.0, false);
		}
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
	public static function circlePlus(x:Int, y:Int, radius:Float, color:Int = 0xFFFFFF, alpha:Float = 1, fill:Bool = true, thick:Int = 1)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_graphics.clear();
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
			}
			drawToScreen();
		}
		else
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
	}

	/**
	 * Draws the Entity's hitbox.
	 * @param	e			The Entity whose hitbox is to be drawn.
	 * @param	outline		If just the hitbox's outline should be drawn.
	 * @param	color		Color of the hitbox.
	 * @param	alpha		Alpha of the hitbox.
	 */
	public static function hitbox(e:Entity, outline:Bool = true, color:Int = 0xFFFFFF, alpha:Float = 1)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			if (outline)
			{
				color = 0xFF000000 | (0xFFFFFF & color);
				var x:Int = Std.int(e.x - e.originX - _camera.x),
					y:Int = Std.int(e.y - e.originY - _camera.y);
				_rect.x = x;
				_rect.y = y;
				_rect.width = e.width;
				_rect.height = 1;
				_target.fillRect(_rect, color);
				_rect.y += e.height - 1;
				_target.fillRect(_rect, color);
				_rect.y = y;
				_rect.width = 1;
				_rect.height = e.height;
				_target.fillRect(_rect, color);
				_rect.x += e.width - 1;
				_target.fillRect(_rect, color);
				return;
			}
			if (alpha >= 1 && blend == null)
			{
				color = 0xFF000000 | (0xFFFFFF & color);
				_rect.x = e.x - e.originX - _camera.x;
				_rect.y = e.y - e.originY - _camera.y;
				_rect.width = e.width;
				_rect.height = e.height;
				_target.fillRect(_rect, color);
				return;
			}

			_graphics.clear();
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(e.x - e.originX - _camera.x, e.y - e.originY - _camera.y, e.width, e.height);
			drawToScreen();
		}
		else
		{
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(e.x - e.originX - _camera.x, e.y - e.originY - _camera.y, e.width, e.height);
			_graphics.endFill();
		}
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
	public static function curve(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, thick:Float = 1, color:Int = 0, alpha:Float = 1)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_graphics.clear();
			_graphics.lineStyle(thick, color, alpha);
			_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
			_graphics.curveTo(x2 - _camera.x, y2 - _camera.y, x3 - _camera.x, y3 - _camera.y);
			drawToScreen();
		}
		else
		{
			_graphics.lineStyle(thick, color, alpha);
			_graphics.moveTo(x1 - _camera.x, y1 - _camera.y);
			_graphics.curveTo(x2 - _camera.x, y2 - _camera.y, x3 - _camera.x, y3 - _camera.y);
			_graphics.lineStyle(0);
		}
	}

	/**
	 * Draws a graphic object.
	 * @param	g		The Graphic to draw.
	 * @param	x		X position.
	 * @param	y		Y position.
	 */
	public static function graphic(g:Graphic, x:Int = 0, y:Int = 0)
	{
		if (g.visible)
		{
			if (g.relative)
			{
				HXP.point.x = x;
				HXP.point.y = y;
			}
			else HXP.point.x = HXP.point.y = 0;
			HXP.point2.x = HXP.camera.x;
			HXP.point2.y = HXP.camera.y;
			g.render(_target, HXP.point, HXP.point2);
		}
	}

	/**
	 * Draws an Entity object.
	 * @param	e					The Entity to draw.
	 * @param	x					X position.
	 * @param	y					Y position.
	 * @param	addEntityPosition	Adds the Entity's x and y position to the target position.
	 */
	public static function entity(e:Entity, ?x:Int = 0, ?y:Int = 0, ?addEntityPosition:Bool = false)
	{
		if (e.visible && e.graphic != null)
		{
			if (addEntityPosition) graphic(e.graphic, Std.int(x + e.x), Std.int(y + e.y));
			else graphic(e.graphic, x, y);
		}
	}

	/**
	 * Draws text.
	 * @param  text    The text to render.
	 * @param  x       X position.
	 * @param  y       Y position.
	 * @param  options Options (see Text constructor).
	 */
	public static function text(text:String, ?x:Float = 0, ?y:Float = 0, ?options:TextOptions = null)
	{
		var textGfx:Text = new Text(text, x, y, 0, 0, options);
		textGfx.render(_target, HXP.zero, _camera);
	}

	// Drawing information.
	private static var _target:BitmapData;
	private static var _camera:Point;
	private static var _graphics:Graphics;
	private static var _rect:Rectangle;
	private static var _matrix:Matrix = new Matrix();
}
