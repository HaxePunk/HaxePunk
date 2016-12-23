package haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import haxepunk.HXP;
import haxepunk.RenderMode;
import haxepunk.Graphic;
import haxepunk.graphics.Text;
import haxepunk.graphics.atlas.BitmapFontAtlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;

@:dox(hide)
typedef RenderFunction = AtlasRegion -> GlyphData -> Float -> Float -> Void;

/**
 * Text option including the font, size, color, font format...
 */
typedef BitmapTextOptions =
{
	> TextOptions,
	@:optional var format:BitmapFontFormat;
	@:optional var extraParams:Dynamic;
};

/**
 * An object for drawing text using a bitmap font.
 * @since	2.5.0
 */
class BitmapText extends Graphic
{
	public var width:Float = 0;
	public var height:Float = 0;
	public var textWidth:Int = 0;
	public var textHeight:Int = 0;
	public var autoWidth:Bool = false;

	/**
	 * Whether or not to automatically figure out the height 
	 * and width of the text. 
	 * @default False.
	 */
	public var autoHeight:Bool = false;
	public var size:Int = 0;
	public var wrap:Bool = false;

	public var scale:Float = 1;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public var lines:Array<String>;
	public var lineSpacing:Int = 0;
	public var charSpacing:Int = 0;

	/**
	 * BitmapText constructor.
	 * @param text    Text to display.
	 * @param x       X offset.
	 * @param y       Y offset.
	 * @param width   Image width (leave as 0 to size to the starting text string).
	 * @param height  Image height (leave as 0 to size to the starting text string).
	 * @param options An object containing optional parameters contained in BitmapTextOptions
	 * 						font		Name of the font asset (.fnt or .png).
	 * 						size		Font size.
	 * 						format		Font format (BitmapFontFormat.XML or BitmapFontFormat.XNA).
	 * 						wordWrap	Automatic word wrapping.
	 * 						color		Text color.
	 * 						align		Alignment ("left", "center" or "right"). (Currently ignored.)
	 * 						resizable	If the text field can automatically resize if its contents grow. (Currently ignored.)
	 * 						leading		Vertical space between lines. (Currently ignored.)
	 *						richText	If the text field uses a rich text string. (Currently ignored.) 
	 */
	public function new(text:String, ?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?height:Float = 0, ?options:BitmapTextOptions)
	{
		super();

		if (options == null) options = {};

		// defaults
		if (!Reflect.hasField(options, "font"))      options.font      = HXP.defaultFont + ".png";
		if (!Reflect.hasField(options, "size"))      options.size      = null;
		if (!Reflect.hasField(options, "color"))     options.color     = 0xFFFFFF;
		if (!Reflect.hasField(options, "wordWrap"))  options.wordWrap  = false;

		// load the font as a BitmapFontAtlas
		var font = BitmapFontAtlas.getFont(options.font, options.format, options.extraParams);

		blit = HXP.renderMode != RenderMode.HARDWARE;
		_font = cast(font, BitmapFontAtlas);

		// failure to load
		if (_font == null)
			throw "Invalid font glyphs provided.";
		
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		wrap = options.wordWrap;
		size = options.size != null ? options.size : _font.fontSize;

		autoWidth = (width == 0);
		autoHeight = (height == 0);

		if (blit)
		{
			_set = HXP.getBitmap(StringTools.replace(options.font, ".fnt", ".png"));
			_matrix = HXP.matrix;
			_colorTransform = new ColorTransform();
		}

		this.color = options.color;
		updateColor();
		this.text = text != null ? text : "";

		smooth = (HXP.stage.quality != LOW);
	}

	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	public var color(default, set):Color;
	private function set_color(value:Color):Int
	{
		value &= 0xFFFFFF;
		if (color == value) return value;

		color = value;
		updateColor();

		return value;
	}

	public var alpha(default, set):Float=1;
	private function set_alpha(value:Float)
	{
		alpha = value;
		updateColor();

		return value;
	}

