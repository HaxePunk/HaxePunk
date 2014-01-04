package layers;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.atlas.Atlas;

class LayerScene extends DemoScene
{

	public function new()
	{
		super();

		// Atlas.drawCallThreshold = 0;
	}

	public override function begin()
	{

		var e = new Entity();
		e.layer = 50;
		var img1 = Image.createCircle(100, 0xff0000);

		var img2 = Image.createCircle(100, 0x00ff00);
		img2.x = 100;
		img2.y = 100;

		var img3 = Image.createCircle(100, 0x0000ff);
		img3.x = 200;
		img3.y = 200;

		var background = Image.createRect(HXP.width, HXP.height, 0xffffff);

		e.addGraphic(background);
		e.addGraphic(img1);
		e.addGraphic(img2);
		e.addGraphic(img3);

		// add entity to scene list
		add(e);
	}
}