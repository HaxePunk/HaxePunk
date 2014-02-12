package com.haxepunk;

import com.haxepunk.Entity;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import com.haxepunk.masks.Masklist;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

typedef MaskCallback = Dynamic -> Bool;

/**
 * Base class for Entity collision masks.
 */
class Mask
{
	/**
	 * The parent Entity of this mask.
	 */
	public var parent:Entity;

	/**
	 * The parent Masklist of the mask.
	 */
	public var list:Masklist;

	/**
	 * Constructor.
	 */
	public function new()
	{
		_class = Type.getClassName(Type.getClass(this));
		_check = new Map<String,MaskCallback>();
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Masklist), collideMasklist);
	}

	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		if (parent == null)
		{
			throw "Mask must be attached to a parent Entity";
		}

		var cbFunc:MaskCallback = _check.get(mask._class);
		if (cbFunc != null) return cbFunc(mask);

		cbFunc = mask._check.get(_class);
		if (cbFunc != null) return cbFunc(this);

		return false;
	}

	/** @private Collide against an Entity. */
	private function collideMask(other:Mask):Bool
	{
		return parent.x - parent.originX + parent.width > other.parent.x - other.parent.originX
			&& parent.y - parent.originY + parent.height > other.parent.y - other.parent.originY
			&& parent.x - parent.originX < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y - parent.originY < other.parent.y - other.parent.originY + other.parent.height;
	}

	private function collideMasklist(other:Masklist):Bool
	{
		return other.collide(this);
	}

	/** @private Assigns the mask to the parent. */
	public function assignTo(parent:Entity)
	{
		this.parent = parent;
		if (parent != null) update();
	}

	/**
	 * Override this
	 */
	public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{

	}

	/** Updates the parent's bounds for this mask. */
	public function update()
	{

	}

	public function project(axis:Vector, projection:Projection):Void
	{
		var cur:Float,
			max:Float = -9999999999.0,
			min:Float = 9999999999.0;

		cur = -parent.originX * axis.x - parent.originY * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (-parent.originX + parent.width) * axis.x - parent.originY * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = -parent.originX * axis.x + (-parent.originY + parent.height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (-parent.originX + parent.width) * axis.x + (-parent.originY + parent.height)* axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		projection.min = min;
		projection.max = max;
	}

	/**
	 * Replacement for BitmapData.hitTest() that is not yet available in non-flash targets. TODO: Thorough testing and optimizations.
	 * 
	 * @param	firstObject				The first BitmapData object to check against.
	 * @param	firstPoint				A position of the upper-left corner of the BitmapData image in an arbitrary coordinate space. The same coordinate space is used in defining the secondBitmapPoint parameter.
	 * @param	firstAlphaThreshold		The smallest alpha channel value that is considered opaque for this hit test.
	 * @param	secondObject			A Rectangle, Point, Bitmap, or BitmapData object.
	 * @param	secondPoint				A point that defines a pixel location in the second BitmapData object. Use this parameter only when the value of secondObject is a BitmapData object.
	 * @param	secondAlphaThreshold	The smallest alpha channel value that is considered opaque in the second BitmapData object. Use this parameter only when the value of secondObject is a BitmapData object and both BitmapData objects are transparent.
	 * 
	 * @return  A value of true if a hit occurs; false otherwise.
	 */
	public static function hitTest(firstObject:BitmapData, firstPoint:Point, firstAlphaThreshold:Int, secondObject:Dynamic, secondPoint:Point = null, secondAlphaThreshold:Int = 1):Bool 
	{
		if (firstPoint == null) {
			throw "firstPoint cannot be null.";
		}
		
		var rectA:Rectangle = firstObject.rect.clone();
		var firstBMD:BitmapData = firstObject;
		var rectB:Rectangle = null;
		var secondBMD:BitmapData = null;
		
		if (Std.is(secondObject, Point)) 
		{
			var p:Point = cast secondObject;
			rectB = new Rectangle(p.x, p.y, 1, 1);
			var pixel:Int = firstBMD.getPixel32(Std.int(p.x), Std.int(p.y));
			return (pixel >>> 24) >= firstAlphaThreshold;
		} 
		else if (Std.is(secondObject, Rectangle)) 
		{
			rectB = (cast secondObject).clone();
		} 
		else if (Std.is(secondObject, BitmapData)) 
		{
			secondBMD = cast secondObject;
			rectB = secondBMD.rect.clone();
		} 
		else throw "Invalid secondObject. Must be Point, Rectangle or BitmapData.";
		
		rectA.x = firstPoint.x;
		rectA.y = firstPoint.y;
		if (secondBMD != null && secondPoint != null) 
		{
			rectB.x = secondPoint.x;
			rectB.y = secondPoint.y;
		} 
		else 
		{
			secondPoint = firstPoint;
		}
		
		var intersectRect:Rectangle = rectA.intersection(rectB);
		var boundsOverlap:Bool = (intersectRect.width >= 1 && intersectRect.height >= 1);
		var hit:Bool = false;

		if (boundsOverlap) 
		{
			var w:Int = Std.int(intersectRect.width);
			var h:Int = Std.int(intersectRect.height);
			
			// firstObject
			var xOffset:Float = intersectRect.x > rectA.x ? intersectRect.x - rectA.x : rectA.x - intersectRect.x;
			var yOffset:Float = intersectRect.y > rectA.y ? intersectRect.y - rectA.y : rectA.y - intersectRect.y;
			rectA.x += xOffset - firstPoint.x;
			rectA.y += yOffset - firstPoint.y;
			rectA.width = w;
			rectA.height = h;

			// secondObject
			xOffset = intersectRect.x > rectB.x ? intersectRect.x - rectB.x : rectB.x - intersectRect.x;
			yOffset = intersectRect.y > rectB.y ? intersectRect.y - rectB.y : rectB.y - intersectRect.y;
			rectB.x += xOffset - secondPoint.x;
			rectB.y += yOffset - secondPoint.y;
			rectB.width = w;
			rectB.height = h;
			
			var pixelsA:ByteArray = firstBMD.getPixels(rectA);
			var pixelsB:ByteArray = null;
			if (secondBMD != null) 
			{
				pixelsB = secondBMD.getPixels(rectB);
				pixelsB.position = 0;
			}
			pixelsA.position = 0;
			
			// analyze overlapping area of BitmapDatas to check for a collision (alpha values >= alpha threshold)
			var alphaA:Int = 0;
			var alphaB:Int = 0;
			var overlapPixels:Int = w * h;
			var alphaIdx:Int = 0;
			
			// check even pixels first
			for (i in 0...Math.ceil(overlapPixels / 2)) 
			{
				alphaIdx = i << 3;
				alphaA = pixelsA[alphaIdx];
				alphaB = secondBMD != null ? pixelsB[alphaIdx] : 255;
				if (alphaA >= firstAlphaThreshold && alphaB >= secondAlphaThreshold) 
				{
					hit = true;
					break; 
				}
			}
			
			if (!hit) 
			{
				// check odd pixels
				for (i in 0...overlapPixels >> 1) 
				{
					alphaIdx = (i << 3) + 4;
					alphaA = pixelsA[alphaIdx];
					alphaB = secondBMD != null ? pixelsB[alphaIdx] : 255;
					if (alphaA >= firstAlphaThreshold && alphaB >= secondAlphaThreshold) 
					{
						hit = true;
						break; 
					}
				}
			}
			
			pixelsA = null;
			pixelsB = null;
		}
		
		return hit;
	}
	
	// Mask information.
	private var _class:String;
	private var _check:Map<String,MaskCallback>;
}
