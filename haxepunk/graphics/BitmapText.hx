package haxepunk.graphics;

import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.Text;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.BitmapFontAtlas;
import haxepunk.graphics.atlas.IBitmapFont;
import haxepunk.utils.Color;

/**
 * Text option including the font, size, color, font format...
 */
typedef BitmapTextOptions =
{
	> TextOptions,
	@:optional var format:BitmapFontFormat;
	@:optional var extraParams:Dynamic;
};

@:enum
abstract AlignType(Int)
{
	var Left = 0;
	var Center = 1;
	var Right = 2;
}

typedef GlyphMoveFunction = String -> Point -> Point;

/**
 * Rendering opcodes. Text is parsed into an array of these opcodes which
 * either modify the format, render blocks of text or images, or change the
 * cursor position.
 * @since	4.0.0
 */
enum TextOpcode
{
	SetColor(color:Color);
	SetAlpha(alpha:Float);
	SetScale(scale:Float);
	TextBlock(text:String);
	NewLine(width:Float, height:Float, align:AlignType);
	Image(image:Image);
	Align(alignType:AlignType);
	MoveText(f:GlyphMoveFunction);
	PopColor;
	PopAlpha;
	PopScale;
	PopMoveText;
}

/**
 * An object for drawing text using a bitmap font.
 * @since	2.5.0
 */
class BitmapText extends Graphic
{
	static var FORMAT_TAG_RE = ~/<(([A-Za-z_-]+)\/?|(\/[A-Za-z_-]+))>/;

	static var formatTags:Map<String, Array<TextOpcode>> = [
		"br" => [NewLine(0, 0, Left)],
		"left" => [Align(Left)],
		"/left" => [Align(Left)],
		"right" => [Align(Right)],
		"/right" => [Align(Left)],
		"center" => [Align(Center)],
		"/center" => [Align(Left)],
	];

	static var _colorStack:Array<Color> = new Array();
	static var _alphaStack:Array<Float> = new Array();
	static var _scaleStack:Array<Float> = new Array();
	static var _moveStack:Array<GlyphMoveFunction> = new Array();
	static var _renderPoint:Point = new Point();

	/**
	 * Define a new format tag which can be used to modify the formatting of a
	 * subset of text.
	 * @param tag The tag name, e.g. "red" (used as "<red>my text</red>"). Will
	 *  			automatically define the appropriate close tag.
	 * @param color The color of text inside this tag.
	 * @param alpha The alpha of text inside this tag.
	 * @param scale The scale of text inside this tag.
	 * @since 4.0.0
	 */
	public static function defineFormatTag(tag:String, ?color:Color, ?alpha:Float, ?scale:Float):Void
	{
		var tagOps:Array<TextOpcode> = new Array();
		var closeTagOps:Array<TextOpcode> = new Array();
		if (color != null)
		{
			tagOps.push(SetColor(color));
			closeTagOps.push(PopColor);
		}
		if (alpha != null)
		{
			tagOps.push(SetAlpha(alpha));
			closeTagOps.push(PopAlpha);
		}
		if (scale != null)
		{
			tagOps.push(SetScale(scale));
			closeTagOps.push(PopScale);
		}
		var closeTag = '/$tag';
		formatTags[tag] = tagOps;
		formatTags[closeTag] = closeTagOps;
	}

	/**
	 * Define a markup tag which can be used to render an Image. Should be used
	 * as a self-closed tag.
	 * @param tag The tag name, e.g. "my-img" (used as "<my-img/>")
	 * @param image An Image to be rendered. The Image's coordinates, origin,
	 *  			angle and scale can be modified.
	 * @since 4.0.0
	 */
	public static function defineImageTag(tag:String, image:Image)
	{
		formatTags[tag] = [Image(image)];
	}

	public static function defineMoveTag(tag:String, func:GlyphMoveFunction)
	{
		var closeTag = '/$tag';
		formatTags[tag] = [MoveText(func)];
		formatTags[closeTag] = [PopMoveText];
	}

	/**
	 * Undefine an existing XML tag.
	 * @since 4.0.0
	 */
	public static function removeTag(tag:String)
	{
		if (formatTags.exists(tag)) formatTags.remove(tag);
		var closeTag = '/$tag';
		if (formatTags.exists(closeTag)) formatTags.remove(closeTag);
	}

	@:isVar public var textWidth(get, set):Int = 0;
	inline function get_textWidth()
	{
		if (_dirty) parseText();
		return textWidth;
	}
	inline function set_textWidth(v:Int) return textWidth = v;

