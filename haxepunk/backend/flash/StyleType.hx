package haxepunk.backend.flash;

import flash.text.TextFormat;
import haxepunk.graphics.text.TextOptions;

/**
 * Abstract representing either a `TextFormat` or a `TextOptions`.
 *
 * Conversion is automatic, no need to use this.
 */
@:dox(hide)
abstract StyleType(TextFormat)
{
	function new(format:TextFormat) this = format;
	@:to public function toTextformat():TextFormat return this;

	@:from public static inline function fromTextFormat(format:TextFormat) return new StyleType(format);
	@:from public static inline function fromTextOptions(object:TextOptions) return fromDynamic(object);
	@:from public static inline function fromDynamic(object:Dynamic)
	{
		var format = new TextFormat();
		var fields = Type.getInstanceFields(TextFormat);

		for (key in Reflect.fields(object))
		{
			if (HXP.indexOf(fields, key) > -1)
			{
				Reflect.setField(format, key, Reflect.field(object, key));
			}
			else
			{
				throw '"' + key + '" is not a TextFormat property';
			}
		}
		return new StyleType(format);
	}
}
