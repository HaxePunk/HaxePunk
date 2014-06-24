package haxepunk.graphics;

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lime.graphics.GL;
import lime.graphics.GLTexture;
import lime.utils.UInt8Array;
import lime.utils.ByteArray;
import lime.Assets;

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
		loadImage(path);
	}

	/**
	 * Binds the texture for drawing
	 */
	public inline function bind():Void
	{
		if (_lastBoundTexture != _texture)
		{
			GL.bindTexture(GL.TEXTURE_2D, _texture);
			_lastBoundTexture = _texture;
		}
	}

	public static function clear():Void
	{
		_lastBoundTexture = null;
		GL.bindTexture(GL.TEXTURE_2D, _lastBoundTexture);
	}

	private inline function toPowerOfTwo(value:Int):Int
	{
		return Std.int(Math.pow(2, Math.ceil(Math.log(value) / Math.log(2))));
	}

	@:access(lime.graphics.Image)
	private inline function loadImage(path:String)
	{
		var image = Assets.getImage(path);
		width = originalWidth = image.width;
		height = originalHeight = image.height;

		switch (HXP.context)
		{
			case OPENGL(gl):
				// TODO: handle power of 2 textures
				// width = toPowerOfTwo(image.width);
				// height = toPowerOfTwo(image.height);
				// if (width != originalWidth || height != originalHeight)
				// {
				// }

				_texture = GL.createTexture();
				GL.bindTexture(GL.TEXTURE_2D, _texture);
				GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, image.__bytes);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			case FLASH(stage):
			default:
		}
	}

	private var _texture:GLTexture;
	private static var _textures = new StringMap<Texture>();
	private static var _lastBoundTexture:GLTexture;

}
