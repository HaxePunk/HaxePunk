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
   * @param source    The image to use as a mask.
   * @param x     X offset of the mask.
   * @param y     Y offset of the mask.
   */
  public function new(source:Image)
  {
    super(new BitmapData(1, 1));
    _source = source;
    update();
    _check.set(Type.getClassName(Imagemask), collidePixelmask);
  }

  /**
   * Update Source image. Calls update().
   * @param newsource Update source image.
   */
  public function setSource(newsource:Image) {
    _source = newsource;
    update();
  }

/**
   * Updates mask.
   */
  override public function update()
  {
    var r = getBounds();

    _x = Math.floor(r.x);
    _y = Math.floor(r.y);
    _width = Math.ceil(r.width);
    _height = Math.ceil(r.height);

    _data = new BitmapData(_width, _height, true, 0x00000000);
    _source.render(_data, new Point(-_x, -_y), new Point(0, 0));

    super.update();
  }

  /**
   * Calculates the bound box of the source Image, taking account the Image
   * transformation.
   * @return  the bound box in local coordinates.
   */
  public function getBounds():flash.geom.Rectangle {
    var sx = _source.scale * _source.scaleX;
    var sy = _source.scale * _source.scaleY;

    var matrix = new Matrix(sx, 0, 0, sy,
      -_source.originX * sx,
      -_source.originY * sy);
    matrix.rotate(_source.angle * HXP.RAD);

    var point = new Point(0, 0);
    var p1 = matrix.transformPoint(point);
    point.x = _source.width;
    point.y = _source.height;
    var p2 = matrix.transformPoint(point);
    point.x = 0;
    point.y = _source.height;
    var p3 = matrix.transformPoint(point);
    point.x = _source.width;
    point.y = 0;
    var p4 = matrix.transformPoint(point);

    var r = new Rectangle(0, 0, 0, 0);
    r.x = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
    r.y = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
    r.width  = Math.max(Math.max(p1.x - r.x, p2.x - r.x), Math.max(p3.x - r.x, p4.x - r.x));
    r.height = Math.max(Math.max(p1.y - r.y, p2.y - r.y), Math.max(p3.y - r.y, p4.y - r.y));

    return r;
  }

  /**
   * Current Image mask.
   */
  private var _source:Image;
}
