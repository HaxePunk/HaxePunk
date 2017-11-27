package haxepunk.graphics.text;

@:dox(hide)
#if lime
typedef TextAlignType = haxepunk.backend.lime.TextAlignType;
#else
typedef TextAlignType = String;
#end
