package haxepunk;

import haxe.ds.Either;
import haxepunk.assets.AssetCache;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.AtlasResolutions;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.hardware.Texture;
import haxepunk.graphics.shader.Shader;
import haxepunk.graphics.shader.TextureShader;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;
import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;

/**
 * Abstract representing either a `String`, a `TileAtlas` or a `Texture`.
 *
 * Conversion is automatic, no need to use this.
 */
abstract TileType(TileAtlas) from TileAtlas to TileAtlas
{
	@:dox(hide) @:from public static inline function fromString(tileset:String):TileType
	{
		return AssetCache.global.getTileAtlas(tileset, false);
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas):TileType
	{
		return atlas;
	}
	@:dox(hide) @:from public static inline function fromTexture(bd:Texture):TileType
	{
		return new TileAtlas(bd);
	}
}

/**
 * Abstract representing either a `String`, a `TileAtlas`, a `Texture` or a `AtlasRegion`.
 *
 * Conversion is automatic, no need to use this.
 */
@:forward(width, height)
abstract ImageType(IAtlasRegion) from IAtlasRegion to IAtlasRegion
{
	@:dox(hide) @:from public static inline function fromString(s:String):ImageType
	{
		var region = AssetCache.global.getAtlasRegion(s, false);
		return region;
	}
	@:dox(hide) @:from public static inline function fromTileAtlas(atlas:TileAtlas):ImageType
	{
		return atlas.getRegion(0);
	}
	@:dox(hide) @:from public static inline function fromAtlasRegion(region:IAtlasRegion):ImageType
	{
		return region;
	}
	@:dox(hide) @:from public static inline function fromTexture(bd:Texture):ImageType
	{
		return Atlas.loadImageAsRegion(bd);
	}
	@:dox(hide) @:from public static inline function fromStrings(v:Array<String>):ImageType
	{
		return new AtlasResolutions([for (image in v) Atlas.loadImageAsRegion(image)]);
	}
	@:dox(hide) @:from public static inline function fromAtlasRegions(v:Array<AtlasRegion>):ImageType
	{
		return new AtlasResolutions(v);
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

	@:from public static inline function fromTexture(bd:Texture):ImageOrTileType
		return Right(TileType.fromTexture(bd));

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
	 * Newly created graphics will have this `smooth` setting by default.
	 */
	public static var smoothDefault:Bool = true;

	/**
	 * If the graphic should update.
	 */
	public var active:Bool = false;

	/**
	 * If the image should be drawn transformed with pixel smoothing.
	 * This will affect drawing performance, but look less pixelly.
	 *
	 * Default value: false if HXP.stage.quality is LOW, true otherwise.
	 */
	public var smooth:Bool;

	/**
	 * Whether this graphic will be snapped to the nearest whole number pixel
	 * position when rendering. If pixelSnapping is set to `true` on the
	 * Camera, snapping will occur regardless of this setting. Some graphics
	 * like Tilemap set this to true by default.
	 */
	public var pixelSnapping:Bool = false;

	/**
	 * If true, this graphic may sometimes "fall through" other textures to
	 * reduce the number of draw calls. This can affect layering.
	 */
	public var flexibleLayer:Bool = false;

	/**
	 * Optional blend mode to use when drawing this image.
	 * Use constants from the haxepunk.utils.BlendMode class.
	 */
	public var blend:BlendMode = BlendMode.Alpha;

	/**
	 * Optional rectangle to clip the portion of this graphic that will be
	 * drawn.
	 * @since 4.0.0
	 */
	public var clipRect:Rectangle;

	/**
	 * The shader to use when drawing this graphic.
	 * @since 4.0.0
	 */
	public var shader:Shader;

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
	 * X origin of the graphic, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originX:Float = 0;

	/**
	 * Y origin of the graphic, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originY:Float = 0;

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(default, set):Float = 1;
	function set_alpha(value:Float):Float
	{
		return alpha = value < 0 ? 0 : (value > 1 ? 1 : value);
	}

	/**
	 * The tinted color of the Image. Use 0xFFFFFF to draw the Image normally.
	 */
	public var color(default, set):Color;
	function set_color(value:Color):Color
	{
		return color = value & 0xffffff;
	}

	/**
	 * If the graphic should render at its position relative to its parent Entity's position.
	 */
	public var relative:Bool = true;

	var _screenClipRect:Rectangle;
	inline function screenClipRect(camera:Camera, x:Float, y:Float)
	{
		if (clipRect != null)
		{
			if (_screenClipRect == null) _screenClipRect = new Rectangle();
			_screenClipRect.setTo(
				(x + clipRect.x) * camera.screenScaleX,
				(y + clipRect.y) * camera.screenScaleY,
				clipRect.width * camera.screenScaleX,
				clipRect.height * camera.screenScaleY
			);
			return _screenClipRect;
		}
		else
		{
			return null;
		}
	}

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new()
	{
		smooth = smoothDefault;
		color = Color.White;
		shader = TextureShader.defaultShader;
		_class = Type.getClassName(Type.getClass(this));
	}

	public inline function floorX(camera:Camera, x:Float) return (pixelSnapping || camera.pixelSnapping) ? camera.floorX(x) : x;
	public inline function floorY(camera:Camera, y:Float) return (pixelSnapping || camera.pixelSnapping) ? camera.floorY(y) : y;

	/**
	 * Updates the graphic.
	 */
	@:dox(hide)
	public function update() {}

	/**
	 * Removes the graphic from the scene
	 */
	public function destroy() {}

	public inline function isPixelPerfect(camera:Camera):Bool
	{
		return pixelSnapping || camera.pixelSnapping;
	}

	/**
	 * Renders the graphic. This may call render or pixelPerfectRender
	 * depending on settings.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	@:dox(hide)
	public function doRender(point:Vector2, camera:Camera)
	{
		if (isPixelPerfect(camera)) pixelPerfectRender(point, camera);
		else render(point, camera);
	}

	/**
	 * Renders the graphic.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	@:dox(hide)
	public function render(point:Vector2, camera:Camera) {}

	/**
	 * Renders the graphic, taking extra care to snap pixel locations and
	 * lengths to whole number positions. Not all graphics need a separate
	 * pixelPerfectRender implementation; by default this will just call
	 * render.
	 * @param  point      The position to draw the graphic.
	 * @param  camera     The camera offset.
	 */
	public function pixelPerfectRender(point:Vector2, camera:Camera) render(point, camera);

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

	/**
	 *  Center the Origin of this graphic.
	 */
	public function centerOrigin() {}

	public function toString():String return '[$_class]';

	var _class:String;
	// Graphic information.
	var _scroll:Bool = true;
	var _point:Vector2 = new Vector2();
	var _visible:Bool = true;
}