	/*
	 * Called automatically to update the ColorTransform object whenever color
	 * or alpha is set.
	 */
	private function updateColor()
	{
		// update _colorTransform if blitting
		_red = color.red;
		_green = color.green;
		_blue = color.blue;

		if (blit)
		{
			_colorTransform.redMultiplier = _red;
			_colorTransform.greenMultiplier = _green;
			_colorTransform.blueMultiplier = _blue;
			_colorTransform.alphaMultiplier = alpha;
		}
	}

	public var text(default, set):String;
	private function set_text(text:String):String
	{
		this.text = text;
		var _oldLines:Array<String> = null;
		if (lines != null)
			_oldLines = lines;
		lines = text.split("\n");

		if (wrap)
		{
			wordWrap();
		}

		textWidth = textHeight = 0;
		if (blit) updateBuffer(_oldLines);
		else computeTextSize();

		return text;
	}

	/**
	 * Automatically wraps text by figuring out how many words can fit on a
	 * single line, and splitting the remainder onto a new line.
	 */
	public function wordWrap():Void
	{
		// subdivide lines
		var newLines:Array<String> = [];
		var spaceWidth = _font.glyphData.get(' ').xAdvance;
		var fontScale = size / _font.fontSize;
		var sx:Float = scale * scaleX * fontScale, 
			sy:Float = scale * scaleY * fontScale;
		for (line in lines)
		{
			var subLines:Array<String> = [];
			var words:Array<String> = [];
			// split this line into words
			var thisWord = "";
			for (n in 0 ... line.length)
			{
				var char:String = line.charAt(n);
				switch (char)
				{
					case ' ', '-':
						words.push(thisWord + char);
						thisWord = "";
					default:
						thisWord += char;
				}
			}
			if (thisWord != "") words.push(thisWord);
			if (words.length > 1)
			{
				var w:Int = 0, lastBreak:Int = 0, lineWidth:Float = 0;
				while (w < words.length)
				{
					var wordWidth:Float = 0;
					var word = words[w];
					for (letter in word.split(''))
					{
						var letterWidth = _font.glyphData.exists(letter) ?
						                  _font.glyphData.get(letter).xAdvance : 0;
						wordWidth += (letterWidth + charSpacing);
					}
					lineWidth += wordWidth;
					// if the word ends in a space, don't count that last space
					// toward the line length for determining overflow
					var endsInSpace = word.charAt(word.length - 1) == ' ';
					if ((lineWidth - (endsInSpace ? spaceWidth : 0)) > width / sx)
					{
						// line is too long; split it before this word
						subLines.push(words.slice(lastBreak, w).join(''));
						lineWidth = wordWidth;
						lastBreak = w;
					}
					w += 1;
				}
				subLines.push(words.slice(lastBreak).join(''));
			}
			else
			{
				subLines.push(line);
			}

			for (subline in subLines)
			{
				newLines.push(subline);
			}
		}

		lines = newLines;
	}

	/**
	 * Run through the render loop without actually drawing anything. This
	 * will compute the textWidth and textHeight attributes.
	 */
	public function computeTextSize()
	{
		renderFont();
	}

