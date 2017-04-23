package haxepunk.graphics;

import flash.display.BlendMode;
import haxepunk.Graphic.ImageType;
import haxepunk.graphics.BaseEmitter.ParticleType;

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
