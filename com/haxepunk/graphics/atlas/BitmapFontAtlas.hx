package com.haxepunk.graphics.atlas;

import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.HXP;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import openfl.Assets;
import haxe.xml.Fast;


enum BitmapFontFormat
{
	XML;
	XNA;
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
	 * @param extraParams Additional parameters to pass to the format-specific load() function.
	 */
	public static function getFont(fontName:String, ?format:BitmapFontFormat, ?extraParams:Dynamic):BitmapFontAtlas
	{
		if (_fonts == null) _fonts = new Map();

		if (format == null) format = XML;
		if (fontName == HXP.defaultFont + ".png") format = XNA;

		if (!_fonts.exists(fontName))
		{
			_fonts[fontName] = switch(format) {
				case XML: BitmapFontAtlas.loadXMLFont(fontName);
				case XNA: BitmapFontAtlas.loadXNAFont(fontName, extraParams);
			}
		}

		return _fonts[fontName];
	}

	/*
	 * Load a font from Sparrow (or BMFont) XML format.
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
			if (char.has.letter)
			{
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

	/*
	 * Load a font from XNA/BMFont format.
	 * @param asset		An asset
	 * @param options 	An object containing optional parameters
	 * 						letters			String of glyphs contained in the asset, in order (ex. " abcdefghijklmnopqrstuvwxyz"). Defaults to _DEFAULT_GLYPHS.
	 * 						glyphBGColor	An additional background color to remove. Defaults to 0xFF202020, often used for glyphs background.
	 */
	@:access(com.haxepunk.graphics.atlas.AtlasData)
	public static function loadXNAFont(asset:String, ?options:Dynamic):BitmapFontAtlas
	{
		var atlas = new BitmapFontAtlas(asset);
		var bmd:BitmapData = null;
		
		try
		{
			bmd = atlas._data.bitmapData;
		}
		catch (_:Dynamic) { }
	
		if (bmd == null)
			throw 'Invalid XNA font asset "$asset": no BitmapData found.';
		
		if (options == null)
			options = {};

		// defaults
		if (!Reflect.hasField(options, "letters"))
			options.letters = _DEFAULT_GLYPHS;

		if (!Reflect.hasField(options, "glyphBGColor"))
			options.glyphBGColor = 0xFF202020;
		
		var glyphString:String = options.letters;
		var globalBGColor:Int = bmd.getPixel(0, 0);
		var cy:Int = 0;
		var cx:Int;
		var letterIdx:Int = 0;
		var glyph:String;
		var alphabetLength = glyphString.length;
		
		while (cy < bmd.height && letterIdx < alphabetLength)
		{
			var rowHeight:Int = 0;
			cx = 0;
			
			while (cx < bmd.width && letterIdx < alphabetLength)
			{
				if (Std.int(bmd.getPixel(cx, cy)) != globalBGColor) 
				{
					// found non bg pixel
					var gx:Int = cx;
					var gy:Int = cy;
					
					// find width and height of glyph
					while (Std.int(bmd.getPixel(gx, cy)) != globalBGColor) gx++;
					while (Std.int(bmd.getPixel(cx, gy)) != globalBGColor) gy++;
					
					var gw:Int = gx - cx;
					var gh:Int = gy - cy;
					
					glyph = glyphString.charAt(letterIdx);
					HXP.rect.setTo(cx, cy, gw, gh);
					
					var md:GlyphData = {
						glyph: glyph,
						rect: HXP.rect.clone(),
						xOffset: 0,
						yOffset: 0,
						xAdvance: gw
					};

					// set the defined region
					var region = atlas.defineRegion(glyph, HXP.rect);
					atlas.glyphData[glyph] = md;
					
					// store max size
					if (gh > rowHeight) rowHeight = gh;
					if (gh > atlas.fontSize) atlas.fontSize = gh;
					
					// go to next glyph
					cx += gw;
					letterIdx++;
				}
				
				cx++;
			}
			// next row
			cy += (rowHeight + 1);
		}
		
		atlas.lineHeight = atlas.fontSize;
		
		// remove background color
		var bgColor32:Int = bmd.getPixel32(0, 0);
		bmd.threshold(bmd, bmd.rect, HXP.zero, "==", bgColor32, 0x00000000, 0xFFFFFFFF, true);
		
		if (options.glyphBGColor != null)
			bmd.threshold(bmd, bmd.rect, HXP.zero, "==", options.glyphBGColor, 0x00000000, 0xFFFFFFFF, true);
		
		
		return atlas;
	}

	private function new(source:AtlasDataType)
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
	private static var _DEFAULT_GLYPHS:String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
}
