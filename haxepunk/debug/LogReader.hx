package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;
import flash.geom.Rectangle;
import haxepunk.utils.MathUtil;

class LogReader extends Sprite
{
	public function new(big:Bool)
	{
		super();

		this.addChild(_logReadText0);
		this.addChild(_logReadText1);
		_logReadText0.defaultTextFormat = Format.format(16, 0xFFFFFF);
		_logReadText1.defaultTextFormat = Format.format(big ? 16 : 8, 0xFFFFFF);
		_logReadText0.selectable = false;
		_logReadText0.width = 80;
		_logReadText0.height = 20;
		_logReadText1.width = HXP.windowWidth;
		_logReadText0.x = 2;
		_logReadText0.y = 3;
		_logReadText0.text = "OUTPUT:";
		_logHeight = HXP.windowHeight - 60;
		_logBar = new Rectangle(8, 24, 16, _logHeight - 8);
		_logBarGlobal = _logBar.clone();
		_logBarGlobal.y += 40;
		if (big) _logLines = Std.int(_logHeight / 16.5);
		else _logLines = Std.int(_logHeight / 8.5);
	}

	public function log(text:String)
	{
		LOG.push(text);
	}

	public function canStartScrolling(x:Float, y:Float)
	{
		return LOG.length > _logLines ? _logBarGlobal.contains(x, y) : false;
	}

	public function scroll(y:Float)
	{
		_logScroll = MathUtil.scaleClamp(y, _logBarGlobal.y, _logBarGlobal.bottom, 0, 1);
	}

	function drawStart()
	{
		_logHeight = HXP.windowHeight - 60;
		_logBar.height = _logHeight - 8;
	}

	public function drawSingleLine()
	{
		drawStart();
		this.y = HXP.windowHeight - 40;
		_logReadText1.height = 20;
		this.graphics.clear();
		this.graphics.beginFill(0, .75);
		this.graphics.drawRect(0, 0, _logReadText0.width - 20, 20);
		this.graphics.moveTo(_logReadText0.width, 20);
		this.graphics.lineTo(_logReadText0.width - 20, 20);
		this.graphics.lineTo(_logReadText0.width - 20, 0);
		this.graphics.curveTo(_logReadText0.width, 0, _logReadText0.width, 20);
		this.graphics.drawRect(0, 20, HXP.windowWidth, 20);

		// Draw the single-line log text with the latests logged text.
		_logReadText1.text = (LOG.length != 0) ? LOG[LOG.length - 1] : "";
		_logReadText1.x = 2;
		_logReadText1.y = 21;
		_logReadText1.selectable = false;
	}

	public function drawMultipleLines()
	{
		drawStart();
		this.y = 40;
		this.graphics.clear();
		this.graphics.beginFill(0, .75);
		this.graphics.drawRect(0, 0, _logReadText0.width - 20, 20);
		this.graphics.moveTo(_logReadText0.width, 20);
		this.graphics.lineTo(_logReadText0.width - 20, 20);
		this.graphics.lineTo(_logReadText0.width - 20, 0);
		this.graphics.curveTo(_logReadText0.width, 0, _logReadText0.width, 20);
		this.graphics.drawRect(0, 20, HXP.windowWidth, _logHeight);

		// Draw the log scrollbar.
		this.graphics.beginFill(0x202020, 1);
		this.graphics.drawRoundRect(_logBar.x, _logBar.y, _logBar.width, _logBar.height, 16, 16);

		// If the log has more lines than the display limit.
		if (LOG.length > _logLines)
		{
			// Draw the log scrollbar handle.
			this.graphics.beginFill(0xFFFFFF, 1);
			var y:Int = Std.int(_logBar.y + 2 + (_logBar.height - 16) * _logScroll);
			this.graphics.drawRoundRect(_logBar.x + 2, y, 12, 12, 12, 12);
		}

		// Display the log text lines.
		if (LOG.length != 0)
		{
			var i:Int = (LOG.length > _logLines) ? Std.int(Math.round((LOG.length - _logLines) * _logScroll)) : 0,
				n:Int = Std.int(i + Math.min(_logLines, LOG.length)),
				s:String = "";
			while (i < n) s += LOG[i++] + "\n";
			_logReadText1.text = s;
		}
		else _logReadText1.text = "";

		// Indent the text for the scrollbar and size it to the log panel.
		_logReadText1.height = _logHeight;
		_logReadText1.x = 32;
		_logReadText1.y = 24;
	}

	var _logReadText0:TextField = new TextField();
	var _logReadText1:TextField = new TextField();
	var _logHeight:Int;
	var _logBar:Rectangle;
	var _logBarGlobal:Rectangle;
	var _logScroll:Float = 0;

	// Log information.
	var _logLines:Int = 33;
	var LOG = new Array<String>();
}
