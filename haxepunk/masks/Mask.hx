package haxepunk.masks;

import haxepunk.math.Vector3;
import haxepunk.scene.Entity;
import haxepunk.graphics.Color;

interface Mask
{

	public function intersects(other:Mask):Bool;
	public function overlap(other:Mask):Vector3;
	public function containsPoint(vec:Vector3):Bool;
	public function debugDraw(offset:Vector3, color:Color):Void;

}