	@:isVar public var textHeight(get, set):Int = 0;
	inline function get_textHeight()
	{
		if (_dirty) parseText();
		return textHeight;
	}
	inline function set_textHeight(v:Int) return textHeight = v;

	public var width(default, set):Float = 0;
	inline function set_width(v:Float)
	{
		if (v != width) _dirty = true;
		return width = v;
	}
	public var height(default, set):Float = 0;
	inline function set_height(v:Float)
	{
		if (v != height) _dirty = true;
		return height = v;
	}

	/**
	 * Font size, in points.
	 */
	public var size(default, set):Int = 0;
	inline function set_size(v:Int)
	{
		if (v != size) _dirty = true;
		return size = v;
	}
	public var wrap(default, set):Bool = false;
	inline function set_wrap(v:Bool)
	{
		if (v != wrap) _dirty = true;
		return wrap = v;
	}

	public var scale(default, set):Float = 1;
	inline function set_scale(v:Float)
	{
		if (v != scale) _dirty = true;
		return scale = v;
	}
	public var scaleX(default, set):Float = 1;
	inline function set_scaleX(v:Float)
	{
		if (v != scaleX) _dirty = true;
		return scaleX = v;
	}
	public var scaleY(default, set):Float = 1;
	inline function set_scaleY(v:Float)
	{
		if (v != scaleY) _dirty = true;
		return scaleY = v;
	}

	public var lineSpacing(default, set):Int = 0;
	inline function set_lineSpacing(v:Int)
	{
		if (v != lineSpacing) _dirty = true;
		return lineSpacing = v;
	}
	public var charSpacing(default, set):Int = 0;
	inline function set_charSpacing(v:Int)
	{
		if (v != charSpacing) _dirty = true;
		return charSpacing = v;
	}

	/**
	 * How many characters of text to render. If -1, render the entire string;
	 * if less than the number of visible characters, will end early. Images
	 * and line breaks count as one character each.
	 */
	public var displayCharCount:Int = -1;

	var opCodes:Array<TextOpcode> = new Array();

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
	public function new(text:String, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, ?options:BitmapTextOptions)
	{
		super();

		if (options == null) options = {};

		// defaults
		if (!Reflect.hasField(options, "font"))      options.font      = HXP.defaultFont + ".png";
		if (!Reflect.hasField(options, "size"))      options.size      = null;
		if (!Reflect.hasField(options, "color"))     options.color     = 0xFFFFFF;
		if (!Reflect.hasField(options, "wordWrap"))  options.wordWrap  = false;

		// load the font as a BitmapFontAtlas
		var font:IBitmapFont = AssetManager.getBitmapFont(options.font);
		if (font == null)
		{
			font = BitmapFontAtlas.getFont(options.font, options.format, options.extraParams);
		}

		_font = font;

		// failure to load
		if (_font == null)
			throw "Invalid font glyphs provided.";

		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		wrap = options.wordWrap;
		size = options.size;

		autoWidth = (width == 0);
		autoHeight = (height == 0);

		this.color = options.color;
		this.text = text != null ? text : "";
	}

	public var text(default, set):String;
	function set_text(text:String):String
	{
		if (this.text != text)
		{
			this.text = text;

			parseText();
		}

		return text;
	}

