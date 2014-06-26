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

	private inline function loadImage(path:String)
	{
		var image = Assets.getImage(path);
		width = originalWidth = image.width;
		height = originalHeight = image.height;

		switch (HXP.context)
		{
			case OPENGL(gl):
				image.convertToPOT();
				width = image.width;
				height = image.height;

				_texture = gl.createTexture();
				gl.bindTexture(gl.TEXTURE_2D, _texture);
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.bytes);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
			case FLASH(stage):
			default:
		}
	}

	private var _texture:GLTexture;
	private static var _textures = new StringMap<Texture>();
	private static var _lastBoundTexture:GLTexture;

}
