package haxepunk.debug;

import haxe.ds.StringMap;
import haxepunk.ds.Maybe;
import haxepunk.graphics.text.Text;
import haxepunk.input.MouseManager;
import haxepunk.utils.Draw;

@:access(haxepunk.Scene)
private class LayerToggle extends Entity
{
	public var controlScene(default, set):Maybe<Scene>;
	inline function set_controlScene(value:Maybe<Scene>):Maybe<Scene>
	{
		visible = collidable = (value != null);
		return controlScene = value;
	}

	public var layerNumber:Int;

	var label:Text;

	var display:Bool = true;

	public function new(mouseManager:MouseManager)
	{
		super();
		label = new Text("Layer");
		label.alpha = 0.75;
		addGraphic(label);
		width = 220;
		height = 24;
		type = mouseManager.type;
		mouseManager.add(this, null, onClick, onEnter, onExit, true);
	}

	override public function update()
	{
		controlScene.may(function(scene)
		{
			var entityCount = scene._layers.exists(layerNumber) ? Lambda.count(scene._layers[layerNumber]) : 0;
			var txt = "Layer " + layerNumber + " [" + entityCount + "]";
			if (label.text != txt) label.text = txt;
			label.color = scene.layerVisible(layerNumber) ? 0x00ff00 : 0xff0000;
		});
	}

	function onClick()
	{
		controlScene.may(function(scene)
		{
			var display = !scene.layerVisible(layerNumber);
			scene.showLayer(layerNumber, display);
			scene.updateLists();
		});
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

		var entityId = 0;
		for (scene in HXP.engine.visibleScenes)
		{
			// skip console scene
			if (scene == HXP.engine.console) continue;

			// get or create scene label and update it's position
			var sceneLabel = getSceneLabel(scene);
			sceneLabel.visible = true;
			sceneLabel.y = childY;
			childY += sceneLabel.textHeight;

			for (layer in scene._layerList)
			{
				var toggle:LayerToggle;
				if (entities.length > entityId)
				{
					toggle = entities[entityId];
				}
				else
				{
					toggle = new LayerToggle(mouseManager);
					add(toggle);
				}
				toggle.controlScene = scene;
				toggle.layerNumber = layer;
				toggle.localY = childY;
				childY += toggle.height + 4;
				entityId += 1;
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
		for (i in entityId...entities.length)
		{
			entities[i].controlScene = null;
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
