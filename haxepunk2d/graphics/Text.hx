package haxepunk2d.graphics;

typedef TextConfig = {
	> GraphicConfig,
	wordWrap : Bool,
	size:Int,
	resizable:Resizable,
	leading:Int,
	indent:Int,
	format:TextFormat,
	color:Color,
	align:TextAlign,
	font:String,
	thickness:Int
};

/**
 * Used for drawing text using embedded fonts or bitmap fonts.
 */
class Text extends Graphic
{
	/** Default values used when creating a new Text graphic with omitted configuration values. */
	public static var defaults : { font:String, size:Int, color:Color };

	/** Automatic word wrapping. */
	public var wordWrap : Bool;

	/** The font size of the text. */
	public var size:Int;

	/** If the text field can automatically resize if its contents grow. If set to false text may be truncated if it's too big. */
	public var resizable:Resizable;

	/** Vertical space between lines.  */
	public var leading:Int;

	/** The indentation of pararaghs. */
	public var indent:Int;

	/** The format of the font. */
	public var format:TextFormat;

	/** The color of the text. */
	public var color:Color;

	/** The aligngement of the text. */
	public var align:TextAlign;

	/** The font of the text. */
	public var font:String;

	/** The thickness of the text. */
	public var thickness:Int;

	/** The actual height of the text not the text graphic. */
	public var textHeight : Int;

	/** The actual height of the text not the text graphic. */
	public var textWidth : Int;

	/** The text content. */
	public var text:String;

	/**
	 * Create a new text.
	 */
	public function new(text:String, ?config:TextConfig);

	/**
	 * Add a style for a subset of the text.
	 * If the tagName was already defined the
	 * style is overwritten.
	 *
	 * Usage:
	 * ```
	 * text.addStyle("red", {color: 0xFF0000});
	 * text.addStyle("big", {size: text.size * 2, bold: true});
	 * text.text = "<big>Hello</big> <red>world</red>";
	 * ```
	 */
	public function addStyle(tagName:String, style:?);
}

enum Resizable
{
	Horizontally;
	Vertically;
	Both;
}

enum TextFormat
{
	Font;
	XML;
	XNA;
}

enum TextAlign
{
	Left;
	Center;
	Right;
	Justify;
}
