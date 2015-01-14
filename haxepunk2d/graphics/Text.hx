package haxepunk2d.graphics;

typedef TextConfig = {
	> GraphicConfig,
	@:optional wordWrap : Bool,
	@:optional size:Int,
	@:optional resizable:Resizable,
	@:optional leading:Int,
	@:optional indent:Int,
	@:optional format:TextFormat,
	@:optional color:Color,
	@:optional align:TextAlign,
	@:optional font:String,
	@:optional thickness:Int
};

/**
 * Used for drawing text using embedded fonts or bitmap fonts.
 */
class Text extends Graphic
{
	/** Default values for newly created texts when config options are ommited. Config options inherited from GraphicConfig may be left null to use the values from Graphic's defaultConfig. */
	public static var defaultConfig : TextConfig;

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
	public var textHeight(default, null) : Int;

	/** The actual height of the text not the text graphic. */
	public var textWidth(default, null) : Int;

	/** The text content. */
	public var text:String;

	/**
	 * Create a new text.
	 * Ommited config values will use the defaults from `defaultConfig`.
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