	/**
	 * Parse text and any formatting tags into a list of rendering opcodes.
	 * Handles newlines and word wrapping.
	 */
	function parseText():Void
	{
		// clear current opcode list
		HXP.clear(opCodes);
		HXP.clear(_scaleStack);

		_scaleStack.push(1);
		var fsx:Float = HXP.screen.fullScaleX,
			fsy:Float = HXP.screen.fullScaleY;
		var sx:Float = size * scale * scaleX,
			sy:Float = size * scale * scaleY;
		var lineHeight:Float = _font.getLineHeight(sy * fsy) / fsy,
			lineSpacing:Float = lineSpacing * scale * scaleY,
			thisLineHeight:Float = lineHeight;
		var remaining = text;
		var cursorX:Float = 0,
			cursorY:Float = 0,
			block:String = "",
			currentWord:String = "",
			currentWordLength:Float = 0,
			currentScale:Float = 1,
			currentAlign:AlignType = AlignType.Left;

		var textWidth = 0;
		opCodes.push(null);
		var newLineIndex:Int = 0;

		inline function flushWord()
		{
			if (currentWord != "")
			{
				block += currentWord;
				currentWord = "";
				cursorX += currentWordLength;
				if (cursorX > textWidth) textWidth = Std.int(cursorX);
				currentWordLength = 0;
			}
		}
		inline function flushBlock()
		{
			if (block != "")
			{
				opCodes.push(TextBlock(block));
				block = "";
			}
		}
		inline function addNewLine()
		{
			opCodes[newLineIndex] = NewLine(Std.int(cursorX), Std.int(thisLineHeight), currentAlign);
			cursorX = 0;
			cursorY += thisLineHeight + lineSpacing;
			thisLineHeight = lineHeight;
			opCodes.push(null);
			newLineIndex = opCodes.length - 1;
		}

		while (true)
		{
			var matched = FORMAT_TAG_RE.match(remaining);
			var line:String = matched ? FORMAT_TAG_RE.matchedLeft() : remaining;
			if (line.length > 0)
			{
				for (i in 0 ... line.length)
				{
					var char:String = line.charAt(i);
					switch (char)
					{
						case "\n":
							flushWord();
							flushBlock();
							addNewLine();
						case " ", "-":
							var maxFullScale = sx * fsx;
							var gd = _font.getChar(char, maxFullScale * currentScale);
							var charWidth = gd.xAdvance * gd.scale / fsx;
							currentWord += char;
							currentWordLength += charSpacing * currentScale + charWidth;
							flushWord();
						default:
							currentWord += char;
							var maxFullScale = sx * fsx;
							var gd = _font.getChar(char, maxFullScale * currentScale);
							var charWidth = gd.xAdvance * gd.scale / fsx;
							currentWordLength += charWidth;
							if (wrap && cursorX + currentWordLength > width)
							{
								flushBlock();
								addNewLine();
							}
							currentWordLength += charSpacing * currentScale;
					}
				}
			}

			if (matched)
			{
				var tag:String = FORMAT_TAG_RE.matched(2);
				if (tag == null) tag = FORMAT_TAG_RE.matched(3);
				if (tag != null && formatTags.exists(tag))
				{
					flushWord();
					flushBlock();
					for (tag in formatTags[tag])
					{
						switch (tag)
						{
							case Image(image):
								var imageWidth = ((image.width * image.scale * image.scaleX * this.scale * this.scaleX) + charSpacing) * currentScale;
								cursorX += imageWidth;
								currentWordLength = 0;
								if (wrap && cursorX > width)
								{
									addNewLine();
									cursorX = imageWidth;
								}
								opCodes.push(tag);
								thisLineHeight = Math.max(thisLineHeight, currentScale * image.height * image.scale * image.scaleY * this.scale * this.scaleY);
								if (cursorX > textWidth) textWidth = Std.int(cursorX);
							case SetScale(scale):
								_scaleStack.push(currentScale = scale);
								opCodes.push(tag);
								thisLineHeight = Math.max(thisLineHeight, lineHeight * currentScale);
							case PopScale:
								if (_scaleStack.length > 1) _scaleStack.pop();
								currentScale = _scaleStack[_scaleStack.length - 1];
								thisLineHeight = Math.max(thisLineHeight, lineHeight * currentScale);
								opCodes.push(tag);
							case NewLine(_, _, _):
								addNewLine();
							case Align(alignType):
								if (cursorX > 0)
								{
									addNewLine();
								}
								if (alignType != Left && !autoWidth) textWidth = Std.int(width);
								currentAlign = alignType;
							default:
								opCodes.push(tag);
						}
					}
				}
				else
				{
					throw 'Unrecognized format tag: <$tag>';
				}
				remaining = FORMAT_TAG_RE.matchedRight();
			}
			else break;
		}
		flushWord();
		flushBlock();
		if (opCodes[newLineIndex] == null) opCodes[newLineIndex] = NewLine(cursorX, thisLineHeight, currentAlign);
		this.textWidth = textWidth;
		if (autoWidth) width = textWidth;
		this.textHeight = Std.int(cursorY + (cursorX > 0 ? thisLineHeight : 0));

		_scaleStack.pop();
		_dirty = false;
	}

	@:dox(hide)
	override public function render(layer:Int, point:Point, camera:Camera)
	{
		// determine drawing location
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);
		// make sure our format stacks are clear
		HXP.clear(_colorStack);
		HXP.clear(_alphaStack);
		HXP.clear(_scaleStack);
		HXP.clear(_moveStack);

		_colorStack.push(color);
		_alphaStack.push(alpha);
		_scaleStack.push(1);