	/**
	 * Update the drawing buffer on software rendering mode. For efficiency, if
	 * any lines were unchanged from previously rendered text, they will not be
	 * re-drawn.
	 */
	public function updateBuffer(?oldLines:Array<String>)
	{
		// render the string of text to _buffer

		if (text == null) return;

		var fontScale = size / _font.fontSize;

		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		var sx = scale * scaleX * fontScale,
			sy = scale * scaleY * fontScale;

		var w:Int;
		var h:Int;
		if (autoWidth || autoHeight)
		{
			computeTextSize();
			w = Std.int(autoWidth ? (textWidth / sx) : (width / sx));
			h = Std.int(autoHeight ? (textHeight / sy) : (height / sy));
		}
		else
		{
			w = Std.int(width / sx);
			h = Std.int(height / sy);
		}
		w = Std.int(w);
		h = Std.int(h + _font.lineHeight + lineSpacing);

		// create or clear the buffer if necessary
		if (_buffer == null || _buffer.width != w || _buffer.height != h)
		{
			if (_buffer != null) _buffer.dispose();
			_buffer = HXP.createBitmap(w, h, true, 0);
		}
		else
		{
			_buffer.fillRect(_buffer.rect, HXP.blackColor);
		}

		// make a pass through each character, copying it onto the buffer
		renderFont(function(region:AtlasRegion, gd:GlyphData, x:Float, y:Float)
		{
			_point.x = x;
			_point.y = y;

			_buffer.copyPixels(_set, gd.rect, _point, null, null, true);
		});
	}

	/*
	 * Loops through the text, drawing each character on each line.
	 * @param renderFunction    Function to render each character.
	 */
	private inline function renderFont(?renderFunction:RenderFunction)
	{
		// loop through the text one character at a time, calling the supplied
		// rendering function for each character
		var fontScale = size / _font.fontSize;

		var lineHeight:Int = Std.int(_font.lineHeight + lineSpacing);

		var rx:Int = 0, ry:Int = 0;
		var sx:Float = scale * scaleX * fontScale, 
			sy:Float = scale * scaleY * fontScale;
		for (y in 0 ... lines.length)
		{
			var line = lines[y];

			for (x in 0 ... line.length)
			{
				var letter = line.charAt(x);
				var region = _font.getChar(letter);
				var gd = _font.glyphData.get(letter);
				// if a character isn't in this font, display a space
				if (gd == null) 
				{
					letter = ' ';
					gd = _font.glyphData.get(' ');
				}

				if (letter == ' ')
				{
					// it's a space, just move the cursor
					rx += Std.int(gd.xAdvance);
				}
				else
				{
					// draw the character
					if (renderFunction != null)
					{
						renderFunction(region, gd,
						               (rx + gd.xOffset),
						               (ry + gd.yOffset));
					}
					// advance cursor position
					rx += Std.int((gd.xAdvance + charSpacing));
					if (width != 0 && rx > width / sx)
					{
						textWidth = Std.int(width);
						rx = 0;
						ry += lineHeight;
					}
				}

				// longest line so far
				if (Std.int(rx * sx) > textWidth) textWidth = Std.int(rx * sx);
			}

			// next line
			rx = 0;
			ry += lineHeight;
			if (Std.int(ry * sy) > textHeight) textHeight = Std.int(ry * sy);
		}
	}

	@:dox(hide)
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		// determine drawing location
		var fontScale = size / _font.fontSize;

		var sx = scale * scaleX * fontScale,
			sy = scale * scaleY * fontScale;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);

		// blit the buffer to the screen
		_matrix.b = _matrix.c = 0;
		_matrix.a = sx;
		_matrix.d = sy;
		_matrix.tx = _point.x;
		_matrix.ty = _point.y;
		target.draw(_buffer, _matrix, _colorTransform, null, null, smooth);
		//target.copyPixels(_buffer, _buffer.rect, _point, null, null, true);
	}

	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		// determine drawing location
		var fontScale = size / _font.fontSize;

		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		var sx = scale * scaleX * fontScale * fsx,
			sy = scale * scaleY * fontScale * fsy;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);

		// use hardware accelerated rendering
		renderFont(function(region:AtlasRegion, gd:GlyphData, x:Float, y:Float)
		{
			region.draw(_point.x * fsx + x * sx, _point.y * fsy + y * sy, layer, sx, sy, 0, _red, _green, _blue, alpha, smooth);
		});
	}

	/** Default value: false if HXP.stage.quality is LOW, true otherwise. */
	public var smooth:Bool;

	private var _buffer:BitmapData;
	private var _set:BitmapData;
	private var _font:BitmapFontAtlas;
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;

}
