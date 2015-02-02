package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;
import haxepunk.scene.Camera;

class Graphic
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
	 * Origin of the image. Rotations will be anchored around this point
	 */
	public var origin:Vector3;

	/**
	 * Width of the image.
	 */
	public var width(default, null):Float;

	/**
	 * Height of the image.
	 */
	public var height(default, null):Float;

	public function new()
	{
		_matrix = new Matrix4();
		scale = new Vector3(1, 1, 1);
		origin = new Vector3();
	}

	public function centerOrigin():Void
	{
		origin.x = width / 2;
		origin.y = height / 2;
	}

	public function draw(offset:Vector3):Void {}
	public function update(elapsed:Float) {}

	private var _matrix:Matrix4;

}

/**
 * A Graphic that can contain multiple Graphics of one or various types.
 * Useful for drawing sprites with multiple different parts, etc.
 */
class GraphicList extends Graphic
{

	/**
	 * Constructor.
	 * @param	...graphics		Graphic objects to add to the list.
	 */
	public function new(?graphics:Array<Graphic>)
	{
		super();
		_children = (graphics == null) ? new Array<Graphic>() : graphics;
	}

	/**
	 * Adds the Graphic to the list.
	 * @param	graphic		The Graphic to add.
	 * @return	The added Graphic.
	 */
	public function add(graphic:Graphic):Graphic
	{
		_children.push(graphic);
		return graphic;
	}

	/**
	 * Removes the Graphic from the list.
	 * @param	graphic		The Graphic to remove.
	 * @return	The removed Graphic.
	 */
	public function remove(graphic:Graphic):Graphic
	{
		_children.remove(graphic);
		return graphic;
	}

	/** @private Draws the Graphics in the list. */
	override public function draw(offset:Vector3):Void
	{
		for (i in 0..._children.length)
		{
			_children[i].draw(offset);
		}
	}

	override public function update(elapsed:Float):Void
	{
		for (i in 0..._children.length)
		{
			_children[i].update(elapsed);
		}
	}

	private var _children:Array<Graphic>;
}
