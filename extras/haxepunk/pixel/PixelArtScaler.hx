package haxepunk.pixel;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.shader.SceneShader;

class PixelArtScaler extends Entity
{
	static var s1:SceneShader;
	static var s2:SceneShader;

	public static function globalActivate()
	{
		Graphic.smoothDefault = false;
		Graphic.pixelSnappingDefault = true;
		HXP.engine.onSceneSwitch.bind(activate);
	}

	public static function activate()
	{
		var e = new PixelArtScaler();
		HXP.scene.add(e);
		HXP.scene.camera.pixelSnapping = true;
		return e;
	}

	function new()
	{
		super();
		visible = active = collidable = false;
	}

	override public function added()
	{
		if (scene.shaders == null) scene.shaders = new Array();
		if (s1 == null) s1 = new SceneShader();
		s1.width = Std.int(HXP.width);
		s1.height = Std.int(HXP.height);
		if (s2 == null) s2 = new SceneShader();
		s2.smooth = true;
		resized();

		scene.shaders.push(s1);
		scene.shaders.push(s2);
		Log.info("pixel art shaders activated");
	}

	override public function removed()
	{
		if (scene.shaders != null)
		{
			scene.shaders.remove(s2);
			scene.shaders.remove(s1);
		}
	}

	override public function resized()
	{
		var sx = Std.int(Math.max(HXP.screen.scaleX, 1)),
			sy = Std.int(Math.max(HXP.screen.scaleY, 1));
		s1.active = sx > 1 || sy > 1;
		s2.width = Std.int(sx * HXP.width);
		s2.height = Std.int(sy* HXP.height);
	}
}
