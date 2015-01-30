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
		material.firstPass.addTexture(Texture.fromAsset(asset));
		return new ImageSource(material);
	}
}

class Image extends Graphic
{

	/**
	 * Flip image on the x-axis
	 */
	public var flipX:Bool = false;

	/**
	 * Flip image on the y-axis
	 */
	public var flipY:Bool = false;

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
			_clipRect = new Rectangle(0, 0, texture.width, texture.height);
		}
		else
		{
			_clipRect = clipRect;
		}
		width = _clipRect.width;
		height = _clipRect.height;
#end
	}

	override public function draw(offset:Vector3):Void
	{
		HXP.spriteBatch.draw(material, offset.x, offset.y, width, height,
			_clipRect.x, _clipRect.y, _clipRect.width, _clipRect.height,
			flipX, flipY, origin.x, origin.y, scale.x, scale.y, angle);
	}

	private var _clipRect:Rectangle;

}
