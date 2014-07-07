package haxepunk.graphics;

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lime.utils.UInt8Array;
import lime.utils.ByteArray;
import lime.Assets;
import haxepunk.renderers.Renderer;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Texture
{

	/**
	 * The width of the texture in memory
	 */
	public var width(default, null):Int = 0;

	/**
	 * The height of the texture in memory
	 */
	public var height(default, null):Int = 0;

	/**
	 * The width of the original texture
	 */
	public var originalWidth(default, null):Int = 0;
	/**
	 * The height of the original texture
	 */
	public var originalHeight(default, null):Int = 0;

	public static function create(path:String):Texture
	{
		var texture:Texture = null;
		if (_textures.exists(path))
		{
			texture = _textures.get(path);
		}
		else
		{
			texture = new Texture(path);
			_textures.set(path, texture);
		}
		return texture;
	}

	/**
	 * Creates a new Texture
	 * @param path The path to the texture asset
	 */
	private function new(path:String)
	{
#if !unit_test
		loadImage(path);
#end
	}

	/**
	 * Binds the texture for drawing
	 */
	public inline function bind():Void
	{
		if (_lastBoundTexture != _texture)
		{
			HXP.renderer.bindTexture(_texture);
			_lastBoundTexture = _texture;
		}
	}

	public static function clear():Void
	{
		_lastBoundTexture = null;
		HXP.renderer.bindTexture(_lastBoundTexture);
	}

	private inline function loadImage(path:String)
	{
		var image = Assets.getImage(path);
		width = originalWidth = image.width;
		height = originalHeight = image.height;

		_texture = HXP.renderer.createTexture(image);
		width = image.width;
		height = image.height;
	}

	private var _texture:NativeTexture;
	private static var _textures = new StringMap<Texture>();
	private static var _lastBoundTexture:NativeTexture;

}
