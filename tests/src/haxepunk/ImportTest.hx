package haxepunk;

import massive.munit.Assert;
import haxepunk.Engine;
import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.Mask;
import haxepunk.RenderMode;
import haxepunk.Scene;
import haxepunk.Screen;
import haxepunk.Sfx;
import haxepunk.Tweener;
import haxepunk.Tween;
import haxepunk.debug.Console;
import haxepunk.debug.LayerList;
import haxepunk.graphics.Animation;
import haxepunk.graphics.Backdrop;
import haxepunk.graphics.BitmapText;
import haxepunk.graphics.Canvas;
import haxepunk.graphics.Emitter;
import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Image;
import haxepunk.graphics.Particle;
import haxepunk.graphics.ParticleType;
import haxepunk.graphics.PreRotation;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.Text;
import haxepunk.graphics.TiledImage;
import haxepunk.graphics.TiledSpritemap;
import haxepunk.graphics.Tilemap;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.BitmapFontAtlas;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.masks.Circle;
import haxepunk.masks.Grid;
import haxepunk.masks.Hitbox;
import haxepunk.masks.Imagemask;
import haxepunk.masks.Masklist;
import haxepunk.masks.Pixelmask;
import haxepunk.masks.Polygon;
import haxepunk.masks.SlopedGrid;
import haxepunk.utils.Projection;
import haxepunk.utils.Vector;
import haxepunk.tweens.TweenEvent;
import haxepunk.tweens.misc.Alarm;
import haxepunk.tweens.misc.AngleTween;
import haxepunk.tweens.misc.ColorTween;
import haxepunk.tweens.misc.MultiVarTween;
import haxepunk.tweens.misc.NumTween;
import haxepunk.tweens.misc.VarTween;
import haxepunk.tweens.motion.CircularMotion;
import haxepunk.tweens.motion.CubicMotion;
import haxepunk.tweens.motion.LinearMotion;
import haxepunk.tweens.motion.LinearPath;
import haxepunk.tweens.motion.Motion;
import haxepunk.tweens.motion.QuadMotion;
import haxepunk.tweens.motion.QuadPath;
import haxepunk.tweens.sound.Fader;
import haxepunk.tweens.sound.SfxFader;
import haxepunk.utils.Data;
import haxepunk.utils.Draw;
import haxepunk.utils.Ease;
import haxepunk.input.Input;
import haxepunk.input.Joystick;
import haxepunk.input.Key;
import haxepunk.input.Touch;

/**
 * Empty test.
 * Import all of HaxePunk classes to make sure everything compile,
 * and that all used openfl functionalities exists.
 */
class ImportTest extends TestSuite
{
	@Test
	public function tearDown()
	{
		Assert.isTrue(true);
	}
}
