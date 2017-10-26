package haxepunk.graphics.text;

import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.utils.Color;
import haxepunk.graphics.text.BitmapFontAtlas.BitmapFontFormat;

/**
 * Text option including the font, size, color, font format...
 */
typedef BitmapTextOptions =
{
	> TextOptions,
	@:optional var format:BitmapFontFormat;
	@:optional var extraParams:Dynamic;
};

typedef FormatTagOptions =
{
	@:optional var color:Color;
	@:optional var alpha:Float;
	@:optional var scale:Float;
	@:optional var size:Int;
}

@:enum
abstract AlignType(Int)
{
	var Left = 0;
	var Center = 1;
	var Right = 2;

	public var floatValue(get, never):Float;
	inline function get_floatValue() return switch (this)
	{
		case Center: 0.5;
		case Right: 1;
		default: 0;
	};
}

class RenderData
{
	public var char:Null<String>;
	public var img:Null<Image>;
	public var x:Float = 0;
	public var y:Float = 0;
	public var color:Color = Color.White;
	public var alpha:Float = 1;
	public var scale:Float = 1;

	public function new() {}
}

typedef CustomRenderFunction = BitmapText -> RenderData -> Void;

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
	SetSize(size:Int);
	TextBlock(text:String);
	NewLine(width:Float, height:Float, align:AlignType);
	Image(image:Image, padding:Int);
	Align(alignType:AlignType);
	Custom(f:CustomRenderFunction);
	PopColor;
	PopAlpha;
	PopScale;
	PopSize;
	PopCustom;
}

/**
 * An object for drawing text using a bitmap font.
 * @since	2.5.0
 */
class BitmapText extends Graphic
{
	static var FORMAT_TAG_RE = ~/<(([A-Za-z_-]+)\/?|(\/[A-Za-z_-]+))>/;

