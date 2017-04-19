import massive.munit.TestSuite;

import haxepunk.EntityListTest;
import haxepunk.ImportTest;
import haxepunk.masks.CollideTest;
import haxepunk.masks.HitboxTest;
import haxepunk.masks.SlopedGridTest;
import haxepunk.SceneTest;
import haxepunk.screen.FixedScaleModeTest;
import haxepunk.screen.ScaleModeTest;
import haxepunk.screen.UniformScaleModeTest;
import haxepunk.ScreenTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(haxepunk.EntityListTest);
		add(haxepunk.ImportTest);
		add(haxepunk.masks.CollideTest);
		add(haxepunk.masks.HitboxTest);
		add(haxepunk.masks.SlopedGridTest);
		add(haxepunk.SceneTest);
		add(haxepunk.screen.FixedScaleModeTest);
		add(haxepunk.screen.ScaleModeTest);
		add(haxepunk.screen.UniformScaleModeTest);
		add(haxepunk.ScreenTest);
	}
}
