package haxepunk.graphics;

import haxe.ds.StringMap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.Assets;
import haxepunk.HXP;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;

@:dox(hide)
#if (lime || flash)
typedef AlignType = TextFormatAlign;
#else
typedef AlignType = String;
#end

/**
 * Text option including the font, size, color...
 */
typedef TextOptions =
{
	/** Optional. The font to use. Default value is haxepunk.HXP.defaultFont. */
	@:optional var font:String;
	/** Optional. The font size. Default value is 16. */
	@:optional var size:Int;
	/** Optional. The aligment of the text. Default value is left. */
	@:optional var align:AlignType;
	/** Optional. Automatic word wrapping. Default value is false. */
	@:optional var wordWrap:Bool;
	/** Optional. If the text field can automatically resize if its contents grow. Default value is true. */
	@:optional var resizable:Bool;
	/** Optional. The color of the text. Default value is white. */
	@:optional var color:Color;
	/** Optional. Vertical space between lines. Default value is 0. */
	@:optional var leading:Int;
	/** Optional. If the text field uses a rich text string. */
	@:optional var richText:Bool;
	/** Optional. Any Bitmap Filters To Alter Text Style */
	@:optional var filters:Array<flash.filters.BitmapFilter>;
	/** Optional. If the text should draw a border. */
	@:optional var border:BorderOptions;
};

@:enum
abstract BorderStyle(Int) from Int to Int
{
	/* Draws a thick shadow down and to the right. */
	var Shadow = 1;
	/* Draws a shadow using only one draw call. */
	var FastShadow = 2;
	/* Outlines the text on all sides. */
	var Outline = 3;
	/* A fast outline in four draw calls. */
	var FastOutline = 4;
}

typedef BorderOptions =
{
	var style:BorderStyle;
	var size:Int;
	var color:Color;
	var alpha:Float;
}

/**
 * Abstract representing either a `TextFormat` or a `TextOptions`.
 * 
 * Conversion is automatic, no need to use this.
 */
@:dox(hide)
abstract StyleType(TextFormat)
{
	function new(format:TextFormat) this = format;
	@:to public function toTextformat():TextFormat return this;

	@:from public static inline function fromTextFormat(format:TextFormat) return new StyleType(format);
	@:from public static inline function fromTextOptions(object:TextOptions) return fromDynamic(object);
	@:from public static inline function fromDynamic(object:Dynamic)
	{
		var format = new TextFormat();
		var fields = Type.getInstanceFields(TextFormat);
		
		for (key in Reflect.fields(object))
		{
			if (HXP.indexOf(fields, key) > -1)
			{
				Reflect.setField(format, key, Reflect.field(object, key));
			}
			else
			{
				throw '"' + key + '" is not a TextFormat property';
			}
		}
		return new StyleType(format);
	}
}

/**
 * Used for drawing text using embedded fonts.
 */
class Text extends Image
{
	static var tag_re = ~/<([^>]+)>([^(<\/)]+)<\/[^>]+>/g;

	/**
	 * If the text field can automatically resize if its contents grow.
	 */
	public var resizable:Bool = true;

	/**
	 * Width of the text within the image.
	 */
	public var textWidth(default, null):Int;

	/**
	 * Height of the text within the image.
	 */
	public var textHeight(default, null):Int;

	/**
	 * If set, configuration for text border.
	 */
	var border(default, set):Null<BorderOptions>;
	inline function set_border(options:Null<BorderOptions>):Null<BorderOptions>
	{
		this.border = options;
		if (options != null && options.alpha > 0 && _borderBuffer == null)
		{
			// create a second buffer for the border, to allow independently
			// changing its alpha/color without a full buffer update
			_borderBuffer = HXP.createBitmap(
				Std.int(_sourceRect.width + bufferMargin * 2),
				Std.int(_sourceRect.height + bufferMargin * 2),
				true
			);
			_borderSource = _borderBuffer.clone();
			_borderRegion = Atlas.loadImageAsRegion(_borderSource);
		}
		_needsUpdate = true;
		return options;
	}

