package com.haxepunk.masks;

import com.haxepunk.Mask;
import flash.display.BitmapData;
import flash.geom.Point;
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
    var r = _source.getBounds();

    _x = Math.floor(r.x);
    _y = Math.floor(r.y);
    _width = Math.ceil(r.width);
    _height = Math.ceil(r.height);

    _data = new BitmapData(_width, _height, true, 0x00000000);
    _source.render(_data, new Point(-_x, -_y), new Point(0, 0));

    super.update();
  }

  /**
   * Current Image mask.
   */
  private var _source:Image;
}
