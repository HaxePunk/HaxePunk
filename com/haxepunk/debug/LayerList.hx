package com.haxepunk.debug;

import com.haxepunk.utils.Input;
import com.haxepunk.graphics.atlas.Atlas;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

#if nme
import nme.Assets;
#else
import openfl.Assets;
#end

class Label extends TextField
{
	public var layer(default, set_layer):Int;
	private function set_layer(value:Int):Int
	{
		if (layer != value)
		{
			layer = value;
			text = "Layer: " + value;
		}
		return value;
	}
}

class LayerList extends Sprite
{
	public function new(width:Int=250, height:Int=400)
	{
		super();
		_velocity = 0;

		var mask = new Sprite();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(0, 0, width, height);
		mask.graphics.endFill();
		addChild(mask);
		this.mask = mask;

		addEventListener('click', onClick, true);

		graphics.beginFill(0, .15);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();

		var font = Assets.getFont("font/04B_03__.ttf");
		if (font == null)
		{
			font = Assets.getFont(HXP.defaultFont);
		}
		_textFormat = new TextFormat(font.fontName, 16, 0xFFFFFF);

		_removeList = new Array<DisplayObject>();
	}

	public function set(list:Array<Int>)
	{
		var i = 0, child:DisplayObject;

		// try to reuse previous children
		if (numChildren > 0)
		{
			for (ci in 0...numChildren)
			{
				child = getChildAt(ci);
				if (Std.is(child, Label))
				{
					var label = cast(child, Label);
					if (i < list.length)
					{
						label.layer = list[i];
						i += 1;
					}
					else
					{
						_removeList.push(child);
					}
				}
			}

			for (child in _removeList)
			{
				removeChild(child);
				_removeList.remove(child);
			}
		}

		for (i in i...list.length)
		{
			var tf = new Label();
			addChild(tf);
			tf.defaultTextFormat = _textFormat;
			tf.selectable = false;
			tf.width = width;
			tf.height = 20;
			tf.x = 6;
			tf.y = i * 25 + 5;
#if flash
			tf.embedFonts = true;
#end
			tf.layer = list[i];
		}
	}

	private function onClick(e:MouseEvent)
	{
		var label = cast(e.target, Label);
		var visible = Atlas.toggleLayerVisibility(label.layer);
		if (visible) {
			label.alpha = 1;
		} else {
			label.alpha = 0.4;
		}
	}

	public function update()
	{
		_velocity += Input.mouseWheelDelta;

		// there is probably a better way to do this
		// this.y += _velocity;
		// mask.y -= _velocity;

		if (_velocity < 0)
		{
			_velocity += DRAG;
			if (_velocity > 0)
			{
				_velocity = 0;
			}
		}
		else if (_velocity > 0)
		{
			_velocity -= DRAG;
			if (_velocity < 0)
			{
				_velocity = 0;
			}
		}
	}

	private var _removeList:Array<DisplayObject>;
	private var _velocity:Float;
	private var _textFormat:TextFormat;
	private static inline var DRAG:Float = 0.8;
}