	/*override function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		if (_alpha == value) return value;
		_alpha = value;
		updateColorTransform();
		return _alpha;
	}

	override function set_color(value:Color):Color
	{
		value &= 0xFFFFFF;
		if (_color == value) return value;
		_color = value;
		// save individual color channel values
		_red = _green = _blue = 1;
		updateColorTransform();
		return _color;
	}*/

	/**
	 * Text constructor.
	 * @param text    Text to display.
	 * @param x       X offset.
	 * @param y       Y offset.
	 * @param width   Image width (leave as 0 to size to the starting text string).
	 * @param height  Image height (leave as 0 to size to the starting text string).
	 * @param options An object containing optional parameters contained in TextOptions
	 * 						font		Font family.
	 * 						size		Font size.
	 * 						align		Alignment (one of: TextFormatAlign.LEFT, TextFormatAlign.CENTER, TextFormatAlign.RIGHT, TextFormatAlign.JUSTIFY).
	 * 						wordWrap	Automatic word wrapping.
	 * 						resizable	If the text field can automatically resize if its contents grow.
	 * 						color		Text color.
	 * 						leading		Vertical space between lines.
	 *						richText	If the text field uses a rich text string
	 */
	public function new(text:String = "", ?x:Float = 0, ?y:Float = 0, ?width:Int = 0, ?height:Int = 0, ?options:TextOptions)
	{
		if (options == null) options = {};

		// defaults
		if (!Reflect.hasField(options, "font"))      options.font      = HXP.defaultFont;
		if (!Reflect.hasField(options, "size"))      options.size      = 16;
		if (!Reflect.hasField(options, "align"))     options.align     = TextFormatAlign.LEFT;
		if (!Reflect.hasField(options, "color"))     options.color     = 0xFFFFFF;
		if (!Reflect.hasField(options, "resizable")) options.resizable = true;
		if (!Reflect.hasField(options, "wordWrap"))  options.wordWrap  = false;
		if (!Reflect.hasField(options, "leading"))   options.leading   = 0;
		if (!Reflect.hasField(options, "border"))    options.border   = null;

		var fontObj = Assets.getFont(options.font);
		_format = new TextFormat(fontObj.fontName, options.size, 0xFFFFFF);
		_format.align = options.align;
		_format.leading = options.leading;

		_field = new TextField();
#if flash
		_field.embedFonts = true;
#end
		_field.wordWrap = options.wordWrap;
		_field.defaultTextFormat = _format;
		if (options.filters != null)
		{
			_field.filters = options.filters;
		}
		_field.text = _text = text;
		_field.selectable = false;

		resizable = options.resizable;
		_styles = new StringMap<TextFormat>();

		_width = (width == 0 ? Std.int(_field.textWidth + 4) : width);
		_height = (height == 0 ? Std.int(_field.textHeight + 4) : height);

		var source = HXP.createBitmap(_width, _height, true);
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			_source = source;
			_sourceRect = source.rect;
			_region = Atlas.loadImageAsRegion(_source);
			blit = true;
			super();
		}
		else
		{
			super(source);
		}

		blit = HXP.renderMode == RenderMode.BUFFER;

		this.x = x;
		this.y = y;
		this.border = options.border;
		this.size = options.size;
		this.color = options.color;

