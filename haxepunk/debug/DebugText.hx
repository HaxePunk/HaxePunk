package haxepunk.debug;

import flash.display.Sprite;
import flash.text.TextField;

class DebugText extends Sprite
{

	public var selectable(get, set):Bool;
	function get_selectable():Bool return _title.selectable;
	function set_selectable(value:Bool):Bool return _title.selectable = _entityInfo.selectable = value;

	public function new()
	{
		super();
		this.addChild(_title);
		this.addChild(_entityInfo);
		_title.defaultTextFormat = Format.format(16, 0xFFFFFF);
		_entityInfo.defaultTextFormat = Format.format(8, 0xFFFFFF);
		_title.selectable = false;
		_title.width = 80;
		_title.height = 20;
		_entityInfo.width = 160;
		_entityInfo.height = Std.int(HXP.windowHeight / 4);
		_title.x = 2;
		_title.y = 3;
		_entityInfo.x = 2;
		_entityInfo.y = 24;
		_title.text = "DEBUG:";
		this.y = HXP.windowHeight - (_entityInfo.y + _entityInfo.height);
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
		// Update the Debug read text.
		var lines:Array<String> = [
			'Mouse: ${HXP.scene.mouseX}, ${HXP.scene.mouseY}',
			'Camera: ${HXP.camera.x}, ${HXP.camera.y}'
		];
		if (entities.length != 0)
		{
			lines.push(""); // empty line
			if (entities.length > 1)
			{
				lines.push('Selected: ${entities.length}');
			}
			else
			{
				var e:Entity = entities[0];
				var className = Type.getClassName(Type.getClass(e));
				lines.push('- $className -');
				for (str in WATCH_LIST)
				{
					var field = Reflect.field(e, str);
					if (field != null)
					{
						lines.push('$str: ${field}');
					}
				}
			}
		}

		_entityInfo.text = lines.join("\n");
		_entityInfo.setTextFormat(Format.format(big ? 16 : 8));
		_entityInfo.width = Math.max(_entityInfo.textWidth + 4, _title.width);
		_entityInfo.height = _entityInfo.y + _entityInfo.textHeight + 4;

		// The debug panel.
		y = Std.int(HXP.windowHeight - _entityInfo.height);
		drawBackground();
	}

	function drawBackground()
	{
		var titleWidth = _title.width;
		graphics.clear();
		graphics.beginFill(0, .75);
		graphics.drawRect(0, 0, titleWidth - 20, 20);
		graphics.moveTo(titleWidth, 20);
		graphics.lineTo(titleWidth - 20, 20);
		graphics.lineTo(titleWidth - 20, 0);
		graphics.curveTo(titleWidth, 0, titleWidth, 20);
		graphics.drawRoundRect(-20, 20, _entityInfo.width + 40, HXP.windowHeight - this.y, 40, 40);
	}

	// Watch information.
	var WATCH_LIST:Array<String> = ["x", "y"];

	var _title:TextField = new TextField();
	var _entityInfo:TextField = new TextField();
}
