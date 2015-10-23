package haxepunk.masks;

import haxepunk.math.Vector3;
import haxepunk.scene.Entity;

interface Mask
{

	public function intersects(other:Mask):Bool;
	public function overlap(other:Mask):Vector3;
	public function containsPoint(vec:Vector3):Bool;

	@:allow(haxepunk.debug.Console)
	private function debugDraw(offset:Vector3):Void;

}
