package haxepunk.masks;

import haxepunk.math.Vector3;

interface Mask
{

	public function intersects(other:Mask):Bool;
	public function collide(other:Mask):Vector3;
	public function intersectsPoint(vec:Vector3):Bool;

}
