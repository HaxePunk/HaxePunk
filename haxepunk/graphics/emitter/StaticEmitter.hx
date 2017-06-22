package haxepunk.graphics.emitter;

import haxepunk.utils.BlendMode;
import haxepunk.Graphic.ImageType;

class StaticEmitter extends BaseEmitter<Image>
{
	public function new(source:ImageType)
	{
		super(new Image(source));
		_source.centerOrigin();
	}

	public inline function newType(name:String, ?blendMode:BlendMode):ParticleType
	{
		return addType(name, blendMode);
	}
}
