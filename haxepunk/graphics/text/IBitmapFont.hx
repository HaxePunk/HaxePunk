package haxepunk.graphics.text;

import haxepunk.assets.AssetCache;

@:forward(width, height)
abstract BitmapFontType(IBitmapFont) from IBitmapFont to IBitmapFont
{
	@:dox(hide) @:from public static inline function fromString(s:String):BitmapFontType
	{
		return AssetCache.global.getBitmapFont(s, false);
	}
	@:dox(hide) @:from public static inline function fromFont(font:IBitmapFont):BitmapFontType
	{
		return font;
	}
}

interface IBitmapFont
{
	public function getChar(name:String, size:Float):GlyphData;
	public function getLineHeight(size:Float):Float;
}
