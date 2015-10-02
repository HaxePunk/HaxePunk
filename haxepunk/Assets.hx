package haxepunk;

import haxepunk.graphics.Texture;

class Assets
{
    public static function getText(id:String):String
    {
        return lime.Assets.getText(id);
    }

    public static function exists(id:String):Bool
    {
        return lime.Assets.exists(id);
    }

    /**
     * Get a texture from an asset
     * @param id the asset id to find
     */
    public static function getTexture(id:String):Texture
    {
		if (Texture._textures.exists(id))
		{
			return Texture._textures.get(id);
		}
		else
		{
			var texture = new Texture(id);
			if (Assets.exists(id))
			{
				texture.loadFromImage(lime.Assets.getImage(id).buffer);
				Texture._textures.set(id, texture);
			}
			else
			{
				trace('No texture named $id');
			}
			return texture;
		}
    }
}
