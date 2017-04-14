package haxepunk.graphics.atlas;

interface IBitmapFont
{
	public function getChar(name:String, size:Float):GlyphData;
	public function getLineHeight(size:Float):Float;
}
