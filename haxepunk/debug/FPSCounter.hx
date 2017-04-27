package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;
import haxepunk.utils.MathUtil;

class FPSCounter extends Sprite
{

	var big:Bool = false;

	public var selectable(get, set):Bool;
	function get_selectable():Bool return _fpsReadText.selectable;
	function set_selectable(value:Bool):Bool
	{
		_fpsReadText.selectable = value;
		_fpsInfoText0.selectable = value;
		_fpsInfoText1.selectable = value;
		_memReadText.selectable = value;
		return value;
	}

	public var offset(get, never):Float;
	function get_offset():Float return _fpsInfo.x + _fpsInfoText0.width + _fpsInfoText1.width;

	public function new(big:Bool)
	{
		super();
		this.big = big;
		this.addChild(_fpsReadText);
		_fpsReadText.defaultTextFormat = Format.format(16);
		_fpsReadText.width = 70;
		_fpsReadText.height = 20;
		_fpsReadText.x = 2;
		_fpsReadText.y = 1;

		// The frame timing text.
		if (big) this.addChild(_fpsInfo);
		_fpsInfo.addChild(_fpsInfoText0);
		_fpsInfo.addChild(_fpsInfoText1);
		_fpsInfoText0.defaultTextFormat = Format.format(8, 0xAAAAAA);
		_fpsInfoText1.defaultTextFormat = Format.format(8, 0xAAAAAA);
		_fpsInfoText0.width = _fpsInfoText1.width = 60;
		_fpsInfoText0.height = _fpsInfoText1.height = 20;
		_fpsInfo.x = 75;
		_fpsInfoText1.x = 60;
		_fpsInfo.width = _fpsInfoText0.width + _fpsInfoText1.width;

		// The FPS and frame timing panel.
		this.graphics.clear();
		this.graphics.beginFill(0, .75);
		this.graphics.drawRoundRect(-20, -20, big ? 320 + 20 : 160 + 20, 40, 40, 40);

		// The memory usage
#if !js
		this.addChild(_memReadText);
		_memReadText.defaultTextFormat = Format.format(16);
		_memReadText.embedFonts = true;
		_memReadText.width = 110;
		_memReadText.height = 20;
		_memReadText.x = (big) ? _fpsInfo.x + _fpsInfoText0.width + _fpsInfoText1.width + 5 : _fpsInfo.x + 9;
		_memReadText.y = 1;
#end
	}

	/** @private Update the FPS/frame timing panel text. */
	public function update()
	{
		_fpsReadText.text = "FPS: " + Std.int(HXP.frameRate);
		_fpsInfoText0.text =
			"Update: " + Std.string(HXP._updateTime) + "ms\n" +
			"Render: " + Std.string(HXP._renderTime) + "ms";
		_fpsInfoText1.text =
			"System: " + Std.string(HXP._systemTime) + "ms\n" +
			"Game: " + Std.string(HXP._gameTime) + "ms";
#if !js
		_memReadText.text =
			(big ? "Mem: " : "") + MathUtil.roundDecimal(flash.system.System.totalMemory / 1024 / 1024, 2) + "MB";
#end
	}

	var _fpsInfo:Sprite = new Sprite();
	var _fpsReadText:TextField = new TextField();
	var _fpsInfoText0:TextField = new TextField();
	var _fpsInfoText1:TextField = new TextField();
	var _memReadText:TextField = new TextField();
}