	static var formatTags:Map<String, Array<TextOpcode>> = [
		// newline
		"br" => [NewLine(0, 0, Left)],
		// alignment
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
	static var _sizeStack:Array<Int> = new Array();
	static var _word:Array<TextOpcode> = new Array();
	static var _customStack:Array<CustomRenderFunction> = new Array();
	static var _renderData:RenderData = new RenderData();

	/**
	 * Define a new format tag which can be used to modify the formatting of a
	 * subset of text.
	 * @param tag The tag name, e.g. "red" (used as "<red>my text</red>"). Will
	 *  			automatically define the appropriate close tag.
	 * @param options Formatting options for this tag.
	 * @since 4.0.0
	 */
	public static function defineFormatTag(tag:String, options:FormatTagOptions):Void
	{
		if (formatTags.exists(tag)) throw 'Duplicate format tag: <$tag> already exists';
		var tagOps:Array<TextOpcode> = new Array();
		var closeTagOps:Array<TextOpcode> = new Array();
		if (Reflect.hasField(options, 'color'))
		{
			tagOps.push(SetColor(options.color));
			closeTagOps.push(PopColor);
		}
		if (Reflect.hasField(options, 'alpha'))
		{
			tagOps.push(SetAlpha(options.alpha));
			closeTagOps.push(PopAlpha);
		}
		if (Reflect.hasField(options, 'scale'))
		{
			tagOps.push(SetScale(options.scale));
			closeTagOps.push(PopScale);
		}
		if (Reflect.hasField(options, 'size'))
		{
			tagOps.push(SetSize(options.size));
			closeTagOps.push(PopSize);
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
	public static function defineImageTag(tag:String, image:Image, padding:Int=0)
	{
		if (formatTags.exists(tag)) throw 'Duplicate format tag: <$tag> already exists';
		formatTags[tag] = [Image(image, padding)];
	}

	/**
	 * Define a custom text rendering tag. Custom tags include a function which
	 * takes the BitmapText and a RenderData object as parameters, and are
	 * called before a glyph or image are rendered. Any modifications to the
	 * RenderData object will be reflected in the rendered text; however, note
	 * that you shouldn't hold onto the object reference, as it may be reused.
	 * @param tag The tag name, e.g. "shake" (used as "<shake>text</shake>")
	 * @param func The CustomRenderFunction
	 * @since 4.0.0
	 */
	public static function defineCustomTag(tag:String, func:CustomRenderFunction)
	{
		if (formatTags.exists(tag)) throw 'Duplicate format tag: <$tag> already exists';
		var closeTag = '/$tag';
		formatTags[tag] = [Custom(func)];
		formatTags[closeTag] = [PopCustom];
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

	/**
	 * The total number of visible characters (or images) in the text.
	 * `displayCharCount` can be between 0 and this number.
	 */
	public var charCount(default, null):Int = 0;

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
			_dirty = true;
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
		HXP.clear(_sizeStack);
		HXP.clear(_scaleStack);
		HXP.clear(_colorStack);
		HXP.clear(_alphaStack);
		HXP.clear(_word);

		_sizeStack.push(size);
		_scaleStack.push(1);
		_colorStack.push(color);
		_alphaStack.push(alpha);
		var fsx:Float = HXP.screen.fullScaleX,
			fsy:Float = HXP.screen.fullScaleY;
		var sx:Float = size * scale * scaleX,
			sy:Float = size * scale * scaleY;
		var lineHeight:Float = _font.getLineHeight(sy * fsy) / fsy,
			lineSpacing:Float = lineSpacing * scale * scaleY,
			thisLineHeight:Float = 0;
		var remaining = text;
		var cursorX:Float = 0,
			cursorY:Float = 0,
			block:String = "",
			currentWord:String = "",
			wordLength:Float = 0,
			wordHeight:Float = 0,
			currentScale:Float = 1,
			currentSizeRatio:Float = 1,
			currentAlign:AlignType = AlignType.Left,
			wrapping:Bool = false;

		var textWidth = 0;
		charCount = 0;
		opCodes.push(null);
		var newLineIndex:Int = 0;

		inline function pushOpcode(opCode:TextOpcode)
		{
			if (opCode == null || opCodes[opCodes.length - 1] == null)
			{
				opCodes.push(opCode);
			}
			else switch (opCode)
			{
				case TextBlock(txt2):
					switch (opCodes[opCodes.length - 1])
					{
						case TextBlock(txt1):
							opCodes[opCodes.length - 1] = TextBlock(txt1 + txt2);
						default:
							opCodes.push(opCode);
					}
				default:
					opCodes.push(opCode);
			}
		}
		// start the next line
		inline function addNewLine()
		{
			opCodes[newLineIndex] = NewLine(cursorX, thisLineHeight, currentAlign);
			cursorX = 0;
			cursorY += thisLineHeight + (cursorY == 0 ? 0 : lineSpacing);
			thisLineHeight = lineHeight * currentScale * currentSizeRatio;
			opCodes.push(null);
			newLineIndex = opCodes.length - 1;
			++charCount;
		}
		// flush some text to the current word
		inline function flushCurrentWord()
		{
			if (currentWord != "")
			{
				_word.push(TextBlock(currentWord));
				currentWord = "";
			}
		}
		// add a word of text
		inline function flushWord()
		{
			flushCurrentWord();
			if (_word.length != 0)
			{
				if (wrap && cursorX + wordLength > width)
				{
					addNewLine();
					cursorX = wordLength;
				}
				else
				{
					cursorX += wordLength;
				}
				if (cursorX > textWidth) textWidth = Std.int(cursorX);
				for (opCode in _word)
				{
					pushOpcode(opCode);
				}
				thisLineHeight = Math.max(wordHeight, thisLineHeight);
				HXP.clear(_word);
				wordLength = 0;
				wordHeight = 0;
			}
		}

		while (true)
		{
			var matched = FORMAT_TAG_RE.match(remaining);
			var line:String = matched ? FORMAT_TAG_RE.matchedLeft() : remaining;
			if (line.length > 0)
			{
				var i:Int = 0;
				while (i < line.length)
				{
					var char:String = line.charAt(i);
					wordHeight = Math.max(wordHeight, lineHeight * currentScale * currentSizeRatio);
					inline function addChar()
					{
						var maxFullScale = sx * fsx;
						var gd = _font.getChar(char, maxFullScale * currentScale * currentSizeRatio);
						var charWidth = gd.xAdvance * gd.scale / fsx;
						currentWord += char;
						wordLength += charWidth + charSpacing * currentScale * currentSizeRatio;
						++charCount;
					}
					switch (char)
					{
						case "\n":
							flushWord();
							addNewLine();
						case " ":
							addChar();
							flushWord();
						case "-":
							var hyphen = currentWord != "";
							if (hyphen && i < line.length - 1)
							{
								var nextChar = line.charAt(i + 1);
								if (nextChar == " " || nextChar == "-") hyphen = false;
							}
							addChar();
							if (hyphen) flushWord();
						default:
							// treat tabs as non-breaking spaces
							if (char == "	") char = " ";
							addChar();
					}
					++i;
				}
			}

			if (matched)
			{
				var tag:String = FORMAT_TAG_RE.matched(2);
				if (tag == null) tag = FORMAT_TAG_RE.matched(3);
				if (tag != null && formatTags.exists(tag))
				{
					flushCurrentWord();
					for (tag in formatTags[tag])
					{
						switch (tag)
						{
							case Image(image, padding):
								var imageWidth = ((image.width * image.scale * image.scaleX * this.scale * this.scaleX) + charSpacing) * currentScale;
								_word.push(tag);
								wordLength += imageWidth + padding * 2;
								wordHeight = Math.max(wordHeight, image.height * currentScale * image.scale * image.scaleY * this.scale * this.scaleY);
								if (cursorX > textWidth) textWidth = Std.int(cursorX);
								++charCount;
							case SetSize(size):
								_sizeStack.push(size);
								currentSizeRatio = size / this.size;
								_word.push(tag);
							case PopSize:
								if (_sizeStack.length > 1) _sizeStack.pop();
								currentSizeRatio = _sizeStack[_sizeStack.length - 1] / this.size;
								_word.push(SetSize(_sizeStack[_sizeStack.length - 1]));
							case SetScale(scale):
								_scaleStack.push(currentScale = scale);
								_word.push(tag);
							case PopScale:
								if (_scaleStack.length > 1) _scaleStack.pop();
								currentScale = _scaleStack[_scaleStack.length - 1];
								_word.push(SetScale(currentScale));
							case SetColor(color):
								_colorStack.push(color);
								_word.push(tag);
							case PopColor:
								if (_colorStack.length > 1) _colorStack.pop();
								_word.push(SetColor(_colorStack[_colorStack.length - 1]));
							case SetAlpha(alpha):
								_alphaStack.push(alpha);
								_word.push(tag);
							case PopAlpha:
								if (_alphaStack.length > 1) _alphaStack.pop();
								_word.push(SetAlpha(_alphaStack[_alphaStack.length - 1]));
							case NewLine(_, _, _):
								flushWord();
								addNewLine();
							case Align(alignType):
								flushWord();
								if (cursorX > 0)
								{
									addNewLine();
								}
								if (alignType != Left && !autoWidth) textWidth = Std.int(width);
								currentAlign = alignType;
							default:
								_word.push(tag);
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
		if (opCodes[newLineIndex] == null) opCodes[newLineIndex] = NewLine(cursorX, thisLineHeight, currentAlign);
		this.textWidth = textWidth;
		if (autoWidth) width = textWidth;
		this.textHeight = Std.int(cursorY + (cursorX > 0 ? thisLineHeight : 0));

		_dirty = false;
	}

	@:dox(hide)
	override public function render(point:Point, camera:Camera)
	{
		if (_dirty) parseText();
		HXP.clear(_customStack);
		var pixelPerfect = isPixelPerfect(camera);

		// determine drawing location
		var fsx = camera.fullScaleX,
			fsy = camera.fullScaleY;

		_point.x = point.x + floorX(camera, x) - floorX(camera, camera.x * scrollX);
		_point.y = point.y + floorY(camera, y) - floorY(camera, camera.y * scrollY);

		var sx = scale * scaleX * size,
			sy = scale * scaleY * size;
		var lineHeight:Float = _font.getLineHeight(sy * fsy) / fsy,
			lineSpacing:Float = lineSpacing * scale * scaleY,
			thisLineHeight:Float = 0,
			lineOffsetX:Float = 0;
		var currentColor:Color = color,
			currentAlpha:Float = alpha,
			currentScale:Float = 1,
			currentSizeRatio:Float = 1,
			cursorX:Float = 0,
			cursorY:Float = 0,
			charCount:Int = 0;
		inline function applyCustomFunctions(data:RenderData)
		{
			for (func in _customStack) func(this, data);
		}
		for (op in opCodes)
		{
			if (displayCharCount > -1 && charCount >= displayCharCount) break;
			switch (op)
			{
				case SetColor(color):
					currentColor = color;
				case SetAlpha(alpha):
					currentAlpha = alpha;
				case SetScale(scale):
					currentScale = scale;
				case SetSize(size):
					currentSizeRatio = size / this.size;
				case TextBlock(text):
					// render a block of text on this line
					for (i in 0 ... text.length)
					{
						if (displayCharCount > -1 && charCount >= displayCharCount) break;
						++charCount;
						var char = text.charAt(i);
						var maxFullScale = sx * fsx;
						var gd = _font.getChar(char, maxFullScale * currentScale * currentSizeRatio);

						if (char == ' ')
						{
							// it's a space, just move the cursor
							cursorX += gd.xAdvance * gd.scale / fsx;
						}
						else
						{
							// draw the character
							_renderData.char = char;
							_renderData.img = null;
							_renderData.x = cursorX;
							_renderData.y = cursorY;
							_renderData.color = currentColor;
							_renderData.alpha = currentAlpha;
							_renderData.scale = currentScale;
							applyCustomFunctions(_renderData);
							var x = _renderData.x + lineOffsetX + gd.xOffset * gd.scale / fsx,
								y = _renderData.y + gd.yOffset * gd.scale * sy / maxFullScale + thisLineHeight - (lineHeight * currentScale * currentSizeRatio);
							gd.region.draw(
								(_point.x + floorX(camera, x)) * fsx,
								(_point.y + floorY(camera, y)) * fsy,
								gd.scale, gd.scale * sy * fsy / maxFullScale, 0,
								_renderData.color, _renderData.alpha,
								shader, smooth, blend, clipRect, flexibleLayer
							);
							// advance cursor position
							cursorX += gd.xAdvance * gd.scale / fsx + charSpacing * currentScale * currentSizeRatio;
						}
					}
				case NewLine(lineWidth, lineHeight, alignType):
					// advance to next line and set the new line height
					cursorX = 0;
					cursorY += thisLineHeight + ((cursorY > 0 && thisLineHeight > 0) ? lineSpacing : 0);
					lineOffsetX = (width - lineWidth) * alignType.floatValue;
					thisLineHeight = lineHeight;
					if (cursorY != 0) ++charCount;
				case Image(image, padding):
					// draw the image
					var originalX = image.x,
						originalY = image.y,
						originalScaleX = image.scaleX,
						originalScaleY = image.scaleY;
					image.originX = image.originY = 0;
					_renderData.char = null;
					_renderData.img = image;
					_renderData.x = cursorX;
					_renderData.y = cursorY;
					_renderData.color = currentColor;
					_renderData.alpha = currentAlpha;
					_renderData.scale = currentScale;
					applyCustomFunctions(_renderData);
					image.x = _point.x + _renderData.x + lineOffsetX + originalX + padding;
					image.y = _point.y + _renderData.y + thisLineHeight + originalY - image.height * image.scale * image.scaleY * _renderData.scale * this.scale * this.scaleY;
					image.color = _renderData.color;
					image.alpha = _renderData.alpha;
					image.scaleX *= this.scale * this.scaleX * _renderData.scale;
					image.scaleY *= this.scale * this.scaleY * _renderData.scale;
					image.pixelSnapping = pixelPerfect;
					image.render(HXP.zero, HXP.zeroCamera);
					image.x = originalX;
					image.y = originalY;
					image.scaleX = originalScaleX;
					image.scaleY = originalScaleY;
					image.flexibleLayer = flexibleLayer;
					// advance cursor position
					cursorX += ((image.width * image.scale * image.scaleX * this.scale * this.scaleX) + charSpacing + padding * 2) * _renderData.scale;
					++charCount;
				case Custom(func):
					_customStack.push(func);
				case PopCustom:
					_customStack.pop();
				case PopSize, PopScale, PopColor, PopAlpha: {}
				case Align(_): {}
			}
		}
	}

	var autoWidth:Bool = false;
	var autoHeight:Bool = false;
	var _dirty:Bool = false;
	var _font:IBitmapFont;
}
