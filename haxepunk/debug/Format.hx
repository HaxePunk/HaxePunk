package haxepunk.debug;

import flash.Assets;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxepunk.utils.Color;

class Format
{
	/** @private Gets a TextFormat object with the formatting. */
	public static function format(size:Int = 16, color:Color = 0xFFFFFF, align:String = "left"):TextFormat
	{
		if (_format == null)
		{
			var font = Assets.getFont("font/04B_03__.ttf");
			if (font == null)
			{
				font = Assets.getFont(HXP.defaultFont);
			}
			_format = new TextFormat(font.fontName, 8, 0xFFFFFF);
		}

		_format.size = size;
		_format.color = color;
		switch (align)
		{
			case "left":
				_format.align = TextFormatAlign.LEFT;
			case "right":
				_format.align = TextFormatAlign.RIGHT;
			case "center":
				_format.align = TextFormatAlign.CENTER;
			case "justify":
				_format.align = TextFormatAlign.JUSTIFY;
		}
		return _format;
	}

	static var _format:TextFormat;
}
