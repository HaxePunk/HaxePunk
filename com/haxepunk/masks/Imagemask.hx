package com.haxepunk.masks;

import com.haxepunk.Mask;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;

/**
 * A bitmap mask used for pixel-perfect collision.
 *
 * Example usage:
 *
 * class Object extends Entity {
 *   public function new() {
 *     super();
 *     var sprite = new Image("myimage.png", 100, 100);
 *     graphic = sprite;
 *     mask = new Imagemask(sprite);
 *     mask.assignTo(this);
 *   }
 * }
 *
 * Remember to call "mask.update()" when you update the image.
 *
 * If you are using HARDWARE mode, Imagemask will still work, but only if your
 * Image source is created with a BitmapData. AtlasData is not currently
 * supported.
 *
 */
class Imagemask extends Pixelmask
{
	/**
	* Constructor.
	* @param source		The Image to use as a mask.
	*/
	public function new(source:Image)
	{
		super(new BitmapData(1, 1));

		_bounds = new Rectangle();
		this.source = source;
	}

	/** The Image to use as source for the mask. */
	public var source(get, set):Image;
	private function get_source():Image { return _source; }
	private function set_source(value:Image):Image 
	{
		if (value != _source) 
		{
			_source = value;
			update();
		}
		return _source;
	}

	/**
	* Updates the mask.
	*/
	@:access(com.haxepunk.graphics.Image)
	override public function update()
	{
		getBounds();	// recalc bounds

		_x = Math.floor(_bounds.x);
		_y = Math.floor(_bounds.y);
		_width = Math.ceil(_bounds.width);
		_height = Math.ceil(_bounds.height);

		if (_data == null || (_data.width != _width || _data.height != _height)) 
		{
			_data = new BitmapData(_width, _height, true, 0);
		} 
		else 
		{
			data.fillRect(data.rect, 0);
		}
		
		_point.x = -_x;
		_point.y = -_y;
		
		// draw source Image to its buffer (even if in RenderMode.HARDWARE)
		if (!_source.blit) 
		{
			_source.blit = true;
			_source.drawBuffer();
			_source.render(_data, _point, HXP.zero);
			_source.blit = false;
		} 
		else 
		{
			_source.render(_data, _point, HXP.zero);
		}

		super.update();
	}

	/**
	* Calculates the bounding box of the source Image, taking into account the Image transform.
	* @return  the bounding box in local coordinates.
	*/
	public function getBounds():Rectangle 
	{
		var sx = _source.scale * _source.scaleX;
		var sy = _source.scale * _source.scaleY;

		_matrix.a = sx;
		_matrix.b = 0;
		_matrix.c = 0;
		_matrix.d = sy;
		_matrix.tx = -_source.originX * sx;
		_matrix.ty = -_source.originY * sy;
		_matrix.rotate(_source.angle * HXP.RAD);

		_point.x = 0;
		_point.y = 0;
		
		// TODO: optimize this
		var p1 = _matrix.transformPoint(_point);
		_point.x = _source.width;
		_point.y = _source.height;
		var p2 = _matrix.transformPoint(_point);
		_point.x = 0;
		_point.y = _source.height;
		var p3 = _matrix.transformPoint(_point);
		_point.x = _source.width;
		_point.y = 0;
		var p4 = _matrix.transformPoint(_point);

		_bounds.x = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
		_bounds.y = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
		_bounds.width  = Math.max(Math.max(p1.x - _bounds.x, p2.x - _bounds.x), Math.max(p3.x - _bounds.x, p4.x - _bounds.x));
		_bounds.height = Math.max(Math.max(p1.y - _bounds.y, p2.y - _bounds.y), Math.max(p3.y - _bounds.y, p4.y - _bounds.y));

		return _bounds;
	}

	/**
	 * Imagemask information.
	 */
	private var _source:Image;
	private var _bounds:Rectangle;
}
