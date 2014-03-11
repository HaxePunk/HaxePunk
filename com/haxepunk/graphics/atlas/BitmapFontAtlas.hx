package com.haxepunk.graphics.atlas;

import flash.geom.Rectangle;
import openfl.Assets;
import haxe.xml.Fast;


enum BitmapFontFormat
{
	XML;
}

typedef GlyphData = {
	var glyph:String;
	var rect:Rectangle;
	var xOffset:Int;
	var yOffset:Int;
	var xAdvance:Int;
};

class BitmapFontAtlas extends TextureAtlas
{

	public var lineHeight:Int = 0;
	public var fontSize:Int = 0;
	public var glyphData:Map<String, GlyphData>;

	/*
	 * Loads a bitmap font, returning a BitmapFontAtlas. The first time a font
	 * is loaded, it is cached for later use.
	 * @param fontName    The path to a .fnt bitmap font description.
	 * @param format      An enum specifying the font format. Default is Sparrow XML format.
	 */
	public static function getFont(fontName:String, ?format:BitmapFontFormat):BitmapFontAtlas
	{
		if (_fonts == null) _fonts = new Map();

		if (format == null) format = XML;

		if (!_fonts.exists(fontName))
		{
			_fonts[fontName] = switch(format) {
				case XML: BitmapFontAtlas.loadXMLFont(fontName);
			}
		}

		return _fonts[fontName];
	}

	/*
	 * Load a font in Sparrow XML format.
	 */
	public static function loadXMLFont(file:String):BitmapFontAtlas
	{
		var atlas = new BitmapFontAtlas(StringTools.replace(file, ".fnt", ".png"));

		var xmlText = Assets.getText(file);
		
		if (xmlText == null) throw 'BitmapFontAtlas: "$file" not found!';

		var xml = Xml.parse(xmlText);
		
		var fast = new Fast(xml.firstElement());

		atlas.lineHeight = Std.parseInt(fast.node.common.att.lineHeight);
		atlas.fontSize = Std.parseInt(fast.node.info.att.size);
		var chars = fast.node.chars;

		for (char in chars.nodes.char)
		{
			HXP.rect.x = Std.parseInt(char.att.x);
			HXP.rect.y = Std.parseInt(char.att.y);
			HXP.rect.width = Std.parseInt(char.att.width);
			HXP.rect.height = Std.parseInt(char.att.height);

			
			var glyph:String = null;
			if (char.has.letter) {
				glyph = char.att.letter;
			} else if (char.has.id) {
				glyph = String.fromCharCode(Std.parseInt(char.att.id));
			}
			if (glyph == null) throw '"$file" is not a valid .fnt file!';
			
			glyph = switch(glyph) {
				case "space": ' ';
				case "&quot;": '"';
				case "&amp;": '&';
				case "&gt;": '>';
				case "&lt;": '<';
				default: glyph;
			}

			var md:GlyphData = {
				glyph: glyph,
				rect: HXP.rect.clone(),
				xOffset: char.has.xoffset ? Std.parseInt(char.att.xoffset) : 0,
				yOffset: char.has.yoffset ? Std.parseInt(char.att.yoffset) : 0,
				xAdvance: char.has.xadvance ? Std.parseInt(char.att.xadvance) : 0
			};

			// set the defined region
			var region = atlas.defineRegion(glyph, HXP.rect);
			atlas.glyphData[glyph] = md;
		}
		return atlas;
	}

	private function new(source:Dynamic)
	{
		super(source);
		glyphData = new Map();
	}

	/*
	 * Returns an AtlasRegion for a given character, or whitespace if that
	 * character is not found.
	 */
	public function getChar(name:String):AtlasRegion
	{
		try {
			return getRegion(name);
		} catch(msg:String) {
			return getRegion(' ');
		}
	}

	private static var _fonts:Map<String, BitmapFontAtlas>;

}
