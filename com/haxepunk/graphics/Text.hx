package com.haxepunk.graphics;

import haxe.ds.StringMap;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.Assets;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;

/**
 * Text option including the font, size, color...
 */
typedef TextOptions = {
	/** Optional. The font to use. Default value is com.haxepunk.HXP.defaultFont. */
	@:optional var font:String;
	/** Optional. The font size. Default value is 16. */
	@:optional var size:Int;	
	/** Optional. The aligment of the text. Default value is left. */
#if (flash || js || !openfl_legacy)
	@:optional var align:TextFormatAlign;
#else
	@:optional var align:String;
#end
	/** Optional. Automatic word wrapping. Default value is false. */
	@:optional var wordWrap:Bool;
	/** Optional. If the text field can automatically resize if its contents grow. Default value is true. */
	@:optional var resizable:Bool;
	/** Optional. The color of the text. Default value is white. */
	@:optional var color:Int;
	/** Optional. Vertical space between lines. Default value is 0. */
	@:optional var leading:Int;
	/** Optional. If the text field uses a rich text string. */
	@:optional var richText:Bool;
	/** Optional. List Of Filters to be applied to Text */
	@:optional var filters:Array<flash.filters.BitmapFilter>;
};

/**
 * Abstract representing either a `TextFormat` or a `TextOptions`.
 * 
 * Conversion is automatic, no need to use this.
 */
abstract StyleType(TextFormat)
{
	private function new(format:TextFormat) this = format;
	@:dox(hide) @:to public function toTextformat():TextFormat return this;

	@:dox(hide) @:from public static inline function fromTextFormat(format:TextFormat) return new StyleType(format);
	@:dox(hide) @:from public static inline function fromTextOptions(object:TextOptions) return fromDynamic(object);
	@:dox(hide) @:from public static inline function fromDynamic(object:Dynamic)
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
	public function new(?text:String, ?x:Float = 0, ?y:Float = 0, ?width:Int = 0, ?height:Int = 0, ?options:TextOptions)
	{
		if (options == null) options = {};
		if (text == null) text = "";

		// defaults
		if (!Reflect.hasField(options, "font"))      options.font      = HXP.defaultFont;
		if (!Reflect.hasField(options, "size"))      options.size      = 16;
		if (!Reflect.hasField(options, "align"))     options.align     = TextFormatAlign.LEFT;
		if (!Reflect.hasField(options, "color"))     options.color     = 0xFFFFFF;
		if (!Reflect.hasField(options, "resizable")) options.resizable = true;
		if (!Reflect.hasField(options, "wordWrap"))  options.wordWrap  = false;
		if (!Reflect.hasField(options, "leading"))   options.leading   = 0;

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
		if(options.filters != null)
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
		updateTextBuffer();

		this.size = options.size;
		this.color = options.color;
		this.x = x;
		this.y = y;
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
		if (_richText != null) updateTextBuffer();
	}

	override private function updateColorTransform():Void
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

			if (_format.color != _color)
			{
				updateTextBuffer();
			}
			else
			{
				updateBuffer();
			}
		}
		else
		{
			super.updateColorTransform();
		}
	}
	
	private static var tag_re = ~/<([^>]+)>([^(?:<\/)]+)<\/[^>]+>/g;
	private function matchStyles()
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
	private function updateTextBuffer()
	{
		if (_richText == null)
		{
			_format.color = 0xFFFFFF;
			_field.setTextFormat(_format);
		}
		else
		{
			_format.color = _color;
			matchStyles();
		}

		_field.width = _width;
		_field.width = textWidth = Math.ceil(_field.textWidth + 4);
		_field.height = textHeight = Math.ceil(_field.textHeight + 4);

		if (resizable && (textWidth > _width || textHeight > _height))
		{
			if (_width < textWidth) _width = textWidth;
			if (_height < textHeight) _height = textHeight;
		}

		if (_width > _source.width || _height > _source.height)
		{
			_source = HXP.createBitmap(
				Std.int(Math.max(_width, _source.width)),
				Std.int(Math.max(_height, _source.height)),
				true);

			_sourceRect = _source.rect;
			createBuffer();

			if (!blit)
			{
				if (_region != null)
				{
					_region.destroy();
				}
				_region = Atlas.loadImageAsRegion(_source);
			}
		}
		else
		{
			_source.fillRect(_sourceRect, 0);
		}

		_field.width = _width;
		_field.height = _height;

		_source.draw(_field);
		super.updateBuffer();
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

	/**
	 * Text string.
	 */
	public var text(get, set):String;
	private inline function get_text():String { return _text; }
	private function set_text(value:String):String
	{
		if (_text == value && _richText == null) return value;
		_field.text = _text = value;
		if (_richText == null)
		{
			updateTextBuffer();
		}
		else
		{
			updateColorTransform();
		}
		return value;
	}

	/**
	 * Rich-text string with markup.
	 * 
	 * Use `Text.addStyle` to control the appearance of marked-up text.
	 */
	public var richText(get, set):String;
	private function get_richText():String { return (_richText == null ? _text : _richText); }
	private function set_richText(value:String):String
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
			updateTextBuffer();
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
		
		updateTextBuffer();
		return true;
	}

	/**
	 * Font family.
	 */
	public var font(default, set):String;
	private function set_font(value:String):String
	{
		if (font == value) return value;
		value = Assets.getFont(value).fontName;
		_format.font = font = value;
		updateTextBuffer();
		return value;
	}

	/**
	 * Font size.
	 */
	public var size(default, set):Int;
	private function set_size(value:Int):Int
	{
		if (size == value) return value;
		_format.size = size = value;
		updateTextBuffer();
		return value;
	}

	/**
	 * Font alignment.
	 */
#if (flash || js || !openfl_legacy)
	public var align(default, set):TextFormatAlign;
	private function set_align(value:TextFormatAlign):TextFormatAlign
#else
	public var align(default, set):String;
	private function set_align(value:String):String
#end
	{
		if (align == value) return value;
		_format.align = value;
		updateTextBuffer();
		return value;
	}

	/**
	 * Leading (amount of vertical space between lines).
	 */
	public var leading(default, set):Int;
	private function set_leading(value:Int):Int
	{
		if (leading == value) return value;
		_format.leading = leading = value;
		updateTextBuffer();
		return value;
	}

	/**
	 * Automatic word wrapping.
	 */
	public var wordWrap(default, set):Bool;
	private function set_wordWrap(value:Bool):Bool
	{
		if (wordWrap == value) return value;
		_field.wordWrap = wordWrap = value;
		updateTextBuffer();
		return value;
	}

	override private function get_width():Int { return Std.int(_width); }
	override private function get_height():Int { return Std.int(_height); }

	// Text information.
	private var _width:Int;
	private var _height:Int;
	private var _text:String;
	private var _richText:String;
	private var _field:TextField;
	private var _format:TextFormat;
	private var _styles:StringMap<TextFormat>;

}
