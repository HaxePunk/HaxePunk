package haxepunk.debug;

import haxe.ds.StringMap;
import haxepunk.graphics.text.Text;
import haxepunk.input.MouseManager;
import haxepunk.utils.Draw;

@:access(haxepunk.Scene)
private class LayerToggle extends Entity
{
	public var controlScene:Scene;
	public var layerNumber:Null<Int>;

	var label:Text;

	var display:Bool = true;

	public function new(controlScene:Scene, mouseManager:MouseManager)
	{
		super();
		label = new Text("Layer");
		label.alpha = 0.75;
		addGraphic(label);
		width = 220;
		height = 24;
		this.controlScene = controlScene;
		type = mouseManager.type;
		mouseManager.add(this, null, onClick, onEnter, onExit, true);
	}

	override public function update()
	{
		visible = collidable = layerNumber != null;
		if (layerNumber != null)
		{
			var entityCount = 0;
			entityCount = controlScene._layers.exists(layerNumber) ? Lambda.count(controlScene._layers[layerNumber]) : 0;
			var txt = "Layer " + layerNumber + " [" + entityCount + "]";
			if (label.text != txt) label.text = txt;
			label.color = controlScene.layerVisible(layerNumber) ? 0x00ff00 : 0xff0000;
		}
	}

	function onClick()
	{
		if (layerNumber != null)
		{
			var display = !controlScene.layerVisible(layerNumber);
			controlScene.showLayer(layerNumber, display);
			controlScene.updateLists();
		}
	}

	function onEnter() label.alpha = 1;
	function onExit() label.alpha = 0.75;
}

@:access(haxepunk.Scene)
class LayerList extends EntityList<LayerToggle>
{
	var alpha:Float = 0.5;
	var mouseManager:MouseManager;
	var sceneLabels:StringMap<Text> = new StringMap<Text>();

	public function new(mouseManager:MouseManager)
	{
		super();
		this.mouseManager = mouseManager;
		width = 280;
		height = 320;

		type = mouseManager.type;
		mouseManager.add(this, null, null, onEnter, onExit);
	}

	function getLayerToggle(scene:Scene, layerNumber:Int):Null<LayerToggle>
	{
		for (e in entities)
		{
			if (e.layerNumber == layerNumber && e.controlScene == scene)
			{
				return e;
			}
		}
		return null;
	}

	function getSceneLabel(scene:Scene):Text
	{
		var className = Type.getClassName(Type.getClass(scene));
		if (sceneLabels.exists(className))
		{
			return sceneLabels.get(className);
		}
		else
		{
			var sceneLabel = new Text();
			sceneLabel.text = className;
			addGraphic(sceneLabel);
			sceneLabels.set(className, sceneLabel);
			return sceneLabel;
		}
	}

	override public function update()
	{
		super.update();

		var childY:Int = 8;

		// hide scene labels and toggles until they are used
		for (label in sceneLabels)
		{
			label.visible = false;
		}
		for (toggle in entities)
		{
			toggle.visible = false;
		}

		for (scene in HXP.engine.visibleScenes)
		{
			// skip console scene
			if (scene == HXP.engine.console) continue;

			// get or create scene label and update it's position
			var sceneLabel = getSceneLabel(scene);
			sceneLabel.visible = true;
			sceneLabel.y = childY;
			childY += sceneLabel.textHeight;

			var layers = [for (layer in scene._layerList) layer];
			layers.sort(function(a, b) return a - b);
			for (layer in layers)
			{
				var toggle = getLayerToggle(scene, layer);
				if (toggle == null)
				{
					toggle = new LayerToggle(scene, mouseManager);
					toggle.layerNumber = layer;
					add(toggle);
				}
				toggle.visible = true;
				toggle.localY = childY;
				childY += toggle.height + 4;
				toggle.update();
			}
		}

		// remove any unused scene labels
		for (sceneName in sceneLabels.keys())
		{
			if (!sceneLabels.get(sceneName).visible)
			{
				sceneLabels.remove(sceneName);
			}
		}
		// remove any unused layer toggles
		for (e in entities)
		{
			if (!e.visible)
			{
				remove(e);
			}
		}
	}

	override public function render(camera:Camera)
	{
		var fsx:Float = camera.fullScaleX,
			fsy:Float = camera.fullScaleY;
		Draw.setColor(0, alpha);
		Draw.lineThickness = 4;
		Draw.rectFilled(x * fsx, y * fsy, width * fsx, height * fsy);

		super.render(camera);
	}

	function onEnter() alpha = 0.75;
	function onExit() alpha = 0.5;
}
