package haxepunk.masks;

import haxepunk.math.Vector3D;

interface Mask
{

	public function intersects(other:Mask):Bool;
	public function collide(other:Mask):Vector3D;

}
