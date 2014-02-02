package com.haxepunk.graphics;

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
import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.atlas.AtlasRegion;

typedef TextOptions = {
	@:optional var font:String;
	@:optional var size:Int;
#if (flash || js)
	@:optional var align:TextFormatAlign;
#else
	@:optional var align:String;
#end
	@:optional var wordWrap:Bool;
	@:optional var resizable:Bool;
	@:optional var color:Int;
	@:optional var leading:Int;
};

/**
 * Used for drawing text using embedded fonts.
 */
class Text extends Image
{

	public var resizable:Bool;
	public var textWidth(default, null):Int;
	public var textHeight(default, null):Int;
	public var autoWidth:Bool = false;
	public var autoHeight:Bool = false;

	/**
	 * Constructor.
	 * @param text    Text to display.
	 * @param x       X offset.
	 * @param y       Y offset.
	 * @param width   Image width (leave as 0 to size to the starting text string).
	 * @param height  Image height (leave as 0 to size to the starting text string).
	 * @param options An object containing optional parameters contained in TextOptions
	 */
	public function new(text:String, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, ?options:TextOptions)
	{
		if (options == null)
		{
			options = {};
			options.color = 0xFFFFFF;
		}

		if (options.font == null)  options.font = HXP.defaultFont;
		if (options.size == 0)     options.size = 16;
		if (options.align == null) options.align = TextFormatAlign.LEFT;

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
		_field.text = text;
		_field.selectable = false;

		resizable = options.resizable;

		if (width == 0)
		{
			width = Std.int(_field.textWidth + 4);
			autoWidth = true;
		}
		if (height == 0)
		{
			height = Std.int(_field.textHeight + 4);
			autoHeight = true;
		}

		var source = HXP.createBitmap(width, height, true);
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			_sourceRect = source.rect;
			_source = source;
			_bitmap = new Bitmap();
			_colorTransform = new ColorTransform();
			createBuffer();
			updateBuffer();
			_textHardware = true;
		}
		super(source);

		this.text = text;
		this.color = options.color;
		this.x = x;
		this.y = y;
	}

	/** @private Updates the drawing buffer. */
	public override function updateBuffer(clearBefore:Bool = false)
	{
		_field.setTextFormat(_format);
		_field.width = _bufferRect.width;

		if (autoWidth)
			_field.width = textWidth = Math.ceil(_field.textWidth + 4);
		if (autoHeight)
			_field.height = textHeight = Math.ceil(_field.textHeight + 4);

		if (resizable)
		{
			_bufferRect.width = textWidth;
			_bufferRect.height = textHeight;
		}

		if (textWidth > _source.width || textHeight > _source.height)
		{
			_source = HXP.createBitmap(
				Std.int(Math.max(textWidth, _source.width)),
				Std.int(Math.max(textHeight, _source.height)),
				true);

			_sourceRect = _source.rect;
			createBuffer();
		}
		else
		{
			_source.fillRect(_sourceRect, HXP.blackColor);
		}

		if (resizable)
		{
			_field.width = textWidth;
			_field.height = textHeight;
		}

		_source.draw(_field);
		super.updateBuffer(clearBefore);

		if (_textHardware)
		{
			if (_region != null)
			{
				_region.destroy();
			}
			_region = Atlas.loadImageAsRegion(_source);
		}
	}
	
	override public function destroy()
	{
		if (_textHardware && _region != null)
		{
			_region.destroy();
		}
	}

	/**
	 * Text string.
	 */
	public var text(default, set_text):String;
	private function set_text(value:String):String
	{
		if (text == value) return value;
		_field.text = text = value;
		updateBuffer();
		return value;
	}

	/**
	 * Font family.
	 */
	public var font(default, set_font):String;
	private function set_font(value:String):String
	{
		if (font == value) return value;
		value = Assets.getFont(value).fontName;
		_format.font = font = value;
		updateBuffer();
		return value;
	}

	/**
	 * Font size.
	 */
	public var size(default, set_size):Int;
	private function set_size(value:Int):Int
	{
		if (size == value) return value;
		_format.size = size = value;
		updateBuffer();
		return value;
	}

	// Text information.
	private var _field:TextField;
	private var _format:TextFormat;
	private var _textHardware:Bool = false;
}
