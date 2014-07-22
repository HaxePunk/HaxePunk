package haxepunk.graphics;

import haxepunk.HXP;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class Image implements Graphic
{

	public var material:Material;

	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the image.
	 */
	public var scale:Vector3;

	/**
	 * Origin of the image.
	 */
	public var origin:Vector3;

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
	 * Width of the image.
	 */
	public var width(get, never):Float;
	private function get_width():Float { return _texture.width; }

	/**
	 * Height of the image.
	 */
	public var height(get, never):Float;
	private function get_height():Float { return _texture.height; }

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(default, set):Float;
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		return (alpha == value) ? value : alpha = value;
	}

	public function new(material:Material)
	{
		scale = new Vector3(1, 1, 1);
		origin = new Vector3();
		_matrix = new Matrix4();

#if !unit_test
		this.material = material;
		_texture = material.techniques[0].passes[0].getTexture(0);
		if (_texture == null) throw "Must have a texture attached for materials used in Image";
#end
	}

	public function update(elapsed:Float) {}

	public function centerOrigin():Void
	{
		origin.x = -(width / 2);
		origin.y = -(height / 2);
	}

	private function calculateMatrixWithOffset(offset:Vector3)
	{
		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.scale(width, height, 1);
		_matrix.translateVector3(origin);
		_matrix.scaleVector3(scale);
		// if (angle != 0) _matrix.rotateZ(angle);

		origin -= offset;
		origin /= scale;
	}

	public function draw(camera:Camera, offset:Vector3):Void
	{
		if (material == null) return;
		calculateMatrixWithOffset(offset);
		HXP.spriteBatch.draw(this, _matrix);
	}

	private var _matrix:Matrix4;
	private var _texture:Texture;

}
