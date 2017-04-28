package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;
import haxepunk.utils.MathUtil;

class FPSCounter extends Sprite
{

	var big:Bool = false;

	public var selectable(get, set):Bool;
	function get_selectable():Bool return _fpsCounter.selectable;
	function set_selectable(value:Bool):Bool
	{
		_fpsCounter.selectable = value;
		_infoLeft.selectable = value;
		_infoRight.selectable = value;
#if !js
		_memReadText.selectable = value;
#end
		return value;
	}

	public var offset(get, never):Float;
	function get_offset():Float
	{
#if js
		return _fpsInfo.visible ? _fpsCounter.width : _fpsInfo.x + _fpsInfo.width + 40;
#else
		return _memReadText.x + _memReadText.width + 40;
#end
	}

	public function new()
	{
		super();
		this.addChild(_fpsCounter);
		_fpsCounter.defaultTextFormat = Format.format(16);
		_fpsCounter.width = 70;
		_fpsCounter.height = 20;
		_fpsCounter.x = 2;
		_fpsCounter.y = 1;

		// The frame timing text.
		addChild(_fpsInfo);
		_fpsInfo.addChild(_infoLeft);
		_fpsInfo.addChild(_infoRight);
		_fpsInfo.x = 75;

		_infoLeft.defaultTextFormat = Format.format(8, 0xAAAAAA);
		_infoRight.defaultTextFormat = Format.format(8, 0xAAAAAA);
		_infoLeft.width = _infoRight.width = 60;
		_infoLeft.height = _infoRight.height = 20;
		_infoRight.x = 60;
		_fpsInfo.width = _infoLeft.width + _infoRight.width;

		// The memory usage
#if !js
		this.addChild(_memReadText);
		_memReadText.defaultTextFormat = Format.format(16);
		_memReadText.embedFonts = true;
		_memReadText.width = 110;
		_memReadText.height = 20;
		_memReadText.y = 1;
#end
	}

	/** @private Update the FPS/frame timing panel text. */
	public function update(big:Bool)
	{
		_fpsCounter.text = "FPS: " + Std.int(HXP.frameRate);

		_fpsInfo.visible = big;
		if (big)
		{
			_infoLeft.text =
				'Update: ${HXP._updateTime}ms\n' +
				'Render: ${HXP._renderTime}ms';
			_infoRight.text =
				'System: ${HXP._systemTime}ms\n' +
				'Game: ${HXP._gameTime}ms';
		}

#if !js
		_memReadText.text =
			(big ? "Mem: " : "") + MathUtil.roundDecimal(flash.system.System.totalMemory / 1024 / 1024, 2) + "MB";
		_memReadText.width = _memReadText.textWidth;
		_memReadText.x = (big) ? _fpsInfo.x + _infoLeft.width + _infoRight.width + 5 : _fpsInfo.x + 9;
#end
		this.graphics.clear();
		this.graphics.beginFill(0, .75);
		this.graphics.drawRoundRect(-20, -20, offset, 40, 40, 40);
	}

	var _fpsInfo:Sprite = new Sprite();
	var _fpsCounter:TextField = new TextField();
	var _infoLeft:TextField = new TextField();
	var _infoRight:TextField = new TextField();
#if !js
	var _memReadText:TextField = new TextField();
#end
}
