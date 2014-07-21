package haxepunk.graphics;

class Color
{

	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;

	public function new(r:Float=1, g:Float=1, b:Float=1, a:Float=1)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	/**
	 * Hue value from HSV
	 */
	public var h(get, never):Float;
	private function get_h():Float {
		var max = Math.max(r, Math.max(g, b));
		var min = Math.min(r, Math.min(g, b));

		var hue = 0.0;

		if (max == min)
		{
			hue = 0;
		}
		else if (max == r)
		{
			hue = (60 * (g - b) / (max - min) + 360) % 360;
		}
		else if (max == g)
		{
			hue = (60 * (b - r) / (max - min) + 120);
		}
		else if (max == b)
		{
			hue = (60 * (r - g) / (max - min) + 240);
		}

		return hue / 360;
	}

	/**
	 * Saturation value from HSV
	 */
	public var s(get, never):Float;
	private inline function get_s():Float {
		var max = Math.max(r, Math.max(g, b));
		if (max == 0)
		{
			return 0;
		}
		else
		{
			var min = Math.min(r, Math.min(g, b));
			return (max - min) / max;
		}
	}

	/**
	 * Value from HSV
	 */
	public var v(get, never):Float;
	private inline function get_v():Float {
		return Math.max(r, Math.max(g, b));
	}

	public function fromRGB(r:Float, g:Float, b:Float, a:Float=1.0)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public function fromInt(value:Int, withAlpha:Bool=false):Void
	{
		if (withAlpha)
		{
			r = (value >> 24 & 0xFF) / 0xFF;
			g = (value >> 16 & 0xFF) / 0xFF;
			b = (value >> 8 & 0xFF) / 0xFF;
			b = (value & 0xFF) / 0xFF;
		}
		else
		{
			r = (value >> 16 & 0xFF) / 0xFF;
			g = (value >> 8 & 0xFF) / 0xFF;
			b = (value & 0xFF) / 0xFF;
			a = 1;
		}
	}

	/**
	 * Convert color to an int value
	 * @param alpha include the alpha value
	 */
	public function toInt(alpha:Bool=false):Int
	{
		var color = getColorRGB(Std.int(r * 255), Std.int(g * 255), Std.int(b * 255));
		if (alpha) color = color << 8 | Std.int(a * 255);
		return color;
	}

	/**
	 * Convert color to a web friendly hex string
	 * @param alpha include the alpha value
	 */
	public function toHexCode(alpha:Bool=false):String
	{
		return "#" + StringTools.hex(toInt(alpha));
	}

	/**
	 * Creates a color value by combining the chosen RGB values.
	 * @param	R		The red value of the color, from 0 to 255.
	 * @param	G		The green value of the color, from 0 to 255.
	 * @param	B		The blue value of the color, from 0 to 255.
	 * @return	The color Int.
	 */
	public static inline function getColorRGB(R:Int = 0, G:Int = 0, B:Int = 0):Int
	{
		return R << 16 | G << 8 | B;
	}

	/**
	 * Creates a color value with the chosen HSV values.
	 * @param	h		The hue of the color (from 0 to 1).
	 * @param	s		The saturation of the color (from 0 to 1).
	 * @param	v		The value of the color (from 0 to 1).
	 * @return	The color Int.
	 */
	public static function getColorHSV(h:Float, s:Float, v:Float):Int
	{
		h = Std.int(h * 360);
		var hi:Int = Math.floor(h / 60) % 6,
			f:Float = h / 60 - Math.floor(h / 60),
			p:Float = (v * (1 - s)),
			q:Float = (v * (1 - f * s)),
			t:Float = (v * (1 - (1 - f) * s));
		switch (hi)
		{
			case 0: return Std.int(v * 255) << 16 | Std.int(t * 255) << 8 | Std.int(p * 255);
			case 1: return Std.int(q * 255) << 16 | Std.int(v * 255) << 8 | Std.int(p * 255);
			case 2: return Std.int(p * 255) << 16 | Std.int(v * 255) << 8 | Std.int(t * 255);
			case 3: return Std.int(p * 255) << 16 | Std.int(q * 255) << 8 | Std.int(v * 255);
			case 4: return Std.int(t * 255) << 16 | Std.int(p * 255) << 8 | Std.int(v * 255);
			case 5: return Std.int(v * 255) << 16 | Std.int(p * 255) << 8 | Std.int(q * 255);
			default: return 0;
		}
		return 0;
	}

	/**
	 * Finds the hue factor of a color.
	 * @param  color The color to evaluate.
	 * @return The hue value (from 0 to 1).
	 */
	public static function getColorHue(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		var max:Int = Std.int(Math.max(h, Math.max(s, v)));
		var min:Int = Std.int(Math.min(h, Math.min(s, v)));

		var hue:Float = 0;

		if (max == min)
		{
			hue = 0;
		}
		else if (max == h)
		{
			hue = (60 * (s - v) / (max - min) + 360) % 360;
		}
		else if (max == s)
		{
			hue = (60 * (v - h) / (max - min) + 120);
		}
		else if (max == v)
		{
			hue = (60 * (h - s) / (max - min) + 240);
		}

		return hue / 360;
	}

	/**
	 * Finds the saturation factor of a color.
	 * @param  color The color to evaluate.
	 * @return The saturation value (from 0 to 1).
	 */
	public static function getColorSaturation(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		var max:Int = Std.int(Math.max(h, Math.max(s, v)));

		if (max == 0)
		{
			return 0;
		}
		else
		{
			var min:Int = Std.int(Math.min(h, Math.min(s, v)));

			return (max - min) / max;
		}
	}

	/**
	 * Finds the value factor of a color.
	 * @param  color The color to evaluate.
	 * @return The value value (from 0 to 1).
	 */
	public static function getColorValue(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		return Std.int(Math.max(h, Math.max(s, v))) / 255;
	}

	/**
	 * Finds the red factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getRed(color:Int):Int
	{
		return color >> 16 & 0xFF;
	}

	/**
	 * Finds the green factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getGreen(color:Int):Int
	{
		return color >> 8 & 0xFF;
	}

	/**
	 * Finds the blue factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}

}
