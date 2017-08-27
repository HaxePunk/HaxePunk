package haxepunk.debug;

import haxepunk.graphics.text.Text;
import haxepunk.input.MouseManager;
import haxepunk.utils.Draw;

@:access(haxepunk.Scene)
private class LayerToggle extends Entity
{
	public var layerNumber:Null<Int>;

	var label:Text;

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
		visible = collidable = layerNumber != null;
		if (layerNumber != null)
		{
			var entityCount = HXP.scene._layers.exists(layerNumber) ? Lambda.count(HXP.scene._layers[layerNumber]) : 0;
			var txt = "Layer " + layerNumber + " [" + entityCount + "]";
			if (label.text != txt) label.text = txt;
			label.color = HXP.scene.layerVisible(layerNumber) ? 0x00ff00 : 0xff0000;
		}
	}

	function onClick()
	{
		if (layerNumber != null)
		{
			var display = !HXP.scene.layerVisible(layerNumber);
			HXP.scene.showLayer(layerNumber, display);
			HXP.scene.updateLists();
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
	var sceneLabel:Text;
	var childY:Int = 8;

	public function new(mouseManager:MouseManager)
	{
		super();
		this.mouseManager = mouseManager;
		width = 280;
		height = 320;

		sceneLabel = new Text("Scene");
		sceneLabel.y = childY;
		childY += sceneLabel.textHeight;
		graphic = sceneLabel;

		type = mouseManager.type;
		mouseManager.add(this, null, null, onEnter, onExit);
	}

	override public function update()
	{
		super.update();

		var layerCount = HXP.scene._layerList.length;
		while (entities.length < layerCount)
		{
			var toggle = new LayerToggle(mouseManager);
			add(toggle);
			toggle.localY = childY;
			childY += toggle.height + 4;
		}

		for (i in 0 ... entities.length)
		{
			entities[i].layerNumber = i >= HXP.scene._layerList.length ? null : HXP.scene._layerList[i];
			entities[i].update();
		}

		var txt = Type.getClassName(Type.getClass(HXP.scene));
		if (sceneLabel.text != txt) sceneLabel.text = txt;
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
