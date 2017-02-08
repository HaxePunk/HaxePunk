package haxepunk;

import haxepunk.ds.Either;
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
abstract TileType(Either<BitmapData, TileAtlas>)
{
	private inline function new(e:Either<BitmapData, TileAtlas>) this = e;
	@:dox(hide) public var type(get, never):Either<BitmapData, TileAtlas>;
	@:to inline function get_type() return this;

	@:dox(hide) @:from public static inline function fromString(tileset:String)
	{
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new TileType(Right(new TileAtlas(tileset)));
		else
			return new TileType(Left(HXP.getBitmap(tileset)));
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas)
	{
		return new TileType(Right(atlas));
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData)
	{
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new TileType(Right(new TileAtlas(bd)));
		else
			return new TileType(Left(bd));
	}
}

/**
 * Abstract representing either a `String`, a `TileAtlas`, a `BitmapData` or a `AtlasRegion`.
 * 
 * Conversion is automatic, no need to use this.
 */
abstract ImageType(Either<BitmapData, AtlasRegion>)
{
	private inline function new(e:Either<BitmapData, AtlasRegion>) this = e;
	@:dox(hide) public var type(get, never):Either<BitmapData, AtlasRegion>;
	@:to inline function get_type() return this;

	@:dox(hide) @:from public static inline function fromString(s:String)
	{
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new ImageType(Right(Atlas.loadImageAsRegion(s)));
		else
			return new ImageType(Left(HXP.getBitmap(s)));
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas)
	{
		return new ImageType(Right(atlas.getRegion(0)));
	}
	@:dox(hide) @:from public static inline function fromAtlasRegion(region:AtlasRegion)
	{
		return new ImageType(Right(region));
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData)
	{
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new ImageType(Right(Atlas.loadImageAsRegion(bd)));
		else
			return new ImageType(Left(bd));
	}

	public var width(get, never):Int;
	inline function get_width()
	{
		return Std.int(switch (this)
		{
			case Left(b): b.width;
			case Right(a): a.width;
		});
	}

	public var height(get, never):Int;
	inline function get_height()
	{
		return Std.int(switch (this)
		{
			case Left(b): b.height;
			case Right(a): a.height;
		});
	}
}

/**
 * An abstract which can either be a static image or a tiled image.
 *
 * Conversion is automatic, no need to use this.
 */
abstract ImageOrTileType(Either<ImageType, TileType>)
{
	private inline function new(e:Either<ImageType, TileType>) this = e;
	@:dox(hide) public var type(get, never):Either<ImageType, TileType>;
	@:to inline function get_type() return this;

	@:dox(hide) @:from public static inline function fromString(tileset:String):ImageOrTileType
	return new ImageOrTileType(Right(TileType.fromString(tileset)));
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData):ImageOrTileType
	return new ImageOrTileType(Right(TileType.fromBitmapData(bd)));
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas):ImageOrTileType
	return new ImageOrTileType(Right(TileType.fromTileAtlas(atlas)));
	@:dox(hide) @:from public static inline function fromAtlasRegion(region:AtlasRegion):ImageOrTileType
	return new ImageOrTileType(Left(ImageType.fromAtlasRegion(region)));
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
	private inline function get_visible():Bool return _visible;
	private inline function set_visible(value:Bool):Bool return _visible = value;

	/**
	 * X offset.
	 */
	@:isVar public var x(get, set):Float = 0;
	private inline function get_x():Float return x;
	private inline function set_x(value:Float):Float return x = value;

	/**
	 * Y offset.
	 */
	@:isVar public var y(get, set):Float = 0;
	private inline function get_y():Float return y;
	private inline function set_y(value:Float):Float return y = value;

	/**
	 * X scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollX:Float = 0;

	/**
	 * Y scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollY:Float = 0;

	/**
	 * If the graphic should render at its position relative to its parent Entity's position.
	 */
	public var relative:Bool = true;

	/**
	 * If we can blit the graphic or not (flash/html5)
	 */
	public var blit(default, null):Bool = false;

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
	 * Renders the graphic to the screen buffer.
	 * @param  target     The buffer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	@:dox(hide)
	public function render(target:BitmapData, point:Point, camera:Point) {}

	/**
	 * Renders the graphic as an atlas.
	 * @param  layer      The layer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	@:dox(hide)
	public function renderAtlas(layer:Int, point:Point, camera:Point) {}

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
