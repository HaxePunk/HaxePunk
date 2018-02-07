package haxepunk.graphics;

import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.Image;
import haxepunk.utils.Color;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;

/**
 * A NineSlice is an automatically scaling graphic cut into nine segments
 * (upper/middle/lower and left/middle/right.) NineSlice is useful when a
 * graphic has borders that should remain a constan size as the graphic scales
 * (such as a UI button or panel.)
 */
class NineSlice extends Graphic
{
	public var width:Float;
	public var height:Float;

	/**
	 * If false, the borders will always be drawn at their native resolution,
	 * regardless of screen scale.
	 */
	public var scaleBorder:Bool = false;

	/**
	 * Set this to false to skip the center, drawing only the border segments.
	 */
	public var drawCenter:Bool = true;

	override function set_color(v:Color):Color
	{
		return topL.color =
			topC.color =
			topR.color =
			medL.color =
			medC.color =
			medR.color =
			botL.color =
			botC.color =
			botR.color =
			color = v;
	}

	override function set_alpha(v:Float):Float
	{
		return topL.alpha =
			topC.alpha =
			topR.alpha =
			medL.alpha =
			medC.alpha =
			medR.alpha =
			botL.alpha =
			botC.alpha =
			botR.alpha =
			alpha = v;
	}

	var source:ImageType;

	/**
	 * Constructor.
	 * @param	source Source image
	 * @param	leftWidth Distance from left side of the source image used for 9-slicing the image
	 * @param	rightWidth Distance from right side of the source image used for 9-slicing the image
	 * @param	topHeight Distance from top side of the source image used for 9-slicing the image
	 * @param	bottomHeight Distance from bottom side of the source image used for 9-slicing the image
	 */
	public function new(source:ImageType, leftWidth:Int = 0, rightWidth:Int = 0, topHeight:Int = 0, bottomHeight:Int = 0)
	{
		this.source = source;

		var w = source.width,
			h = source.height;

		topL = getSegment(source, 0, 0, leftWidth, topHeight);
		topC = getSegment(source, leftWidth, 0, w - leftWidth - rightWidth, topHeight);
		topR = getSegment(source, w - rightWidth, 0, rightWidth, topHeight);
		medL = getSegment(source, 0, topHeight, leftWidth, h - topHeight - bottomHeight);
		medC = getSegment(source, leftWidth, topHeight, w - leftWidth - rightWidth, h - topHeight - bottomHeight);
		medR = getSegment(source, w - rightWidth, topHeight, rightWidth, h - topHeight - bottomHeight);
		botL = getSegment(source, 0, h - bottomHeight, leftWidth, bottomHeight);
		botC = getSegment(source, leftWidth, h - bottomHeight, w - leftWidth - rightWidth, bottomHeight);
		botR = getSegment(source, w - rightWidth, h - bottomHeight, rightWidth, bottomHeight);
		_sliceRect.setTo(leftWidth, topHeight, w - rightWidth, h - bottomHeight);

		super();

		width = w;
		height = h;
		pixelSnapping = false;
	}

	inline function getSegment(source:ImageType, x:Int, y:Int, width:Int, height:Int):Image
	{
		var segment = new Image(source, new Rectangle(x, y, width, height));
		segment.originX = segment.originY = 0;
		return segment;
	}

	override public function render(point:Vector2, camera:Camera)
	{
		var leftWidth:Float, rightWidth:Float, topHeight:Float, bottomHeight:Float;
		if (scaleBorder)
		{
			leftWidth = floorX(camera, _sliceRect.left);
			rightWidth = floorX(camera, source.width - _sliceRect.width);
			topHeight = floorY(camera, _sliceRect.top);
			bottomHeight = floorY(camera, source.height - _sliceRect.height);
		}
		else
		{
			leftWidth = floorX(camera, _sliceRect.left) / camera.screenScaleX;
			rightWidth = floorX(camera, source.width - _sliceRect.width) / camera.screenScaleX;
			topHeight = floorY(camera, _sliceRect.top) / camera.screenScaleY;
			bottomHeight = floorY(camera, source.height - _sliceRect.height) / camera.screenScaleY;
		}
		var centerWidth:Float = floorX(camera, width) - leftWidth - rightWidth,
			centerHeight:Float = floorY(camera, height) - topHeight - bottomHeight;

		var leftX = 0, centerX = leftWidth, rightX = leftWidth + centerWidth,
			topY = 0, centerY = topHeight, bottomY = topHeight + centerHeight;

		inline function drawSegment(segment:Image, x:Float, y:Float, width:Float, height:Float)
		{
			if (segment != null && segment.visible)
			{
				segment.x = floorX(camera, this.x) + x;
				segment.y = floorY(camera, this.y) + y;
				segment.scaleX = (floorX(camera, x + width) - floorX(camera, x)) / segment.width;
				segment.scaleY = (floorY(camera, y + height) - floorY(camera, y)) / segment.height;
				if (clipRect != null)
				{
					_clipRect.setTo(clipRect.x - x, clipRect.y - y, clipRect.width, clipRect.height);
					segment.clipRect = _clipRect;
				}
				else segment.clipRect = null;
				segment.shader = shader;
				segment.smooth = smooth;
				segment.render(point, camera);
			}
		}

		drawSegment(topL, leftX, topY, leftWidth, topHeight);
		drawSegment(topC, centerX, topY, centerWidth, topHeight);
		drawSegment(topR, rightX, topY, rightWidth, topHeight);
		drawSegment(medL, leftX, centerY, leftWidth, centerHeight);
		if (drawCenter) drawSegment(medC, centerX, centerY, centerWidth, centerHeight);
		drawSegment(medR, rightX, centerY, rightWidth, centerHeight);
		drawSegment(botL, leftX, bottomY, leftWidth, bottomHeight);
		drawSegment(botC, centerX, bottomY, centerWidth, bottomHeight);
		drawSegment(botR, rightX, bottomY, rightWidth, bottomHeight);
	}

	var topL:Image;
	var topC:Image;
	var topR:Image;
	var medL:Image;
	var medC:Image;
	var medR:Image;
	var botL:Image;
	var botC:Image;
	var botR:Image;

	var _sliceRect:Rectangle = new Rectangle();
	var _clipRect:Rectangle = new Rectangle();
}
