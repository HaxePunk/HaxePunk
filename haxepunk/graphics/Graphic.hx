package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;
import haxepunk.scene.Camera;

/**
 * The base Graphic class. All graphics are derived from this class and support scaling, rotation, and an origin point.
 */
class Graphic
{

	/**
	 * Material used for this graphic.
	 */
	public var material:Material;

	/**
	 * Rotation of the graphic, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the graphic.
	 */
	public var scale:Vector3;

	/**
	 * Origin of the graphic. Rotations will be anchored around this point
	 */
	public var origin:Vector3;

	/**
	 * Width of the graphic.
	 */
	public var width:Float;

	/**
	 * Height of the graphic.
	 */
	public var height:Float;

	/**
	 * Create a new graphic and initialize the matrix, scale and origin
	 */
	public function new()
	{
		_matrix = new Matrix4();
		scale = new Vector3(1, 1, 1);
		origin = new Vector3();
	}

	/**
	 * Centers the graphic's origin based on the width and height values.
	 */
	public function centerOrigin():Void
	{
		origin.x = width / 2;
		origin.y = height / 2;
	}

	/**
	 * Graphic rendering method
	 * @param offset an offset given to the graphic. Usually from an Entity object.
	 */
	public function draw(offset:Vector3):Void {}

	/**
	 * Graphic update method, fired every frame
	 * @param elapsed the time elapsed in seconds since the last frame
	 */
	public function update(elapsed:Float):Void {}

	private var _matrix:Matrix4;

}

/**
 * A Graphic that can contain multiple Graphics of one or various types.
 * Useful for drawing sprites with multiple parts, etc...
 */
class GraphicList extends Graphic
{

	/**
	 * Creates a new list of Graphic objects
	 * @param graphics An optional list of Graphic objects to add to the list
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

	/**
	 * Renders all of the Graphic objects in the list
	 */
	override public function draw(offset:Vector3):Void
	{
		for (i in 0..._children.length)
		{
			_children[i].draw(offset);
		}
	}

	/**
	 * Updates all of the Graphic objects in the list
	 */
	override public function update(elapsed:Float):Void
	{
		for (i in 0..._children.length)
		{
			_children[i].update(elapsed);
		}
	}

	private var _children:Array<Graphic>;

}
