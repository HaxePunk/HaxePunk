package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;

class ParticleEmitter extends Graphic
{

	public function new(source:ImageSource, frameWidth:Int=0, frameHeight:Int=0)
	{
		super();
#if !unit_test
		material = source;
#end
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		if (material == null) return;
		calculateMatrixWithOffset(offset);
		HXP.spriteBatch.draw(material, _matrix);
	}

}
