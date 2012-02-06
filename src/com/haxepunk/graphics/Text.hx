package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;

/**
 * Used for drawing text using embedded fonts.
 */
class Text extends Image
{
	
	/**
	 * Constructor.
	 * @param	text		Text to display.
	 * @param	x			X offset.
	 * @param	y			Y offset.
	 * @param	width		Image width (leave as 0 to size to the starting text string).
	 * @param	height		Image height (leave as 0 to size to the starting text string).
	 */
	public function new(text:String, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0)
	{
		_field = new TextField();
		#if flash
		_field.embedFonts = true;
		#end
		#if nme
		var font = ApplicationMain.getAsset ("source/com/haxepunk/graphics/04B_03__.TTF");
		#else
		var font = new TextFormat("source/com/haxepunk/graphics/04B_03__", 16, 0xFFFFFF);
		#end
		_field.defaultTextFormat = _form = new TextFormat(font.fontName, 16, 0xFFFFFF);
		_field.text = _text = text;
		if (width == 0) width = Std.int(_field.textWidth + 4);
		if (height == 0) height = Std.int(_field.textHeight + 4);
		_source = new BitmapData(width, height, true, 0);
		super(_source);
		updateBuffer();
		this.x = x;
		this.y = y;
	}
	
	/** @private Updates the drawing buffer. */
	override public function updateBuffer(clearBefore:Bool = false) 
	{
		_field.setTextFormat(_form);
		_field.width = _field.textWidth + 4;
		_field.height = _field.textHeight + 4;
		_width = Std.int(_field.width);
		_height = Std.int(_field.height);
		_source.fillRect(_sourceRect, 0);
		_source.draw(_field);
		super.updateBuffer(clearBefore);
	}
	
	/**
	 * Text string.
	 */
	public var text(getText, setText):String;
	private function getText():String { return _text; }
	private function setText(value:String):String
	{
		if (_text == value) return value;
		_field.text = _text = value;
		updateBuffer();
		return _text;
	}
	
	/**
	 * Font family.
	 */
	public var font(getFont, setFont):String;
	private function getFont():String { return _font; }
	private function setFont(value:String):String
	{
		if (_font == value) return value;
		_form.font = _font = value;
		updateBuffer();
		return _font;
	}
	
	/**
	 * Font size.
	 */
	public var size(getSize, setSize):Int;
	private function getSize():Int { return _size; }
	private function setSize(value:Int):Int
	{
		if (_size == value) return value;
		_form.size = _size = value;
		updateBuffer();
		return _size;
	}
	
	/**
	 * Width of the text image.
	 */
	override private function getWidth():Int { return _width; }
	
	/**
	 * Height of the text image.
	 */
	override private function getHeight():Int { return _height; }
	
	// Text information.
	private var _field:TextField;
	private var _width:Int;
	private var _height:Int;
	private var _form:TextFormat;
	private var _text:String;
	private var _font:String;
	private var _size:Int;
}