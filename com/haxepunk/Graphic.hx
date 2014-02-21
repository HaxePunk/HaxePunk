package com.haxepunk;

import com.haxepunk.HXP;
import com.haxepunk.ds.Either;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.TileAtlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import flash.display.BitmapData;
import flash.geom.Point;

typedef AssignCallback = Void -> Void;

abstract TileType(Either<BitmapData, TileAtlas>)
{
	private inline function new(e:Either<BitmapData, TileAtlas>) this = e;
	public var type(get,never):Either<BitmapData, TileAtlas>;
	@:to inline function get_type() return this;

	@:from public static inline function fromString(tileset:String) {
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new TileType(Right(new TileAtlas(tileset)));
		else
			return new TileType(Left(HXP.getBitmap(tileset)));
	}
	@:from public static inline function fromTileAtlas(atlas:TileAtlas) {
		return new TileType(Right(atlas));
	}
	@:from public static inline function fromBitmapData(bd:BitmapData) {
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new TileType(Right(new TileAtlas(bd)));
		else
			return new TileType(Left(bd));
	}
}

abstract ImageType(Either<BitmapData, AtlasRegion>)
{
	private inline function new(e:Either<BitmapData, AtlasRegion>) this = e;
	public var type(get,never):Either<BitmapData, AtlasRegion>;
	@:to inline function get_type() return this;

	@:from public static inline function fromString(s:String) {
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new ImageType(Right(Atlas.loadImageAsRegion(s)));
		else
			return new ImageType(Left(HXP.getBitmap(s)));
	}
	@:from public static inline function fromAtlasRegion(region:AtlasRegion) {
		return new ImageType(Right(region));
	}
	@:from public static inline function fromBitmapData(bd:BitmapData) {
		if (HXP.renderMode == RenderMode.HARDWARE)
			return new ImageType(Right(Atlas.loadImageAsRegion(bd)));
		else
			return new ImageType(Left(bd));
	}
}

class Graphic
{
	/**
	 * If the graphic should update.
	 */
	public var active:Bool;

	/**
	 * If the graphic should render.
	 */
	public var visible(get, set):Bool;
	private function get_visible():Bool { return _visible; }
	private function set_visible(value:Bool):Bool { return _visible = value; }

	/**
	 * X offset.
	 */
	@:isVar public var x(get, set):Float;
	private inline function get_x():Float { return x; }
	private inline function set_x(value:Float):Float { return x = value; }

	/**
	 * Y offset.
	 */
	@:isVar public var y(get, set):Float;
	private inline function get_y():Float { return y; }
	private inline function set_y(value:Float):Float { return y = value; }

	/**
	 * X scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollX:Float;

	/**
	 * Y scrollfactor, effects how much the camera offsets the drawn graphic.
	 * Can be used for parallax effect, eg. Set to 0 to follow the camera,
	 * 0.5 to move at half-speed of the camera, or 1 (default) to stay still.
	 */
	public var scrollY:Float;

	/**
	 * If the graphic should render at its position relative to its parent Entity's position.
	 */
	public var relative:Bool;

	/**
	 * If we can blit the graphic or not (flash/html5)
	 */
	public var blit(default, null):Bool;

	/**
	 * Constructor.
	 */
	public function new()
	{
		active = false;
		visible = true;
		x = y = 0;
		scrollX = scrollY = 1;
		relative = true;
		_scroll = true;
		_point = new Point();
	}

	/**
	 * Updates the graphic.
	 */
	public function update()
	{

	}

	/**
	 * Removes the graphic from the scene
	 */
	public function destroy() { }

	/**
	 * Renders the graphic to the screen buffer.
	 * @param  target     The buffer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	public function render(target:BitmapData, point:Point, camera:Point) { }

	/**
	 * Renders the graphic as an atlas.
	 * @param  layer      The layer to draw to.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	public function renderAtlas(layer:Int, point:Point, camera:Point) { }

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
	private var _scroll:Bool;
	private var _point:Point;
	private var _entity:Entity;

	private var _visible:Bool;
}
