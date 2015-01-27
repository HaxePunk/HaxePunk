package haxepunk.graphics;

import haxepunk.HXP;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.math.Rectangle;
import haxepunk.scene.Camera;

abstract ImageSource(Material) to Material from Material
{
	public function new(material:Material) { this = material; }

	@:from
	static inline private function fromAsset(asset:String):ImageSource
	{
		var material = new Material();
		material.firstPass.addTexture(TextureAtlas.fromAsset(asset));
		return new ImageSource(material);
	}
}

class Image extends Graphic
{

	/**
	 * Flip image on the x-axis
	 * NOTE: This changes the image's scale value. By modifying scale.x you may unintentionally update flippedX.
	 */
	public var flippedX(get, set):Bool;
	private inline function get_flippedX():Bool { return scale.x < 0; }
	private function set_flippedX(value:Bool):Bool {
		scale.x = Math.abs(scale.x) * (value ? -1 : 1);
		return value;
	}

	/**
	 * Flip image on the y-axis
	 * NOTE: This changes the image's scale value. By modifying scale.y you may unintentionally update flippedY.
	 */
	public var flippedY(get, set):Bool;
	private inline function get_flippedY():Bool { return scale.y < 0; }
	private function set_flippedY(value:Bool):Bool {
		scale.y = Math.abs(scale.y) * (value ? -1 : 1);
		return value;
	}

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(default, set):Float;
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		return (alpha == value) ? value : alpha = value;
	}

	public function new(source:ImageSource, ?clipRect:Rectangle)
	{
		super();

#if !unit_test
		this.material = source;
		var texture = this.material.firstPass.getTexture(0);
		if (texture == null) throw "Must have a texture attached for materials used in Image";

		if (clipRect == null)
		{
			width = texture.width;
			height = texture.height;
		}
		else
		{
			var atlas = cast(texture, TextureAtlas);
			_tileIndex = atlas.addTile(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			width = clipRect.width;
			height = clipRect.height;
		}
#end
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		if (material == null) return;
		calculateMatrixWithOffset(offset);
		HXP.spriteBatch.draw(material, _matrix, _tileIndex);
	}

	private var _tileIndex = 0;

}
