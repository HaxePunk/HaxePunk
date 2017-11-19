package haxepunk.graphics.text;

@:dox(hide)
#if lime
typedef TextAlignType = flash.text.TextFormatAlign;
#elseif nme
typedef TextAlignType = String;
#else
enum TextAlignType
{

}
#end
