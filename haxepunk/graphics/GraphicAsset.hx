package haxepunk.graphics;

abstract GraphicAsset(Material)
{
	inline function new(material:Material) { this = material; }

	@:to
	public function toMaterial():Material
	{
		return this;
	}

	@:from
	static public function fromMaterial(material:Material):GraphicAsset
	{
		return new GraphicAsset(material);
	}

	@:from
	static public function fromTexture(texture:Texture):GraphicAsset
	{
		var material = new Material();
		material.firstPass.addTexture(texture);
		return new GraphicAsset(material);
	}

	@:from
	static public function fromString(asset:String):GraphicAsset
	{
		return fromTexture(new TextureAtlas(Texture.fromAsset(asset)));
	}
}
