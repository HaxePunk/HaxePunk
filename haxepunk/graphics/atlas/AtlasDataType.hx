package haxepunk.graphics.atlas;

import flash.display.BitmapData;

/**
 * Abstract representing either a `String`, a `AtlasData` or a `BitmapData`.
 *
 * Conversion is automatic, no need to use this.
 */
abstract AtlasDataType(AtlasData)
{
	inline function new(data:AtlasData) this = data;
	@:dox(hide) @:to public inline function toAtlasData():AtlasData return this;

	@:dox(hide) @:from public static inline function fromString(s:String)
	{
		return new AtlasDataType(AtlasData.getAtlasDataByName(s, true));
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData)
	{
		return new AtlasDataType(new AtlasData(bd));
	}
	@:dox(hide) @:from public static inline function fromAtlasData(data:AtlasData)
	{
		return new AtlasDataType(data);
	}
}
