package haxepunk.graphics;

import haxepunk.Graphic.ImageType;

class StaticEmitter extends BaseEmitter<Image>
{
	public function new(source:ImageType)
	{
		super(new Image(source));
		_source.centerOrigin();
	}
}
