import com.haxepunk.Engine;
import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.Mask;
import com.haxepunk.RenderMode;
import com.haxepunk.Scene;
import com.haxepunk.Screen;
import com.haxepunk.Sfx;
import com.haxepunk.Tweener;
import com.haxepunk.Tween;
import com.haxepunk.World;
import com.haxepunk.debug.Console;
import com.haxepunk.debug.LayerList;
import com.haxepunk.graphics.Animation;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Canvas;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Particle;
import com.haxepunk.graphics.ParticleType;
import com.haxepunk.graphics.PreRotation;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.TiledImage;
import com.haxepunk.graphics.TiledSpritemap;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.graphics.atlas.TileAtlas;
import com.haxepunk.graphics.prototype.Circle;
import com.haxepunk.graphics.prototype.Rect;
import com.haxepunk.masks.Circle;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.masks.Imagemask;
import com.haxepunk.masks.Masklist;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.masks.Polygon;
import com.haxepunk.masks.SlopedGrid;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import com.haxepunk.tweens.TweenEvent;
import com.haxepunk.tweens.misc.Alarm;
import com.haxepunk.tweens.misc.AngleTween;
import com.haxepunk.tweens.misc.ColorTween;
import com.haxepunk.tweens.misc.MultiVarTween;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.tweens.motion.CircularMotion;
import com.haxepunk.tweens.motion.CubicMotion;
import com.haxepunk.tweens.motion.LinearMotion;
import com.haxepunk.tweens.motion.LinearPath;
import com.haxepunk.tweens.motion.Motion;
import com.haxepunk.tweens.motion.QuadMotion;
import com.haxepunk.tweens.motion.QuadPath;
import com.haxepunk.tweens.sound.Fader;
import com.haxepunk.tweens.sound.SfxFader;
import com.haxepunk.utils.Data;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Joystick;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Touch;

/**
 * Empty test.
 * Import all of HaxePunk classes to make sure everything compile,
 * and that all used openfl functionalities exists.
 */
class TestImport extends haxe.unit.TestCase
{
	public override function setup()
	{
	}
	
	public override function tearDown()
	{
	}
}
