package com.haxepunk.debug;

import com.haxepunk.utils.Input;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.ds.IntMap;

import openfl.Assets;

class VisibleLabel extends Sprite
{

	public function new(textFormat:TextFormat)
	{
		super();

		active = new Bitmap(Assets.getBitmapData("gfx/debug/console_visible.png"));
		inactive = new Bitmap(Assets.getBitmapData("gfx/debug/console_hidden.png"));

		label = new TextField();
		label.defaultTextFormat = textFormat;
		label.selectable = false;
		label.width = 150;
		label.height = 14;

		label.x = 24;
		label.y = 2;
#if flash
		label.embedFonts = true;
#end

		this.x = 6;
		this.display = true;

		addChild(active);
		addChild(label);

		addEventListener("click", onClick, true);
	}

	public var display(default, set):Bool;
	private function set_display(value:Bool):Bool
	{
		if (value != display)
		{
			display = value;
			if (value)
			{
				removeChild(inactive);
				addChild(active);
			}
			else
			{
				removeChild(active);
				addChild(inactive);
			}
		}
		return value;
	}

	private function onClick(e:MouseEvent)
	{
		display = !display;
	}

	private var active:Bitmap;
	private var inactive:Bitmap;
	private var label:TextField;

}

class MaskLabel extends VisibleLabel
{
	public function new(textFormat:TextFormat)
	{
		super(textFormat);
		label.text = "Masks";
	}

	private override function onClick(e:MouseEvent)
	{
		super.onClick(e);
		HXP.console.debugDraw = display;
		HXP.console.update();
	}
}

class LayerLabel extends VisibleLabel
{

	public var layer(default, null):Int;

	public function new(layer:Int, textFormat:TextFormat)
	{
		super(textFormat);

		this.layer = layer;
		this.count = 0;
	}

	public var count(never, set):Int;
	private function set_count(value:Int):Int
	{
		label.text = 'Layer $layer [$value]';
		return value;
	}

	private override function onClick(e:MouseEvent)
	{
		super.onClick(e);
		HXP.scene.showLayer(layer, display);
		HXP.engine.render();
		HXP.console.debugDraw = HXP.console.debugDraw; // redraw masks
	}

}

class LayerList extends Sprite
{
	public function new(width:Int=250, height:Int=400)
	{
		super();

		var mask = new Sprite();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(0, 0, width, height);
		mask.graphics.endFill();
		addChild(mask);
		this.mask = mask;

		graphics.beginFill(0, .15);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();

		var font = Assets.getFont("font/04B_03__.ttf");
		if (font == null)
		{
			font = Assets.getFont(HXP.defaultFont);
		}
		_textFormat = new TextFormat(font.fontName, 16, 0xFFFFFF);

		_labels = new IntMap<LayerLabel>();
	}

	private function layerSort(a:Int, b:Int):Int
	{
		return a - b;
	}

	public function set(list:IntMap<Int>)
	{
		// remove added children
		for (key in _labels.keys())
		{
			removeChild(_labels.get(key));
			_labels.remove(key);
		}

		// filter and sort layers
		var keys = new Array<Int>();
		for (key in list.keys())
		{
			if (list.get(key) > 0)
				keys.push(key);
		}
		keys.sort(layerSort);

		var i = 0, scene = HXP.scene;
		for (layer in keys)
		{
			var label:LayerLabel;
			if (_labels.exists(layer))
			{
				label = _labels.get(layer);
			}
			else
			{
				label = new LayerLabel(layer, _textFormat);
				_labels.set(layer, label);
			}
			label.count = list.get(layer);
			label.display = scene.layerVisible(layer);
			label.y = i++ * 20 + 5;
			addChild(label);
		}

		// add and move mask label
		if (_maskLabel == null)
		{
			_maskLabel = new MaskLabel(_textFormat);
			addChild(_maskLabel);
		}
		_maskLabel.y = i++ * 20 + 5;
	}

	private var _labels:IntMap<LayerLabel>;
	private var _maskLabel:MaskLabel;
	private var _textFormat:TextFormat;
}
