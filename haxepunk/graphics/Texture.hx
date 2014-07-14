package haxepunk.graphics;

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lime.utils.UInt8Array;
import lime.utils.ByteArray;
import lime.Assets;
import haxepunk.renderers.Renderer;

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
	private function new(?path:String)
	{
#if !unit_test
		if (path != null) loadImage(path);
#end
	}

	public function destroy()
	{
		Renderer.deleteTexture(_texture);
		_textures.remove(_path);
	}

	/**
	 * Binds the texture for drawing
	 */
	public inline function bind(sampler:Int=0):Void
	{
		Renderer.setBlendMode(SOURCE_ALPHA, ONE_MINUS_SOURCE_ALPHA);
		Renderer.bindTexture(_texture, sampler);
	}

	private inline function loadImage(path:String)
	{
		_path = path;
		var image = Assets.getImage(path);
		if (image == null) return;

		width = originalWidth = image.width;
		height = originalHeight = image.height;

		_texture = Renderer.createTexture(image);
		width = image.width;
		height = image.height;
	}

	private var _texture:NativeTexture;
	private var _path:String;
	private static var _textures = new StringMap<Texture>();

}
