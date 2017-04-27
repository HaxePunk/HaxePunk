package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;

class DebugText extends Sprite
{

	public var selectable(get, set):Bool;
	function get_selectable():Bool return _debReadText0.selectable;
	function set_selectable(value:Bool):Bool return _debReadText0.selectable = _debReadText1.selectable = value;

	public function new()
	{
		super();
		this.addChild(_debReadText0);
		this.addChild(_debReadText1);
		_debReadText0.defaultTextFormat = Format.format(16, 0xFFFFFF);
		_debReadText1.defaultTextFormat = Format.format(8, 0xFFFFFF);
		_debReadText0.selectable = false;
		_debReadText0.width = 80;
		_debReadText0.height = 20;
		_debReadText1.width = 160;
		_debReadText1.height = Std.int(HXP.windowHeight / 4);
		_debReadText0.x = 2;
		_debReadText0.y = 3;
		_debReadText1.x = 2;
		_debReadText1.y = 24;
		_debReadText0.text = "DEBUG:";
		this.y = HXP.windowHeight - (_debReadText1.y + _debReadText1.height);
	}

	/**
	 * Adds properties to watch in the console's debug panel.
	 * @param	properties		The properties (strings) to watch.
	 */
	public function watch(properties:Array<String>)
	{
		for (i in properties) WATCH_LIST.push(i);
	}

	public function update(entities:Array<Entity>, big:Bool)
	{
		var str:String;

		// Update the Debug read text.
		var s:String =
			"Mouse: " + Std.string(HXP.scene.mouseX) + ", " + Std.string(HXP.scene.mouseY) +
			"\nCamera: " + Std.string(HXP.camera.x) + ", " + Std.string(HXP.camera.y);
		if (entities.length != 0)
		{
			if (entities.length > 1)
			{
				s += "\n\nSelected: " + Std.string(entities.length);
			}
			else
			{
				var e:Entity = entities[0];
				s += "\n\n- " + Type.getClassName(Type.getClass(e)) + " -\n";
				for (str in WATCH_LIST)
				{
					var field = Reflect.field(e, str);
					if (field != null)
					{
						s += "\n" + str + ": " + Std.string(field);
					}
				}
			}
		}

		_debReadText1.text = s;
		_debReadText1.setTextFormat(Format.format(big ? 16 : 8));
		_debReadText1.width = Math.max(_debReadText1.textWidth + 4, _debReadText0.width);
		_debReadText1.height = _debReadText1.y + _debReadText1.textHeight + 4;

		// The debug panel.
		this.y = Std.int(HXP.windowHeight - _debReadText1.height);
		this.graphics.clear();
		this.graphics.beginFill(0, .75);
		this.graphics.drawRect(0, 0, _debReadText0.width - 20, 20);
		this.graphics.moveTo(_debReadText0.width, 20);
		this.graphics.lineTo(_debReadText0.width - 20, 20);
		this.graphics.lineTo(_debReadText0.width - 20, 0);
		this.graphics.curveTo(_debReadText0.width, 0, _debReadText0.width, 20);
		this.graphics.drawRoundRect(-20, 20, _debReadText1.width + 40, HXP.windowHeight - this.y, 40, 40);
	}

	// Watch information.
	var WATCH_LIST:Array<String> = ["x", "y"];

	var _debReadText0:TextField = new TextField();
	var _debReadText1:TextField = new TextField();
}
