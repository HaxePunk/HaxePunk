import massive.munit.TestSuite;

import haxepunk.masks.HitboxTest;
import haxepunk.masks.SlopedGridTest;
import haxepunk.masks.CollideTest;
import haxepunk.screen.ScaleModeTest;
import haxepunk.screen.FixedScaleModeTest;
import haxepunk.screen.UniformScaleModeTest;
import haxepunk.SceneTest;
import haxepunk.ScreenTest;
import haxepunk.EntityListTest;
import haxepunk.ImportTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(haxepunk.masks.HitboxTest);
		add(haxepunk.masks.SlopedGridTest);
		add(haxepunk.masks.CollideTest);
		add(haxepunk.screen.ScaleModeTest);
		add(haxepunk.screen.FixedScaleModeTest);
		add(haxepunk.screen.UniformScaleModeTest);
		add(haxepunk.SceneTest);
		add(haxepunk.ScreenTest);
		add(haxepunk.EntityListTest);
		add(haxepunk.ImportTest);
	}
}
