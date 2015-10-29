package haxepunk.graphics;

import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lime.utils.*;
import lime.Assets;
import haxepunk.renderers.Renderer;
import haxepunk.math.Math;

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
	public var sourceWidth(default, null):Int = 0;
	/**
	 * The height of the original texture
	 */
	public var sourceHeight(default, null):Int = 0;

	/**
	 * Create a texture from RGBA data.
	 * @param data the RGBA texture data. Must be 4 Int values per pixel.
	 * @param stride the byte width of the texture.
	 */
	public static function fromRGBA(data:Array<Int>, stride:Int):Texture
	{
		var texture = new Texture();
		texture.loadFromBytes(new UInt8Array(data), stride);
		return texture;
	}

	/**
	 * Creates texture from XPM data. http://en.wikipedia.org/wiki/X_PixMap
	 * @param xpm a string of xpm data
	 */
	public static function fromXPM(xpm:String):Texture
	{
		var lines = xpm.split("\n");
		if ("! XPM" != lines.shift()) return null;

		var format = lines.shift().split(" ");
		var width = Std.parseInt(format[0]);
		var height = Std.parseInt(format[1]);
		var numColors = Std.parseInt(format[2]);
		var charPerPixel = Std.parseInt(format[3]);

		var bytes = new UInt8Array(width * height * 4);
		var colors = new StringMap<Int>();

		for (i in 0...numColors)
		{
			var fields = lines.shift().split(" ");
			var color = 0, c = 0;
			var colorStr = fields[2];
			for (i in 0...colorStr.length)
			{
				var code = StringTools.fastCodeAt(colorStr, i);
				if (code >= '0'.code && code <= '9'.code)
				{
					c = (code - '0'.code);
				}
				else if (code >= 'A'.code && code <= 'F'.code)
				{
					c = (code - 'A'.code + 10);
				}
				else
				{
					continue;
				}
				color |= c << ((colorStr.length - i - 1) * 4);
			}
			// add alpha
			colors.set(fields[0], color);
		}

		for (y in 0...lines.length)
		{
			if (y >= height) break;
			var line = lines[y];
			for (x in 0...Std.int(line.length / charPerPixel))
			{
				if (x >= width) break;
				var colorId = "";
				for (i in 0...charPerPixel)
				{
					colorId += line.charAt(x * charPerPixel + i);
				}
				if (colors.exists(colorId))
				{
					var color = colors.get(colorId);
					var byteOffset = (y * width + x) * 4;
					bytes[byteOffset] = color >> 16 & 0xFF;
					bytes[byteOffset+1] = color >> 8 & 0xFF;
					bytes[byteOffset+2] = color & 0xFF;
					bytes[byteOffset+3] = 0xFF;
				}
				else
				{
					throw 'Unknown color "$colorId" in XPM data';
				}
			}
		}

		var texture = new Texture();
		texture.loadFromBytes(bytes, width);
		return texture;
	}

	@:allow(haxepunk.graphics, haxepunk.Assets)
	private function new(?id:String)
	{
		if (_id == null)
		{
			_id = Math.uuid();
		}
		_textures.set(_id, this);
	}

	private function loadFromBytes(bytes:UInt8Array, stride:Int)
	{
		width = sourceWidth = stride;
		height = sourceHeight = Std.int(bytes.byteLength / stride / 4);
		#if flash
		for (i in 0...Std.int(bytes.length / 4))
		{
			var tmp = bytes[i * 4];
			bytes[i * 4] = bytes[i * 4 + 2];
			bytes[i * 4 + 2] = tmp;
		}
		#end
		_texture = Renderer.createTextureFromBytes(bytes, width, height);
	}

	@:allow(haxepunk.graphics, haxepunk.Assets)
	private function loadFromImage(image:lime.graphics.Image)
	{
		if (image == null || image.buffer == null) return;
		var buffer = image.buffer;
		sourceWidth = buffer.width;
		sourceHeight = buffer.height;

		_texture = Renderer.createTexture(buffer);
		width = buffer.width;
		height = buffer.height;
	}

	/**
	 * Removes a texture from the renderer.
	 */
	public function destroy()
	{
		Renderer.deleteTexture(_texture);
		_textures.remove(_id);
	}

	/**
	 * Binds the texture for drawing
	 * @param sampler the id of the sampler to use
	 */
	public inline function bind(sampler:Int=0):Void
	{
		Renderer.bindTexture(_texture, sampler);
	}

	private var _texture:NativeTexture;
	private var _id:String;

	@:allow(haxepunk.Assets)
	private static var _textures = new StringMap<Texture>();

}
