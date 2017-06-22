package haxepunk.utils;

@:enum
abstract BlendMode(Int) from Int to Int {
	public var Add = 0;
	public var Alpha = 1;
	public var Multiply = 9;
	public var Screen = 12;
	public var Subtract = 14;

#if nme
	@:from public static function fromNmeBlendMode(blend:nme.display.BlendMode):BlendMode
	{
		return switch (blend)
		{
			case ADD: Add;
			case MULTIPLY: Multiply;
			case SCREEN: Screen;
			case SUBTRACT: Subtract;
			default: Alpha;
		}
	}
#elseif openfl
	@:from public static function fromFlashBlendMode(blend:flash.display.BlendMode):BlendMode return cast blend;
#end
}
