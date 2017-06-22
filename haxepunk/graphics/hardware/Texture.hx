package haxepunk.graphics.hardware;

import flash.Assets;
import flash.display.BitmapData;
import haxe.ds.StringMap;
import haxepunk.utils.Color;

class Texture
{
	public var id(default, null):Int;
	static var idSeq:Int = 0;

	public var width(get, never):Int;
	inline function get_width():Int return bitmap.width;

	public var height(get, never):Int;
	inline function get_height():Int return bitmap.height;

	public var bitmap(default, null):BitmapData;

	public static var nullTexture:Texture = new Texture(null);

	public function new(bitmapData:BitmapData)
	{
		id = idSeq++;
		bitmap = bitmapData;
	}

	public inline function getPixel(x:Int, y:Int)
	{
		return bitmap.getPixel32(x, y);
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

		var data:BitmapData = Assets.getBitmapData(name, false);
		var texture:Texture = null;

		if (data != null)
		{
			texture = new Texture(data);
			_texture.set(name, texture);
		}

		return texture;
	}

	/**
	 * Overwrites the image cache for a given name
	 * @param name  The name of the Texture to overwrite.
	 * @param data  The Texture object.
	 * @return True if the prior bitmap was removed.
	 */
	public static function overwriteCache(name:String, data:Texture):Bool
	{
		var removed = remove(name);
		_texture.set(name, data);
		return removed;
	}

	/**
	 * Removes a bitmap from the cache
	 * @param name  The name of the bitmap to remove.
	 * @return True if the bitmap was removed.
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
		bitmap.dispose();
		bitmap = null;
	}

	public function clone():Texture
	{
		return new Texture(bitmap);
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
		return new Texture(new BitmapData(width, height, transparent, color));
	}

	// Bitmap storage.
	static var _texture:StringMap<Texture> = new StringMap<Texture>();
}
