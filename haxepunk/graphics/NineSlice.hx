package haxepunk.graphics;

import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.Image;
import haxepunk.utils.Color;

/**
 * Automatic scaling 9-slice graphic.
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
	 * @param	leftWidth Distance from left side of the source image used for 9-Slicking the image
	 * @param	rightWidth Distance from right side of the source image used for 9-Slicking the image
	 * @param	topHeight Distance from top side of the source image used for 9-Slicking the image
	 * @param	bottomHeight Distance from bottom side of the source image used for 9-Slicking the image
	 */
	public function new(source:ImageType, leftWidth:Int = 0, rightWidth:Int = 0, topHeight:Int = 0, bottomHeight:Int = 0)
	{
		super();
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

		width = w;
		height = h;
	}

	inline function getSegment(source:ImageType, x:Int, y:Int, width:Int, height:Int):Image
	{
		var segment = new Image(source, new Rectangle(x, y, width, height));
		segment.originX = segment.originY = 0;
		return segment;
	}

	override public function render(layer:Int, point:Point, camera:Camera)
	{
		var leftWidth:Float, rightWidth:Float, topHeight:Float, bottomHeight:Float;
		if (scaleBorder)
		{
			leftWidth = Std.int(_sliceRect.left * HXP.screen.fullScaleX) / HXP.screen.fullScaleX;
			rightWidth = Std.int((source.width - _sliceRect.width) * HXP.screen.fullScaleX) / HXP.screen.fullScaleX;
			topHeight = Std.int(_sliceRect.top * HXP.screen.fullScaleY) / HXP.screen.fullScaleY;
			bottomHeight = Std.int((source.height - _sliceRect.height) * HXP.screen.fullScaleY) / HXP.screen.fullScaleY;
		}
		else
		{
			leftWidth = Std.int(_sliceRect.left) / HXP.screen.fullScaleX;
			rightWidth = Std.int(source.width - _sliceRect.width) / HXP.screen.fullScaleX;
			topHeight = Std.int(_sliceRect.top) / HXP.screen.fullScaleY;
			bottomHeight = Std.int(source.height - _sliceRect.height) / HXP.screen.fullScaleY;
		}
		var centerWidth:Float = Std.int(width - leftWidth - rightWidth),
			centerHeight:Float = Std.int(height - topHeight - bottomHeight);

		var leftX = 0, centerX = leftWidth, rightX = leftWidth + centerWidth,
			topY = 0, centerY = topHeight, bottomY = topHeight + centerHeight;

		inline function drawSegment(segment:Image, x:Float, y:Float, width:Float, height:Float)
		{
			if (segment != null && segment.visible)
			{
				segment.x = this.x + x;
				segment.y = this.y + y;
				segment.scaleX = width / segment.width;
				segment.scaleY = height / segment.height;
				if (clipRect != null)
				{
					_clipRect.setTo(clipRect.x - x, clipRect.y - y, clipRect.width, clipRect.height);
					segment.clipRect = _clipRect;
				}
				else segment.clipRect = null;
				segment.smooth = smooth;
				segment.render(layer, point, camera);
			}
		}

		drawSegment(topL, leftX, topY, leftWidth, topHeight);
		drawSegment(topC, centerX, topY, centerWidth, topHeight);
		drawSegment(topR, rightX, topY, rightWidth, topHeight);
		drawSegment(medL, leftX, centerY, leftWidth, centerHeight);
		drawSegment(medC, centerX, centerY, centerWidth, centerHeight);
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
