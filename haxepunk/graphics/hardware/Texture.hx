package haxepunk.graphics.hardware;

import haxe.ds.StringMap;
import haxepunk.utils.Color;

class Texture
{
	public var id(default, null):Int;
	static var idSeq:Int = 0;

	public var width(get, never):Int;
	inline function get_width():Int return image.width;

	public var height(get, never):Int;
	inline function get_height():Int return image.height;

	public var image(default, null):ImageData;

	public static var nullTexture:Texture = new Texture(null);

	public function new(image:ImageData)
	{
		id = idSeq++;
		this.image = image;
	}

	public inline function getPixel(x:Int, y:Int)
	{
		return image.getPixel32(x, y);
	}

	/**
	 * Fetches a stored Texture object represented by the source.
	 * @param	source		Name of texture asset
	 * @return	The stored Texture object.
	 */
	public static function fromAsset(name:String):Texture
	{
		if (_texture.exists(name))
			return _texture.get(name);

		var texture:Texture = null;
		#if (lime || nme)
		var data = flash.Assets.getBitmapData(name, false);

		if (data != null)
		{
			texture = new Texture(data);
			_texture.set(name, texture);
		}
		#end

		return texture;
	}

	/**
	 * Overwrites the image cache for a given name
	 * @param name  The name of the Texture to overwrite.
	 * @param data  The Texture object.
	 * @return True if the prior image was removed.
	 */
	public static function overwriteCache(name:String, data:Texture):Bool
	{
		var removed = remove(name);
		_texture.set(name, data);
		return removed;
	}

	/**
	 * Removes a image from the cache
	 * @param name  The name of the image to remove.
	 * @return True if the image was removed.
	 */
	public static function remove(name:String):Bool
	{
		if (_texture.exists(name))
		{
			var texture = _texture.get(name);
			texture.dispose();
			texture = null;
			return _texture.remove(name);
		}
		return false;
	}

	public function dispose()
	{
		image.dispose();
		image = null;
	}

	public function clone():Texture
	{
		return new Texture(image);
	}

	/**
	 * Creates Texture based on platform specifics
	 *
	 * @param	width			Texture's width.
	 * @param	height			Texture's height.
	 * @param	transparent		If the Texture can have transparency.
	 * @param	color			Texture's color.
	 *
	 * @return	The Texture.
	 */
	public static function create(width:Int, height:Int, transparent:Bool = false, color:Color = Color.Black):Texture
	{
		return new Texture(new ImageData(width, height, transparent, color));
	}

	// image storage.
	static var _texture:StringMap<Texture> = new StringMap<Texture>();
}
