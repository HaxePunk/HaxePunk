package haxepunk.graphics;

import haxepunk.math.Vector3;
import haxepunk.scene.SceneNode;

class Light extends SceneNode
{

	public var ambient:Color;
	public var diffuse:Color;
	public var specular:Color;

	public var spotDirection:Vector3;
	public var spotExponent:Float;
	public var spotCutoff:Float;

	public function new()
	{
		super();
		ambient = new Color();
		diffuse = new Color();
		specular = new Color();
	}

}
