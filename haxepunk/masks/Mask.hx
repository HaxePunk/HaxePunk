package haxepunk.masks;

import haxepunk.math.Vector3;
import haxepunk.scene.Entity;

interface Mask
{

	public function intersects(other:Mask):Bool;
	public function collide(other:Mask):Vector3;
	public function intersectsPoint(vec:Vector3):Bool;

	@:allow(haxepunk.debug.Console)
	private function debugDraw(parent:Entity):Void;

}
