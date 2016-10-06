package com.haxepunk;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;

class Cursor extends Entity
{
	/**
	 * Constructor.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	public function new(graphic:Graphic = null, mask:Mask = null)
	{
		super(0, 0, graphic, mask);
	}

	/**
	 * Updates the entitiy coordinates to match the cursor.
	 */
	public override function update()
	{
		super.update();
		x = scene.mouseX;
		y = scene.mouseY;
	}
}