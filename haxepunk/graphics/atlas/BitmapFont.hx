package haxepunk.graphics.atlas;

class BitmapFont implements IBitmapFont
{
	public var fontName:String;

	var atlases:Array<BitmapFontAtlas> = new Array();

	public function new(fontName:String)
	{
		this.fontName = fontName;
	}

	/**
	 * Add a BitmapFontAtlas for a new size to this font.
	 */
	public function addSize(atlas:BitmapFontAtlas)
	{
		for (i in 0 ... atlases.length + 1)
		{
			if (i == atlases.length || atlases[i].fontSize > atlas.fontSize)
			{
				atlases.insert(i, atlas);
			}
		}
	}

	/**
	 * Get information about a glyph from this font.
	 */
	public function getChar(string:String, size:Float):GlyphData
	{
		var atlas = atlasForScale(size);
		var glyph = atlas.getChar(string, size);
		return glyph;
	}

	public function getLineHeight(size:Float)
	{
		var atlas = atlasForScale(size);
		return atlas.lineHeight * size / atlas.fontSize;
	}

	inline function atlasForScale(size:Float):BitmapFontAtlas
	{
		var best:BitmapFontAtlas = null;
		for (atlas in atlases)
		{
			best = atlas;
			if (atlas.fontSize > size) break;
		}
		return best;
	}
}
