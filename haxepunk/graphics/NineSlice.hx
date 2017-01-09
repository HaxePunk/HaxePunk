package haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.RenderMode;
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
	public var clipRect:Rectangle;

	public var smooth(default, set):Bool;
	inline function set_smooth(v:Bool)
	{
		return topL.smooth =
			topC.smooth =
			topR.smooth =
			medL.smooth =
			medC.smooth =
			medR.smooth =
			botL.smooth =
			botC.smooth =
			botR.smooth =
			v;
	}

	public var color(default, set):Color;
	inline function set_color(v:Color):Color
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
			v;
	}

	public var alpha(default, set):Float;
	inline function set_alpha(v:Float):Float
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
			v;
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

		blit = HXP.renderMode == RenderMode.BUFFER;
	}

	inline function getSegment(source:ImageType, x:Int, y:Int, width:Int, height:Int):Image
	{
		_rect.setTo(x, y, width, height);
		var segment = new Image(source, _rect);
		segment.originX = segment.originY = 0;
		return segment;
	}

	/**
	 * Updates the Image. Make sure to set graphic = output image afterwards.
	 * @param	width	New width
	 * @param	height	New height
	 * @return
	 */
	function renderSegments(renderFunc:Image -> Void)
	{
		var leftWidth:Float = Std.int(_sliceRect.left / HXP.screen.fullScaleX),
			rightWidth:Float = Std.int((source.width - _sliceRect.width) / HXP.screen.fullScaleX),
			centerWidth:Float = Std.int(width - leftWidth - rightWidth);
		var topHeight:Float = Std.int(_sliceRect.top / HXP.screen.fullScaleY),
			bottomHeight:Float = Std.int((source.height - _sliceRect.height) / HXP.screen.fullScaleY),
			centerHeight:Float = Std.int(height - topHeight - bottomHeight);

		var leftX = 0, centerX = leftWidth, rightX = leftWidth + centerWidth,
			topY = 0, centerY = topHeight, bottomY = topHeight + centerHeight;

		drawSegment(renderFunc, topL, leftX, topY, leftWidth, topHeight);
		drawSegment(renderFunc, topC, centerX, topY, centerWidth, topHeight);
		drawSegment(renderFunc, topR, rightX, topY, rightWidth, topHeight);
		drawSegment(renderFunc, medL, leftX, centerY, leftWidth, centerHeight);
		drawSegment(renderFunc, medC, centerX, centerY, centerWidth, centerHeight);
		drawSegment(renderFunc, medR, rightX, centerY, rightWidth, centerHeight);
		drawSegment(renderFunc, botL, leftX, bottomY, leftWidth, bottomHeight);
		drawSegment(renderFunc, botC, centerX, bottomY, centerWidth, bottomHeight);
		drawSegment(renderFunc, botR, rightX, bottomY, rightWidth, bottomHeight);
	}

	inline function drawSegment(renderFunc:Image -> Void, segment:Image, x:Float, y:Float, width:Float, height:Float)
	{
		if (segment != null && segment.visible)
		{
			segment.x = this.x + x;
			segment.y = this.y + y;
			segment.scaleX = width / segment.width;
			segment.scaleY = height / segment.height;
			renderFunc(segment);
		}
	}

	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		renderSegments(function(segment:Image) segment.render(target, point, camera));
	}

	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		renderSegments(function(segment:Image) segment.renderAtlas(layer, point, camera));
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
	var _rect:Rectangle = new Rectangle();
	var _matrix:Matrix = new Matrix();
}
