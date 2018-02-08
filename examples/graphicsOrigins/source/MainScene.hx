package;

import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.graphics.ColoredRect;
import haxepunk.graphics.Image;
import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.NineSlice;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.graphics.text.BitmapText;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.input.Key;
import haxepunk.math.Vector2;

class MainScene extends Scene
{
	var _gList:Graphiclist;
	var _txtList:Graphiclist;
	var _emitter:Emitter;

	var _currentIdx:Int;
	var _targetOrigin:Vector2;
	var _targetScale:Float;

	override public function begin():Void
	{
		createGraphics();

		for (i in 1 ... _gList.children.length)
			_gList.children[i].visible = false;
		
		for (i in 1 ... _txtList.children.length)
			_txtList.children[i].visible = false;

		_currentIdx = 0;
		_targetOrigin = new Vector2(50, 0);
		_targetScale = 0.25;
		updateCurrentGraphic();

		HXP.tween(this,
			{ _targetScale: 1 },
			5,
			{
				type: haxepunk.Tween.TweenType.PingPong,
				ease: haxepunk.utils.Ease.cubeInOut
			}
		);
	}

	override public function update():Void
	{
		_emitter.emit("base");
		_emitter.emit("base");

		if (Key.pressed(Key.ANY))
		{
			_txtList.children[_currentIdx].visible = false;
			_gList.children[_currentIdx].visible = false;

			_currentIdx++;
			while (_currentIdx >= _gList.children.length)
				_currentIdx -= _gList.children.length;
			
			_txtList.children[_currentIdx].visible = true;
			_gList.children[_currentIdx].visible = true;
		}

		updateCurrentGraphic();

		super.update();
	}

	function updateCurrentGraphic():Void
	{
		var graphic = _gList.children[_currentIdx];
		graphic.centerOrigin();
		graphic.originX += _targetOrigin.x;
		graphic.originY += _targetOrigin.y;
		_targetOrigin.rotate(Math.PI * HXP.elapsed);

		if (Reflect.hasField(graphic, "scale"))
			Reflect.setField(graphic, "scale", _targetScale);
	}

	function createGraphics():Void
	{
		_gList = new Graphiclist();
		addGraphic(_gList);
		_gList.originX = -HXP.halfWidth;
		_gList.originY = -HXP.halfHeight;

		_txtList = new Graphiclist();
		addGraphic(_txtList);
		_txtList.originX = -HXP.halfWidth;
		_txtList.originY = -20;

		// ----- Image
		_txtList.add(createText("Image"));
		var img = new Image("graphics/HaxePunk.png");
		_gList.add(img);
		img.centerOrigin();
		img.scale = 0.5;

		// ----- BitmapText
		_txtList.add(createText("BitmapText"));
		var txt = createText("<3 HaxePunk");
		_gList.add(txt);
		txt.centerOrigin();

		// ----- Particles
		_txtList.add(createText("Particle Emitter"));
		_emitter = new Emitter("graphics/particle.png", 4, 4);
		_gList.add(_emitter);
		_emitter.newType("base");
		_emitter.setMotion("base", 0, 100, 1, 360, 50, 0.2);
		_emitter.setScale("base", 1, 3);
		_emitter.setAlpha("base", 1, 0.1);
		_emitter.centerOrigin();

		// ----- Colored Rect
		_txtList.add(createText("Colored Rect"));
		var rect = new ColoredRect(48, 48, 0xff0000);
		_gList.add(rect);
		rect.centerOrigin();

		// ----- Nine Slice
		_txtList.add(createText("NineSlice"));
		var nine = new NineSlice("graphics/nineSlice.png", 4, 4, 4, 4);
		_gList.add(nine);
		nine.width = 256;
		nine.height = 128;
		nine.centerOrigin();

		// ---- Tilemap
		_txtList.add(createText("Tilemap"));
		var map = new Tilemap("graphics/tiles.png", 128, 128, 8, 8);
		_gList.add(map);
		map.scaleX = map.scaleY = 2;
		for (i in 0 ... map.columns)
			for (j in 0 ... map.rows)
				map.setTile(i, j, HXP.choose([0, 1, 2, 3]));
	}

	function createText(text:String):BitmapText
	{
		var txt = new BitmapText(text, 0, 0, 0, 0, {
			font: "font/azmoonfleet.64.fnt",
			size: 64,
			align: "center"
		});

		txt.originX = txt.textWidth * 0.5;

		return txt;
	}
}
