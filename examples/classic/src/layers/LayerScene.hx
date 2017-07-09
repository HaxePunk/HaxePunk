package layers;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.graphics.Image;
import haxepunk.graphics.text.Text;
import haxepunk.graphics.atlas.Atlas;

class LayerScene extends DemoScene
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
		var e = new Entity();
		e.layer = 50;

		var img2 = Image.createCircle(100, 0x00ff00);
		img2.x = 100;
		img2.y = 100;

		var img1 = Image.createCircle(100, 0xff0000);

		// add to graphic list
		e.addGraphic(img1);
		e.addGraphic(img2);
		add(e);

		var text = new Text("Hello World!", 0, 0, 0, 0, {resizable: true});
		text.smooth = true;
		text.size = 24;
		addGraphic(text, 30, 150, 250);

		var img3 = Image.createCircle(100, 0x0000ff);
		addGraphic(img3, 0, 200, 200); // add graphic at base layer 10

		var background = Image.createRect(HXP.width, HXP.height, 0xffffff);
		addGraphic(background, 100); // add graphic at back

		var text = new Text();
		text.color = 0x000000;
		text.addStyle("welcome", {color: 0xFF0000, bold: true});
		text.addStyle("orange", {color: 0xF2990D});
		text.richText = "<welcome>Welcome</welcome> to <orange>HaxePunk</orange>!";
		text.smooth = true;
		text.centerOrigin();
		addGraphic(text, -5, HXP.width / 2, HXP.height / 2);
	}

}
