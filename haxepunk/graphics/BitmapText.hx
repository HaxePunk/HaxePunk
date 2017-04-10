package haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.RenderMode;
import haxepunk.Graphic;
import haxepunk.graphics.Text;
import haxepunk.graphics.atlas.BitmapFontAtlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;

@:dox(hide)
typedef RenderFunction = AtlasRegion -> GlyphData -> Color -> Float -> Float -> Float -> Float -> Void;
typedef RenderImageFunction = Image -> Color -> Float -> Float -> Float -> Float -> Void;

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
	NextLine;
	Image(img:Image);
	PopColor;
	PopAlpha;
	PopScale;
}

/**
 * An object for drawing text using a bitmap font.
 * @since	2.5.0
 */
class BitmapText extends Graphic
{
	static var FORMAT_TAG_RE = ~/<(([A-Za-z_-]+)\/?|(\/[A-Za-z_-]+))>/;

	static var formatTags:Map<String, Array<TextOpcode>> = [
		"br" => [NextLine],
	];

	static var _colorStack:Array<Color> = new Array();
	static var _alphaStack:Array<Float> = new Array();
	static var _scaleStack:Array<Float> = new Array();

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

	public var lineSpacing:Int = 0;
	public var charSpacing:Int = 0;

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
			_rect = HXP.rect;
			_colorTransform = new ColorTransform();
		}

		this.color = options.color;
		this.text = text != null ? text : "";
		_bufferDirty = true;

		smooth = (HXP.stage.quality != LOW);
	}

	public var color(default, set):Color;
	function set_color(value:Color):Int
	{
		_bufferDirty = true;
		return color = value;
	}

	public var alpha(default, set):Float=1;
	function set_alpha(value:Float)
	{
		_bufferDirty = true;
		return alpha = value;
	}

	public var text(default, set):String;
	function set_text(text:String):String
	{
		if (this.text != text)
		{
			this.text = text;

			parseText();

			textWidth = textHeight = 0;
			if (blit) _bufferDirty = true;
			else computeTextSize();
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
		while (opCodes.length > 0)
		{
			opCodes.pop();
		}
		while (_scaleStack.length > 0)
		{
			_scaleStack.pop();
		}
		_scaleStack.push(1);
		var spaceWidth = _font.glyphData.get(' ').xAdvance;
		var fontScale = size / _font.fontSize;
		var sx:Float = scale * scaleX * fontScale,
			sy:Float = scale * scaleY * fontScale;
		var currentLine:Float = 0;
		var remaining = text;
		var cursorX:Float = 0,
			block:String = "",
			currentWord:String = "",
			currentWordLength:Float = 0,
			currentScale:Float = 1;
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
							if (currentWord != "")
							{
								block += currentWord;
								currentWord = "";
							}
							if (block != "")
							{
								opCodes.push(TextBlock(block));
								block = "";
							}
							opCodes.push(NextLine);
							currentWordLength = cursorX = 0;
						case " ", "-":
							block += currentWord + char;
							currentWord = "";
							var charWidth = _font.glyphData.exists(char)
								? _font.glyphData.get(char).xAdvance
								: 0;
							cursorX += currentWordLength + (charSpacing + charWidth) * sx * currentScale;
							currentWordLength = 0;
						default:
							currentWord += char;
							if (wrap)
							{
								var charWidth = _font.glyphData.exists(char)
									? _font.glyphData.get(char).xAdvance
									: 0;
								currentWordLength += charWidth * sx * currentScale;
								if (cursorX + currentWordLength > width)
								{
									if (block != "")
									{
										opCodes.push(TextBlock(block));
										block = "";
									}
									opCodes.push(NextLine);
									cursorX = 0;
								}
								currentWordLength += charSpacing * sx * currentScale;
							}
					}
				}
			}

			if (matched)
			{
				var tag:String = FORMAT_TAG_RE.matched(2);
				if (tag == null) tag = FORMAT_TAG_RE.matched(3);
				if (tag != null && formatTags.exists(tag))
				{
					for (tag in formatTags[tag])
					{
						if (currentWord != "")
						{
							block += currentWord;
							cursorX += currentWordLength + charSpacing * sx * currentScale;
							currentWord = "";
						}
						if (block != "")
						{
							opCodes.push(TextBlock(block));
							block = "";
						}
						switch (tag)
						{
							case Image(img):
								cursorX += currentWordLength + (img.width * img.scale * img.scaleX + charSpacing) * sx * currentScale;
								currentWordLength = 0;
								if (wrap && cursorX > width)
								{
									opCodes.push(NextLine);
									cursorX = (img.width * img.scale * img.scaleX + charSpacing) * sx * currentScale;
								}
								opCodes.push(tag);

							case SetScale(scale):
								_scaleStack.push(currentScale = scale);
								opCodes.push(tag);
							case PopScale:
								if (_scaleStack.length > 1) _scaleStack.pop();
								currentScale = _scaleStack[_scaleStack.length - 1];
								opCodes.push(tag);
							case NextLine:
								opCodes.push(NextLine);
								currentWordLength = cursorX = 0;
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
		if (currentWord != "")
		{
			block += currentWord;
		}
		if (block != "")
		{
			opCodes.push(TextBlock(block));
		}
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
	public function updateBuffer()
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
			w = Math.ceil(autoWidth ? (textWidth / sx) : (width / sx));
			h = Math.ceil(autoHeight ? (textHeight / sy) : (height / sy));
		}
		else
		{
			w = Math.ceil(width / sx);
			h = Math.ceil(height / sy);
		}
		w = Math.ceil(w);
		h = Math.ceil(h + _font.lineHeight + lineSpacing);

		// create or clear the buffer if necessary
		if (_buffer == null || _buffer.width != w || _buffer.height != h)
		{
			if (_buffer != null) _buffer.dispose();
			_buffer = HXP.createBitmap(w, h, true, 0);
		}
		else
		{
			_buffer.fillRect(_buffer.rect, Color.Black);
		}

		// make a pass through each character, copying it onto the buffer
		renderFont(function(region:AtlasRegion, gd:GlyphData, color:Color, alpha:Float, scale:Float, x:Float, y:Float)
		{
			_rect.setTo(x / sx, y / sy, gd.rect.width * scale, gd.rect.height * scale);
			_matrix.setTo(scale, 0, 0, scale, (x / sx - gd.rect.x * scale), (y / sy - gd.rect.y * scale));
			_colorTransform.redMultiplier = color.red;
			_colorTransform.greenMultiplier = color.green;
			_colorTransform.blueMultiplier = color.blue;
			_colorTransform.alphaMultiplier = alpha;
			_buffer.draw(_set, _matrix, _colorTransform, null, _rect, smooth);
		}, function(image:Image, color:Color, alpha:Float, scale:Float, x:Float, y:Float) {
			var originalX = image.x,
				originalY = image.y,
				originalScaleX = image.scaleX,
				originalScaleY = image.scaleY;
			image.x = (image.x + x) / sx;
			image.y = (image.y + y) / sy;
			image.color = color;
			image.alpha = alpha;
			image.scaleX *= scale / sx;
			image.scaleY *= scale / sy;
			image.render(_buffer, HXP.zero, HXP.zeroCamera);
			image.x = originalX;
			image.y = originalY;
			image.scaleX = originalScaleX;
			image.scaleY = originalScaleY;
		});
	}

	/*
	 * Loops through the text, drawing each character on each line.
	 * @param renderFunction    Function to render each character.
	 */
	inline function renderFont(?renderFunction:RenderFunction, ?renderImageFunction:RenderImageFunction)
	{
		// loop through the text one character at a time, calling the supplied
		// rendering function for each character
		var lineHeight:Int = Std.int(_font.lineHeight + lineSpacing);

		// make sure our format stacks are clear
		while (_colorStack.length > 0) _colorStack.pop();
		while (_alphaStack.length > 0) _alphaStack.pop();
		while (_scaleStack.length > 0) _scaleStack.pop();

		_colorStack.push(color);
		_alphaStack.push(alpha);
		_scaleStack.push(1);

		var sx = scale * scaleX * size / _font.fontSize,
			sy = scale * scaleY * size / _font.fontSize;

		var currentColor:Color = color,
			currentAlpha:Float = alpha,
			currentScale:Float = 1,
			cursorX:Float = 0,
			cursorY:Float = 0,
			thisLineHeight:Float = lineHeight * sy,
			charCount:Int = 0;
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
					thisLineHeight = Math.max(thisLineHeight, lineHeight * currentScale * sy);
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
						var region = _font.getChar(char);
						var gd = _font.glyphData.get(char);
						// if a character isn't in this font, display a space
						if (gd == null)
						{
							char = ' ';
							gd = _font.glyphData.get(' ');
						}

						if (char == ' ')
						{
							// it's a space, just move the cursor
							cursorX += gd.xAdvance * sx * currentScale;
						}
						else
						{
							// draw the character
							if (renderFunction != null)
							{
								renderFunction(region, gd, currentColor, currentAlpha, currentScale,
											(cursorX + gd.xOffset * sx * currentScale),
											(cursorY + gd.yOffset * sy * currentScale));
							}
							// advance cursor position
							cursorX += (gd.xAdvance + charSpacing) * sx * currentScale;
						}

						if (cursorX > textWidth) textWidth = Std.int(cursorX);
					}
				case NextLine:
					// advance to next line
					cursorX = 0;
					cursorY += thisLineHeight;
					thisLineHeight = lineHeight * sy * currentScale;
					++charCount;
				case Image(img):
					if (renderImageFunction != null)
					{
						renderImageFunction(img, currentColor, currentAlpha, currentScale, cursorX, cursorY);
					}
					thisLineHeight = Std.int(Math.max(thisLineHeight, img.height * img.scale * img.scaleY));
					cursorX += (img.width * img.scale * img.scaleX * this.scale * this.scaleX * currentScale) + charSpacing * sx * currentScale;
					if (cursorX > textWidth) textWidth = Std.int(cursorX);
					++charCount;
			}
		}
		textHeight = Std.int(cursorY + (cursorX > 0 ? thisLineHeight : 0));

		_colorStack.pop();
		_alphaStack.pop();
		_scaleStack.pop();
	}

	@:dox(hide)
	override public function render(target:BitmapData, point:Point, camera:Camera)
	{
		if (_bufferDirty)
		{
			updateBuffer();
			_bufferDirty = false;
		}

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
		target.draw(_buffer, _matrix, null, null, null, smooth);
		//target.copyPixels(_buffer, _buffer.rect, _point, null, null, true);
	}

	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Camera)
	{
		// determine drawing location
		var fontScale = size / _font.fontSize;

		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		// scale per point; needs to be multiplied by size / fontSize
		var sx = scale * scaleX * fsx * size / _font.fontSize,
			sy = scale * scaleY * fsy * size / _font.fontSize;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);

		// use hardware accelerated rendering
		renderFont(function(region:AtlasRegion, gd:GlyphData, color:Color, alpha:Float, scale:Float, x:Float, y:Float)
		{
			region.draw((_point.x + x) * fsx, (_point.y + y) * fsy, layer, sx * scale, sy * scale, 0, color.red, color.green, color.blue, alpha, smooth);
		}, function(image:Image, color:Color, alpha:Float, scale:Float, x:Float, y:Float) {
			var originalX = image.x,
				originalY = image.y,
				originalScaleX = image.scaleX,
				originalScaleY = image.scaleY;
			image.x += _point.x + x;
			image.y += _point.y + y;
			image.color = color;
			image.alpha = alpha;
			image.scaleX *= this.scale * scaleX * scale;
			image.scaleY *= this.scale * scaleY * scale;
			image.renderAtlas(layer, HXP.zero, HXP.zeroCamera);
			image.x = originalX;
			image.y = originalY;
			image.scaleX = originalScaleX;
			image.scaleY = originalScaleY;
		});
	}

	/** Default value: false if HXP.stage.quality is LOW, true otherwise. */
	public var smooth:Bool;

	var _buffer:BitmapData;
	var _bufferDirty:Bool = false;
	var _set:BitmapData;
	var _font:BitmapFontAtlas;
	var _matrix:Matrix;
	var _rect:Rectangle;
	var _colorTransform:ColorTransform;
}
