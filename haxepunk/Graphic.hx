package haxepunk;

import haxe.ds.Either;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.graphics.atlas.AtlasRegion;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * Abstract representing either a `String`, a `TileAtlas` or a `BitmapData`.
 *
 * Conversion is automatic, no need to use this.
 */
abstract TileType(TileAtlas) from TileAtlas to TileAtlas
{
	@:dox(hide) @:from public static inline function fromString(tileset:String):TileType
	{
		return new TileAtlas(tileset);
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas):TileType
	{
		return atlas;
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData):TileType
	{
		return new TileAtlas(bd);
	}
}

/**
 * Abstract representing either a `String`, a `TileAtlas`, a `BitmapData` or a `AtlasRegion`.
 *
 * Conversion is automatic, no need to use this.
 */
@:forward(width, height)
abstract ImageType(AtlasRegion) from AtlasRegion to AtlasRegion
{
	@:dox(hide) @:from public static inline function fromString(s:String):ImageType
	{
		return Atlas.loadImageAsRegion(s);
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas):ImageType
	{
		return atlas.getRegion(0);
	}
	@:dox(hide) @:from public static inline function fromAtlasRegion(region:AtlasRegion):ImageType
	{
		return region;
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData):ImageType
	{
		return Atlas.loadImageAsRegion(bd);
	}
}

/**
 * An abstract which can either be a static image or a tiled image.
 *
 * Conversion is automatic, no need to use this.
 */
@:dox(hide)
abstract ImageOrTileType(Either<ImageType, TileType>) from Either<ImageType, TileType>
{
	@:from public static inline function fromString(tileset:String):ImageOrTileType
		return Right(TileType.fromString(tileset));

	@:from public static inline function fromBitmapData(bd:BitmapData):ImageOrTileType
		return Right(TileType.fromBitmapData(bd));

	@:from public static inline function fromTileAtlas(atlas:TileAtlas):ImageOrTileType
		return Right(TileType.fromTileAtlas(atlas));

	@:from public static inline function fromAtlasRegion(region:AtlasRegion):ImageOrTileType
		return Left(ImageType.fromAtlasRegion(region));
}

/**
 * Base class for graphics type.
 * Do not use this directly, instead use the classes in haxepunk.graphics.*
 */
class Graphic
{
	/**
	 * If the graphic should update.
	 */
	public var active:Bool = false;

	/**
	 * If the graphic should render.
	 */
	public var visible(get, set):Bool;
	inline function get_visible():Bool return _visible;
	inline function set_visible(value:Bool):Bool return _visible = value;

	/**
	 * X offset.
	 */
	@:isVar public var x(get, set):Float = 0;
	inline function get_x():Float return x;
	inline function set_x(value:Float):Float return x = value;

	/**
	 * Y offset.
	 */
	@:isVar public var y(get, set):Float = 0;
	inline function get_y():Float return y;
	inline function set_y(value:Float):Float return y = value;

	/**
	 * X scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollX:Float = 1;

	/**
	 * Y scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollY:Float = 1;

	/**
	 * If the graphic should render at its position relative to its parent Entity's position.
	 */
	public var relative:Bool = true;

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new() {}

	/**
	 * Updates the graphic.
	 */
	@:dox(hide)
	public function update() {}

	/**
	 * Removes the graphic from the scene
	 */
	public function destroy() {}

	/**
	 * Renders the graphic as an atlas.
	 * @param  layer      The layer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	@:dox(hide)
	public function render(layer:Int, point:Point, camera:Camera) {}

	/**
	 * Pause updating this graphic.
	 */
	public function pause()
	{
		active = false;
	}

	/**
	 * Resume updating this graphic.
	 */
	public function resume()
	{
		active = true;
	}

	// Graphic information.
	var _scroll:Bool = true;
	var _point:Point = new Point();
	var _entity:Entity;

	var _visible:Bool = true;
}
