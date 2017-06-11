package haxepunk.graphics.text;

import haxe.ds.StringMap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.Assets;
import haxepunk.HXP;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;

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
			_borderBackBuffer = _borderBuffer.clone();
			_borderSource = _borderBuffer.clone();
			_borderRegion = Atlas.loadImageAsRegion(_borderSource);
		}
		_needsUpdate = true;
		return options;
	}

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
	public function new(text:String = "", x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, ?options:TextOptions)
	{
		if (options == null) options = {};

		// defaults
		if (!Reflect.hasField(options, "font")) options.font = HXP.defaultFont;
		if (!Reflect.hasField(options, "size")) options.size = 16;
		if (!Reflect.hasField(options, "align")) options.align = TextFormatAlign.LEFT;
		if (!Reflect.hasField(options, "color")) options.color = 0xFFFFFF;
		if (!Reflect.hasField(options, "resizable")) options.resizable = true;
		if (!Reflect.hasField(options, "wordWrap")) options.wordWrap = false;
		if (!Reflect.hasField(options, "leading")) options.leading = 0;
		if (!Reflect.hasField(options, "border")) options.border = null;

		_matrix = new Matrix();

		var fontObj = Assets.getFont(options.font);
		_format = new TextFormat(fontObj.fontName, options.size, 0xFFFFFF);
		_format.align = options.align;
		_format.leading = options.leading;

		_field = new TextField();
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
		_source = source;
		_sourceRect = source.rect;
		_region = Atlas.loadImageAsRegion(_source);
		super();

		createBuffer();
		updateBuffer();

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
		else
		{
			_field.setTextFormat(_format);
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
			if (border != null && border.alpha > 0) _borderSource.fillRect(_sourceRect, 0);
		}

		_field.width = _width;
		_field.height = _height;

		updateBuffer(true);
		if (border != null && border.alpha > 0)
		{
			_borderSource.draw(_borderBuffer);
		}
		_source.draw(_buffer);
	}

	function createBuffer()
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
			_borderBackBuffer.dispose();
			_borderBackBuffer = _buffer.clone();
		}
		_bufferRect = _buffer.rect;
	}

	/**
	 * Updates the image buffer.
	 */
	@:dox(hide)
	public function updateBuffer(clearBefore:Bool = false)
	{
		if (clearBefore)
		{
			_buffer.fillRect(_bufferRect, 0);
			if (border != null && border.alpha > 0)
			{
				_borderBuffer.fillRect(_bufferRect, 0);
				_borderBackBuffer.fillRect(_bufferRect, 0);
			}
		}
		if (_source == null) return;

		_matrix.setTo(1, 0, 0, 1, bufferMargin, bufferMargin);

		if (border != null)
		{
			_borderBuffer.draw(_field, _matrix, _whiteTint);

			inline function drawBorder(ox, oy)
			{
				// two buffers are used because copyPixels from the same
				// BitmapData forces an expensive clone
				var _swap = _borderBuffer;
				_borderBuffer = _borderBackBuffer;
				_borderBackBuffer = _swap;

				_offset.setTo(0, 0);
				_borderBuffer.copyPixels(_borderBackBuffer, _bufferRect, _offset, true);
				_offset.setTo(ox, oy);
				_borderBuffer.copyPixels(_borderBackBuffer, _bufferRect, _offset, true);
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

		_buffer.draw(_field, _matrix);
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

	public function resize(width:Int, height:Int, redraw:Bool = true)
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

	public function setBorder(style:BorderStyle = BorderStyle.FastOutline, size:Int = 1, color:Color = Color.Black, alpha:Float = 1)
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
	public var align(default, set):TextAlignType;
	function set_align(value:TextAlignType):TextAlignType
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

	override public function render(layer:Int, point:Point, camera:Camera)
	{
		if (_needsUpdate) updateTextBuffer();

		if (border != null && border.alpha > 0)
		{
			// draw the border first
			var textRegion = _region,
				c = color,
				a = alpha;
			_region = _borderRegion;
			color = border.color;
			alpha = border.alpha;
			super.render(layer, point, camera);
			_region = textRegion;
			color = c;
			alpha = a;
		}

		super.render(layer, point, camera);
	}

	// Text information.
	var _width:Int;
	var _height:Int;
	var _matrix:Matrix;
	var _text:String;
	var _richText:String;
	var _field:TextField;
	var _format:TextFormat;
	var _styles:StringMap<TextFormat>;
	var _source:BitmapData;
	var _buffer:BitmapData;
	var _bufferRect:Rectangle;

	var _offset:Point = new Point();
	var _whiteTint:ColorTransform = new ColorTransform(1, 1, 1, 1, 0xff, 0xff, 0xff, 1);
	var _needsUpdate:Bool = true;

	var _borderTint:ColorTransform = new ColorTransform();
	var _borderBuffer:BitmapData;
	var _borderBackBuffer:BitmapData;
	var _borderRegion:AtlasRegion;
	var _borderSource:BitmapData;
}
