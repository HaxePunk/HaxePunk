package haxepunk.debug;

import flash.display.BlendMode;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.cameras.UICamera;
import haxepunk.graphics.Image;
import haxepunk.graphics.hardware.Renderer;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.input.MouseManager;
import haxepunk.utils.CircularBuffer;
import haxepunk.utils.DrawContext;

@:access(haxepunk.graphics.hardware)
@:access(haxepunk.Engine)
class Console extends Scene
{
	static inline var SAMPLE_TIME:Float = 20 / 60;
	static inline var DATA_SIZE:Int = Std.int(5 / SAMPLE_TIME);
	static inline var CAMERA_PAN_PER_SECOND:Float = 256;
	static inline var MIN_DRAG:Int = 8;

	public static function enable():Void enabled = true;

	public static var enabled(get, set):Bool;
	static inline function get_enabled() return HXP.engine.console != null;
	static inline function set_enabled(v:Bool)
	{
		HXP.engine.console = new Console();
		return true;
	}

	static inline function avg<T:Float>(buffer:CircularBuffer<T>):Float
	{
		return buffer.length == 0 ? 0 : (Lambda.fold(buffer, add2, 0) / buffer.length);
	}

	static inline function add2(a:Float, b:Float):Float return a + b;

	static var drawContext:DrawContext;

	public var fps:CircularBuffer<Float>;
	public var memory:CircularBuffer<Float>;
	public var entities:CircularBuffer<Int>;
	public var triangles:CircularBuffer<Int>;
	public var drawCalls:CircularBuffer<Int>;

	public var paused(get, set):Bool;
	inline function get_paused() return HXP.engine.paused;
	inline function set_paused(v:Bool)
	{
		return HXP.engine.paused = v;
	}

	public var debugDraw:Bool = false;

	var logo:Image;
	var buttonTray:ButtonTray;
	var logPanel:LogPanel;
	var layerList:LayerList;
	var fpsChart:Metric<Float>;
	var memoryChart:Metric<Float>;
	var entitiesChart:Metric<Int>;
	var trianglesChart:Metric<Int>;
	var drawCallsChart:Metric<Int>;

	var selected:Array<Entity> = new Array();

	var _fps:Float = 0;
	var _mem:Float = 0;
	var _ent:Float = 0;
	var _tri:Float = 0;
	var _dc:Float = 0;
	var _t:Float = 0;

	var click:Point = new Point();
	var selBox:Rectangle = new Rectangle();
	var clickActive:Bool = false;
	var dragging:Bool = false;
	var panning:Bool = false;

	var mouseManager:MouseManager;

	function new()
	{
		super();
		fps = new CircularBuffer(DATA_SIZE);
		memory = new CircularBuffer(DATA_SIZE);
		entities = new CircularBuffer(DATA_SIZE);
		triangles = new CircularBuffer(DATA_SIZE);
		drawCalls = new CircularBuffer(DATA_SIZE);

		logo = new Image("graphics/debug/console_logo.png");
		logo.blend = BlendMode.MULTIPLY;
		addGraphic(logo);

		fpsChart = new Metric("FPS", fps, 0xff0000, HXP.frameRate);
		fpsChart.x = fpsChart.y = 8;
		add(fpsChart);

		memoryChart = new Metric("Memory Used (MB)", memory, 0xffdd55, 256);
		memoryChart.x = fpsChart.x;
		memoryChart.y = fpsChart.y + fpsChart.height + 8;
		add(memoryChart);

		entitiesChart = new Metric("Entities", entities, 0xff6600, 16);
		entitiesChart.x = memoryChart.x;
		entitiesChart.y = memoryChart.y + memoryChart.height + 8;
		add(entitiesChart);

		trianglesChart = new Metric("Triangles", triangles, 0x00ff00, 128);
		trianglesChart.x = entitiesChart.x;
		trianglesChart.y = entitiesChart.y + entitiesChart.height + 8;
		add(trianglesChart);

		drawCallsChart = new Metric("Draw calls", drawCalls, 0x0000ff, 16);
		drawCallsChart.x = trianglesChart.x;
		drawCallsChart.y = trianglesChart.y + trianglesChart.height + 8;
		add(drawCallsChart);

		mouseManager = new MouseManager();
		mouseManager.type = "hxp_debug_ui";

		buttonTray = new ButtonTray(mouseManager, toggleDebugDraw, togglePause, step);
		buttonTray.y = 8;
		add(buttonTray);

		layerList = new LayerList(mouseManager);
		layerList.y = 8;
		add(layerList);

		logPanel = new LogPanel(mouseManager);
		logPanel.x = 8;
		add(logPanel);

		add(mouseManager);

		color = 0xc0c0c0;

		preRender.bind(debugRender);

		camera = new UICamera();

		if (drawContext == null)
		{
			drawContext = new DrawContext();
			drawContext.lineThickness = 2;
		}
	}

