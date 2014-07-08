package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;
import haxepunk.scene.Camera;

interface Graphic
{

	public function update(elapsed:Float):Void;
	public function draw(camera:Camera, offset:Vector3):Void;

}

/**
 * A Graphic that can contain multiple Graphics of one or various types.
 * Useful for drawing sprites with multiple different parts, etc.
 */
class GraphicList implements Graphic
{

	/**
	 * Constructor.
	 * @param	...graphics		Graphic objects to add to the list.
	 */
	public function new(?graphics:Array<Graphic>)
	{
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
	public function draw(camera:Camera, offset:Vector3):Void
	{
		for (graphic in _children)
		{
			graphic.draw(camera, offset);
		}
	}

	public function update(elapsed:Float):Void
	{
		for (graphic in _children)
		{
			graphic.update(elapsed);
		}
	}

	private var _children:Array<Graphic>;
}
