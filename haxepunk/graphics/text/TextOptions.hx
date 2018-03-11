package haxepunk.graphics.text;

import haxepunk.utils.Color;

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
	@:optional var align:TextAlignType;
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
#if (lime || nme)
	/** Optional. Any Bitmap Filters To Alter Text Style */
	@:optional var filters:Array<flash.filters.BitmapFilter>;
#end
	/** Optional. If the text should draw a border. */
	@:optional var border:BorderOptions;
};