		var sx = scale * scaleX * size,
			sy = scale * scaleY * size;
		var lineHeight:Float = _font.getLineHeight(sy * fsy) / fsy,
			lineSpacing:Float = lineSpacing * scale * scaleY,
			thisLineHeight:Float = 0,
			lineOffsetX:Float = 0;
		var currentColor:Color = color,
			currentAlpha:Float = alpha,
			currentScale:Float = 1,
			cursorX:Float = 0,
			cursorY:Float = 0,
			charCount:Int = 0;
		inline function getRenderPoint(char:String = "")
		{
			var point = _renderPoint;
			point.setTo(cursorX, cursorY);
			for (func in _moveStack)
			{
				point = func(char, point);
			}
			return point;
		}
		for (op in opCodes)
		{
			if (displayCharCount > -1 && charCount >= displayCharCount) break;
			switch (op)
			{
				case SetColor(color):
					_colorStack.push(currentColor = color);
				case SetAlpha(alpha):
					_alphaStack.push(currentAlpha = alpha);
				case SetScale(scale):
					_scaleStack.push(currentScale = scale);
				case PopColor:
					if (_colorStack.length > 1) _colorStack.pop();
					currentColor = _colorStack[_colorStack.length - 1];
				case PopAlpha:
					if (_alphaStack.length > 1) _alphaStack.pop();
					currentAlpha = _alphaStack[_alphaStack.length - 1];
				case PopScale:
					if (_scaleStack.length > 1) _scaleStack.pop();
					currentScale = _scaleStack[_scaleStack.length - 1];
				case TextBlock(text):
					// render a block of text on this line
					for (i in 0 ... text.length)
					{
						if (displayCharCount > -1 && charCount >= displayCharCount) break;
						++charCount;
						var char = text.charAt(i);
						var maxFullScale = sx * fsx;
						var gd = _font.getChar(char, maxFullScale * currentScale);

						if (char == ' ')
						{
							// it's a space, just move the cursor
							cursorX += gd.xAdvance * gd.scale / fsx;
						}
						else
						{
							// draw the character
							var point = getRenderPoint(char);
							var x = point.x + lineOffsetX + gd.xOffset * gd.scale / fsx,
								y = point.y + gd.yOffset * gd.scale * sy / maxFullScale + thisLineHeight - (lineHeight * currentScale);
							gd.region.draw(
								(_point.x + x) * fsx, (_point.y + y) * fsy,
								layer, gd.scale, gd.scale * sy * fsy / maxFullScale, 0,
								currentColor.red, currentColor.green, currentColor.blue, currentAlpha,
								shader, smooth, blend
							);
							// advance cursor position
							cursorX += gd.xAdvance * gd.scale / fsx + charSpacing * currentScale;
						}
					}
				case NewLine(lineWidth, lineHeight, alignType):
					// advance to next line and set the new line height
					cursorX = 0;
					cursorY += thisLineHeight + (thisLineHeight > 0 ? lineSpacing : 0);
					lineOffsetX = Std.int((width - lineWidth) * switch (alignType) {
						case Left: 0;
						case Center: 0.5;
						case Right: 1;
					});
					thisLineHeight = lineHeight;
					++charCount;
				case Image(image):
					// draw the image
					var originalX = image.x,
						originalY = image.y,
						originalScaleX = image.scaleX,
						originalScaleY = image.scaleY;
					image.originX = image.originY = 0;
					var point = getRenderPoint();
					image.x += _point.x + point.x + lineOffsetX;
					image.y += _point.y + point.y + thisLineHeight - image.height * image.scale * image.scaleY * currentScale * this.scale * this.scaleY;
					image.color = currentColor;
					image.alpha = currentAlpha;
					image.scaleX *= this.scale * this.scaleX * currentScale;
					image.scaleY *= this.scale * this.scaleY * currentScale;
					image.render(layer, HXP.zero, HXP.zeroCamera);
					image.x = originalX;
					image.y = originalY;
					image.scaleX = originalScaleX;
					image.scaleY = originalScaleY;
					// advance cursor position
					cursorX += ((image.width * image.scale * image.scaleX * this.scale * this.scaleX) + charSpacing) * currentScale;
					++charCount;
				case Align(_): {}
				case MoveText(func):
					_moveStack.push(func);
				case PopMoveText:
					_moveStack.pop();
			}
		}

		_colorStack.pop();
		_alphaStack.pop();
		_scaleStack.pop();
	}

	var autoWidth:Bool = false;
	var autoHeight:Bool = false;
	var _dirty:Bool = false;
	var _font:IBitmapFont;
}