		_needsUpdate = true;
	}

	/**
	 * Add a style for a subset of the text, for use with the richText property.
	 * 
	 * Usage:
	 * 
	 * ```
	 * text.addStyle("red", {color: 0xFF0000});
	 * text.addStyle("big", {size: text.size * 2, bold: true});
	 * text.richText = "<big>Hello</big> <red>world</red>";
	 * ```
	 */
	public function addStyle(tagName:String, params:StyleType):Void
	{
		_styles.set(tagName, params);
		if (_richText != null) _needsUpdate = true;
	}

	override function updateColorTransform():Void
	{
		if (_richText != null)
		{
			if (_alpha == 1)
			{
				_tint = null;
			}
			else
			{
				_tint = _colorTransform;
				_tint.redMultiplier   = 1;
				_tint.greenMultiplier = 1;
				_tint.blueMultiplier  = 1;
				_tint.redOffset       = 0;
				_tint.greenOffset     = 0;
				_tint.blueOffset      = 0;
				_tint.alphaMultiplier = _alpha;
			}

			_needsUpdate = true;
		}
		else
		{
			super.updateColorTransform();
			if (_tint != null) _tint.alphaMultiplier = 1;
		}
	}

	function matchStyles()
	{
		_text = _richText;

		// strip the tags for the display field
		_field.text = tag_re.replace(_text, "$2");

		// set the text formats based on tag names
		_field.setTextFormat(_format);
		while (tag_re.match(_text))
		{
			var tagName = tag_re.matched(1);
			var text = tag_re.matched(2);
			var p = tag_re.matchedPos();
			_text = _text.substr(0, p.pos) + text + _text.substr(p.pos + p.len);
			// try to find a tag name
			if (_styles.exists(tagName))
			{
				_field.setTextFormat(_styles.get(tagName), p.pos, p.pos + text.length);
			}
#if debug
			else
			{
				HXP.log("Could not found text style '" + tagName + "'");
			}
#end
		}

#if debug
		if (_field.text != _text)
		{
			HXP.log("Text field and _text do not match!");
		}
#end
	}

	/** @private Updates the drawing buffer. */
	public function updateTextBuffer()
	{
		_needsUpdate = false;

		if (_richText != null)
		{
			matchStyles();
		}

		_field.width = _width;
		_field.width = textWidth = Math.ceil(_field.textWidth + bufferMargin * 2);
		_field.height = textHeight = Math.ceil(_field.textHeight + bufferMargin * 2);

		if (resizable && (textWidth > _width || textHeight > _height))
		{
			if (_width < textWidth) _width = textWidth + Std.int(bufferMargin * 2);
			if (_height < textHeight) _height = textHeight + Std.int(bufferMargin * 2);
		}

		if (_width > _source.width || _height > _source.height)
		{
			resize(_width, _height, false);
		}
		else
		{
			_source.fillRect(_sourceRect, 0);
			if (border != null && border.alpha > 0) _source.fillRect(_sourceRect, 0);
		}

		_field.width = _width;
		_field.height = _height;

		updateBuffer(true);
		if (!blit)
		{
			if (border != null && border.alpha > 0)
			{
				_borderSource.draw(_borderBuffer);
			}
			_source.draw(_buffer);
		}
	}

	override function createBuffer()
	{
		if (_buffer != null) _buffer.dispose();
		_buffer = HXP.createBitmap(
			Std.int(_sourceRect.width + bufferMargin * 2),
			Std.int(_sourceRect.height + bufferMargin * 2),
			true
		);
		if (_borderBuffer != null)
		{
			_borderBuffer.dispose();
			_borderBuffer = _buffer.clone();
		}
		_bufferRect = _buffer.rect;
		_bitmap.bitmapData = _buffer;
	}

	/**
	 * Updates the image buffer.
	 */
	@:dox(hide)
	override public function updateBuffer(clearBefore:Bool = false)
	{
		if (clearBefore)
		{
			_buffer.fillRect(_bufferRect, 0);
			if (border != null && border.alpha > 0) _borderBuffer.fillRect(_bufferRect, 0);
		}
		if (_source == null) return;

		_matrix.setTo(1, 0, 0, 1, bufferMargin, bufferMargin);

		if (border != null)
		{
			_borderBuffer.draw(_field, _matrix, _whiteTint);

			inline function drawBorder(ox, oy)
			{
				_offset.setTo(ox, oy);
				_borderBuffer.copyPixels(_borderBuffer, _bufferRect, _offset, true);
			}
			switch (border.style)
			{
				case FastShadow:
					drawBorder(border.size, border.size);
				case Shadow:
					for (_ in 0 ... border.size)
					{
						drawBorder(1, 0);
						drawBorder(0, 1);
					}
				case FastOutline:
					drawBorder(0, -border.size);
					drawBorder(-border.size, 0);
					drawBorder(border.size, 0);
					drawBorder(0, border.size);
				case Outline:
					for (_ in 0 ... border.size)
					{
						drawBorder(0, -1);
						drawBorder(-1, 0);
						drawBorder(1, 0);
						drawBorder(0, 1);
					}
			}
		}

		_buffer.draw(_field, _matrix, _tint);
	}

	/**
	 * Removes the graphic from memory
	 */
	override public function destroy()
	{
		if (_region != null)
		{
			_region.destroy();
		}
	}

	public function resize(width:Int, height:Int, ?redraw:Bool = true)
	{
		_width = width;
		_height = height;

		if (_width > _source.width || _height > _source.height)
		{
			_source = HXP.createBitmap(
				Std.int(Math.max(_width, _source.width)),
				Std.int(Math.max(_height, _source.height)),
				true
			);

			_sourceRect = _source.rect;

			if (border != null && border.alpha > 0)
			{
				_borderSource = HXP.createBitmap(
					Std.int(Math.max(_width, _source.width)),
					Std.int(Math.max(_height, _source.height)),
					true
				);
			}

			createBuffer();

			if (!blit)
			{
				if (_region != null)
				{
					_region.destroy();
				}
				_region = Atlas.loadImageAsRegion(_source);

				if (_borderRegion != null)
				{
					_borderRegion.destroy();
					_borderRegion = Atlas.loadImageAsRegion(_borderSource);
				}
			}
		}
		if (redraw) updateBuffer();
	}

	/**
	 * Text string.
	 */
	public var text(get, set):String;
	inline function get_text():String return _text;
	function set_text(value:String):String
	{
		if (_text == value && _richText == null) return value;
		_field.text = _text = value;
		if (_richText != null)
		{
			updateColorTransform();
		}
		_needsUpdate = true;
		return value;
	}

	/**
	 * Rich-text string with markup.
	 * 
	 * Use `Text.addStyle` to control the appearance of marked-up text.
	 */
	public var richText(get, set):String;
	inline function get_richText():String return (_richText == null ? _text : _richText);
	function set_richText(value:String):String
	{
		if (_richText == value) return value;
		var fromPlain = (_richText == null);
		_richText = value;
		if (_richText == "") _field.text = _text = "";
		if (fromPlain && _richText != null)
		{
			_format.color = 0xFFFFFF;
			_red = _green = _blue = 1;
			updateColorTransform();
		}
		else
		{
			_needsUpdate = true;
		}
		return value;
	}

	/** 
	 * Gets the specified property, by also inspecting the underlying TextField and TextFormat objects.
	 * Returns null if the property doesn't exist.
	 */ 
	public function getTextProperty(name:String):Dynamic
	{
		var value = Reflect.getProperty(this, name);
		if (value == null) value = Reflect.getProperty(_field, name);
		if (value == null) value = Reflect.getProperty(_format, name);
		return value;
	}
	
	/** 
	 * Sets the specified property, by also inspecting the underlying TextField and TextFormat objects.
	 * Returns true if the property has been found and set, false otherwise.
	 */ 
	public function setTextProperty(name:String, value:Dynamic):Bool
	{
		var propertyFound:Bool = false;
		
		// chain of try-catch: ugly but Reflect.hasField doesn't work with non-anon structs
		try // on this Text
		{
			Reflect.setProperty(this, name, value);
			return true; // exit early to avoid calling update twice
		} 
		catch (e:Dynamic) 
		{
			try // on TextField
			{
				Reflect.setProperty(_field, name, value);
				propertyFound = true;
			} 
			catch (e:Dynamic) 
			{
				try // on TextFormat
				{
					Reflect.setProperty(_format, name, value);
					propertyFound = true;
				} 
				catch (e:Dynamic) {}
			}
		}
		if (!propertyFound) return false;

		_needsUpdate = true;
		return true;
	}

	public function setBorder(?style:BorderStyle = BorderStyle.FastOutline, ?size:Int = 1, ?color:Color = Color.Black, ?alpha:Float = 1)
	{
		border = {
			style: style,
			size: size,
			color: color,
			alpha: alpha,
		};
	}

	/**
	 * Font family.
	 */
	public var font(default, set):String;
	function set_font(value:String):String
	{
		if (font == value) return value;
		value = Assets.getFont(value).fontName;
		_format.font = font = value;
		_needsUpdate = true;
		return value;
	}

	/**
	 * Font size.
	 */
	public var size(default, set):Int;
	function set_size(value:Int):Int
	{
		if (size == value) return value;
		_format.size = size = value;
		_needsUpdate = true;
		return value;
	}

	/**
	 * Font alignment.
	 */
	public var align(default, set):AlignType;
	function set_align(value:AlignType):AlignType
	{
		if (align == value) return value;
		_format.align = value;
		_needsUpdate = true;
		return value;
	}

	/**
	 * Leading (amount of vertical space between lines).
	 */
	public var leading(default, set):Int;
	function set_leading(value:Int):Int
	{
		if (leading == value) return value;
		_format.leading = leading = value;
		_needsUpdate = true;
		return value;
	}

	/**
	 * Automatic word wrapping.
	 */
	public var wordWrap(default, set):Bool;
	function set_wordWrap(value:Bool):Bool
	{
		if (wordWrap == value) return value;
		_field.wordWrap = wordWrap = value;
		_needsUpdate = true;
		return value;
	}

	override function get_width():Int return Std.int(_width);
	override function get_height():Int return Std.int(_height);

	var bufferMargin(get, null):Float;
	inline function get_bufferMargin() return 2 + (border == null ? 0 : border.size);

	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		if (_needsUpdate) updateTextBuffer();

		if (border != null && border.alpha > 0)
		{
			// draw the border first
			var textBuffer = _buffer,
				textTint = _tint;
			_buffer = _bitmap.bitmapData = _borderBuffer;
			_tint = _borderTint;
			super.render(target, point, camera);
			_buffer = _bitmap.bitmapData = textBuffer;
			_tint = textTint;
		}

		super.render(target, point, camera);
	}

	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		if (_needsUpdate) updateTextBuffer();

		if (border != null && border.alpha > 0)
		{
			// draw the border first
			var textRegion = _region,
				r = _red,
				g = _green,
				b = _blue,
				a = _alpha;
			_region = _borderRegion;
			_red = border.color.r / 0xff;
			_green = border.color.g / 0xff;
			_blue = border.color.b / 0xff;
			_alpha = border.alpha * _alpha;
			super.renderAtlas(layer, point, camera);
			_region = textRegion;
			_red = r;
			_green = g;
			_blue = b;
			_alpha = a;
		}

		super.renderAtlas(layer, point, camera);
	}

	// Text information.
	var _width:Int;
	var _height:Int;
	var _text:String;
	var _richText:String;
	var _field:TextField;
	var _format:TextFormat;
	var _styles:StringMap<TextFormat>;

	var _offset:Point = new Point();
	var _whiteTint:ColorTransform = new ColorTransform(1, 1, 1, 1, 0xff, 0xff, 0xff, 1);
	var _needsUpdate:Bool = true;

	var _borderTint:ColorTransform = new ColorTransform();
	var _borderBuffer:BitmapData;
	var _borderRegion:AtlasRegion;
	var _borderSource:BitmapData;
}
