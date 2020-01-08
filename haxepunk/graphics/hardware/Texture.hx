package haxepunk.graphics.hardware;

import kha.Image;

import haxepunk.utils.Color;
import haxepunk.utils.Log;

using kha.graphics2.GraphicsExtension;

@:forward(width, height)
abstract Texture(Image) from Image to Image
{
	/**
	 * Create a new texture with given dimensions, transparency and color.
	 * @param width 
	 * @param height 
	 * @param transparent 
	 * @param color 
	 * @return Texture
	 */
	public static inline function create(width:Int, height:Int, transparent:Bool=false, color:Color=Color.Black):Texture
	{
		if(!transparent)
			Log.warning("Textures always have transparency.");
		var tex = Image.create(width, height);
		tex.clear(0, 0, 0, width, height, 1, color);
		return tex;
	}

	/**
	 * Load a texture from an asset given its path.
	 * @param name 
	 * @return Texture
	 */
	public static inline function fromAsset(name:String):Texture
	{
		Log.critical("Asset loading not yet implemented");
		return null;
	}

	/**
	 * Get a pixel's color.
	 * @param x 
	 * @param y 
	 * @return Color
	 */
	public function getPixel(x:Int, y:Int) : Color
	{
		return this.at(x, y);
	}

	/**
	 * Set all the texture's pixels to a given color.
	 * @param color 
	 */
	public function clearColor(color:Color)
	{
		this.clear(0, 0, 0, this.width, this.height, 1, color);
	}
	
	/**
	 * Find and make transparent all the pixels of a given color.
	 * @param color 
	 */
	public function removeColor(color:Color)
	{
		Log.critical("removeColor not implemented");
	}

	public function drawCircle(x:Float, y:Float, radius:Float)
	{
		this.g2.begin();
		this.g2.drawCircle(x, y, radius);
		this.g2.end();
	}

	/**
	 * Dispose of this texture.
	 */
	public function dispose()
	{
		this.unload();
	}
}