	override public function update()
	{
		super.update();

		if (Key.pressed(Key.TILDE))
		{
			togglePause();
			debugDraw = paused;
		}

		if (!paused)
		{
			updateMetrics();
		}

		if (paused)
		{
			if (Key.check(Key.RIGHT_SQUARE_BRACKET)) step();

			if (Key.check(Key.SHIFT))
			{
				var mx:Int = 0, my:Int = 0;
				if (Key.check(Key.LEFT)) mx = -1;
				else if (Key.check(Key.RIGHT)) mx = 1;
				if (Key.check(Key.UP)) my = -1;
				else if (Key.check(Key.DOWN)) my = 1;
				if (mx != 0 || my != 0)
				{
					var camera = HXP.scene.camera;
					camera.x = Std.int(camera.x + HXP.elapsed * CAMERA_PAN_PER_SECOND * mx);
					camera.y = Std.int(camera.y + HXP.elapsed * CAMERA_PAN_PER_SECOND * my);
				}
				if (!clickActive && Mouse.mouseDown)
				{
					panning = true;
				}
			}
			if (Mouse.mousePressed)
			{
				clickActive = true;
				dragging = false;
				click.setTo(HXP.scene.mouseX, HXP.scene.mouseY);
			}
			if (clickActive)
			{
				var mx = HXP.scene.mouseX,
					my = HXP.scene.mouseY;
				if (panning)
				{
					// panning
					var dx = Std.int(mx - click.x),
						dy = Std.int(my - click.y);
					if (dx != 0 || dy != 0)
					{
						if (selected.length > 0)
						{
							for (e in selected)
							{
								e.x += dx;
								e.y += dy;
							}
						}
						else
						{
							HXP.scene.camera.x -= dx;
							HXP.scene.camera.y -= dy;
						}
						click.setTo(HXP.scene.mouseX, HXP.scene.mouseY);
					}
				}
				else
				{
					// check for drag selection
					var moved = Math.abs(mx - click.x) + Math.abs(my - click.y);
					if (moved > MIN_DRAG)
					{
						dragging = true;
					}
					if (dragging)
					{
						selBox.setTo(Math.min(mx, click.x), Math.min(my, click.y), Math.abs(mx - click.x), Math.abs(my - click.y));
					}
					if (Mouse.mouseReleased)
					{
						if (!dragging)
						{
							selBox.setTo(click.x, click.y, 1, 1);
						}
						setSelection();
						clickActive = dragging = false;
					}
				}
			}
			if (!Mouse.mouseDown)
			{
				clickActive = dragging = panning = false;
			}
		}

		fpsChart.enabled =
			memoryChart.enabled =
			entitiesChart.enabled =
			trianglesChart.enabled =
			drawCallsChart.enabled =
			logPanel.enabled =
			layerList.enabled =
			debugDraw;

		logo.x = (camera.width - logo.width) / 2;
		logo.y = (camera.height - logo.height) / 2;
		logo.visible = paused;

		buttonTray.x = (camera.width - buttonTray.width) / 2;

		logPanel.width = Std.int(camera.width - logPanel.x - 8);
		logPanel.y = camera.height - logPanel.height - 8;

		layerList.x = camera.width - layerList.width - 8;

		alpha = paused ? 0.75 : 0;

		updateLists();
	}

	public inline function log(data:Array<Dynamic>)
	{
		logPanel.log(data);
	}

	public inline function watch(properties:Array<Dynamic>)
	{
		// TODO
	}

	function toggleDebugDraw()
	{
		debugDraw = !debugDraw;
	}

	function togglePause()
	{
		paused = !paused;
	}

	var _stepping:Bool = false;
	function step()
	{
		if (_stepping || !paused) return;
		_stepping = true;
		HXP.engine.update();
		updateMetrics();
		_stepping = false;
	}

	function updateMetrics()
	{
		var s = HXP.elapsed / SAMPLE_TIME;
		_fps += 1 / HXP.elapsed * s;
		_mem += flash.system.System.totalMemory / 1024 / 1024 * s;
		_ent += HXP.scene.count * s;
		_tri += Renderer.triangleCount * s;
		_dc += Renderer.drawCallCount * s;
		_t += s;
		if (_t >= 1)
		{
			fps.push(_fps / _t);
			memory.push(_mem / _t);
			entities.push(Std.int(_ent / _t));
			triangles.push(Std.int(_tri / _t));
			drawCalls.push(Std.int(_dc / _t));
			_fps = _mem = _ent = _tri = _dc = _t = 0;
		}
	}

	function debugRender()
	{
		if (debugDraw)
		{
			var scene = HXP.scene;
			for (layer in scene._layerList)
			{
				if (!scene.layerVisible(layer)) continue;
				for (e in scene._layers.get(layer))
				{
					e.debugDraw(scene.camera, selected.indexOf(e) > -1);
				}
			}
		}

		if (dragging)
		{
			drawContext.setColor(0xffffff, 0.9);
			var camera = HXP.scene.camera;
			drawContext.rect(
				(selBox.x - camera.x) * camera.fullScaleX,
				(selBox.y - camera.y) * camera.fullScaleY,
				selBox.width * camera.fullScaleX,
				selBox.height * camera.fullScaleY
			);
		}
	}

	function setSelection()
	{
		var _rect = HXP.rect;
		HXP.clear(selected);
		for (entity in HXP.scene._update)
		{
			_rect.setTo(entity.x - 4, entity.y - 4, 8, 8);
			if (selBox.intersects(_rect))
			{
				selected.push(entity);
			}
		}
	}
}
