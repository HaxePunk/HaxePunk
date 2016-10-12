import massive.munit.TestSuite;

import com.haxepunk.EntityListTest;
import com.haxepunk.ImportTest;
import com.haxepunk.masks.CollideTest;
import com.haxepunk.masks.HitboxTest;
import com.haxepunk.masks.SlopedGridTest;
import com.haxepunk.SceneTest;
import com.haxepunk.screen.FixedScaleModeTest;
import com.haxepunk.screen.UniformScaleModeTest;
import com.haxepunk.ScreenTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(com.haxepunk.EntityListTest);
		add(com.haxepunk.ImportTest);
		add(com.haxepunk.masks.CollideTest);
		add(com.haxepunk.masks.HitboxTest);
		add(com.haxepunk.masks.SlopedGridTest);
		add(com.haxepunk.SceneTest);
		add(com.haxepunk.screen.FixedScaleModeTest);
		add(com.haxepunk.screen.UniformScaleModeTest);
		add(com.haxepunk.ScreenTest);
	}
}
