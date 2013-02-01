package com.haxepunk.graphics;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;

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

	/**
	 * Constructor.
	 * @param text    Text to display.
	 * @param x       X offset.
	 * @param y       Y offset.
	 * @param width   Image width (leave as 0 to size to the starting text string).
	 * @param height  Image height (leave as 0 to size to the starting text string).
	 * @param options An object containing optional parameters contained in TextOptions
	 */
	public function new(text:String, ?x:Float = 0, ?y:Float = 0, ?width:Int = 0, ?height:Int = 0, ?options:TextOptions = null)
	{
		if (options == null)
		{
			options = {};
			options.color = 0xFFFFFF;
		}

		if (options.font == null)  options.font = HXP.defaultFont;
		if (options.size == 0)     options.size = 16;
#if (flash || js)
		if (options.align == null) options.align = TextFormatAlign.LEFT;
#else
		if (options.align == null) options.align = "left";
#end

#if nme
		var fontObj = nme.Assets.getFont(options.font);
		_form = new TextFormat(fontObj.fontName, options.size, options.color);
#else
		_form = new TextFormat(options.font, options.size, options.color);
#end
		_form.align = options.align;
		_form.leading = options.leading;

		_field = new TextField();
#if flash
		_field.embedFonts = true;
#end
		_field.wordWrap = options.wordWrap;
		_field.defaultTextFormat = _form;
		_field.text = text;

		resizable = options.resizable;

		if (width == 0) width = Std.int(_field.textWidth + 4);
		if (height == 0) height = Std.int(_field.textHeight + 4);

		super(HXP.createBitmap(width, height, true));

		this.text = text;
		this.x = x;
		this.y = y;
	}

	/** @private Updates the drawing buffer. */
	public override function updateBuffer(clearBefore:Bool = false)
	{
		_field.setTextFormat(_form);

		_field.width = width;
		_field.width = textWidth = Math.ceil(_field.textWidth + 4);
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

		cast(_source, BitmapData).draw(_field);
		super.updateBuffer(clearBefore);
	}

	public var resizable:Bool;
	public var textWidth(default, null):Int;
	public var textHeight(default, null):Int;

	/**
	 * Text string.
	 */
	public var text(default, setText):String;
	private function setText(value:String):String
	{
		if (text == value) return value;
		_field.text = text = value;
		updateBuffer();
		return text;
	}

	/**
	 * Font family.
	 */
	public var font(default, setFont):String;
	private function setFont(value:String):String
	{
		if (font == value) return value;
#if nme
		value = nme.Assets.getFont(value).fontName;
#end
		_form.font = font = value;
		updateBuffer();
		return font;
	}

	/**
	 * Font size.
	 */
	public var size(default, setSize):Int;
	private function setSize(value:Int):Int
	{
		if (size == value) return value;
		_form.size = size = value;
		updateBuffer();
		return value;
	}

	// Text information.
	private var _field:TextField;
	private var _form:TextFormat;
}