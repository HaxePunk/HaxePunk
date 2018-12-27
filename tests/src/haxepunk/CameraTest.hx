package haxepunk;

import haxepunk.Camera;
import haxepunk.Entity;
import haxepunk.HXP;

class CameraTest
{
	@Test
	public function testCameraAnchor()
	{
		var e = new Entity();
		var camera = new Camera();
		
		// Set null information to 0
		var widthSave = HXP.width,
			heightSave = HXP.height;
		HXP.width = 0;
		HXP.height = 0;

		camera.anchor(e);
		Assert.areEqual(e.x, camera.x);
		Assert.areEqual(e.y, camera.y);
		e.x = 100;
		e.y = 500;
		Assert.areNotEqual( e.x, camera.x ); //shouldn't change
		Assert.areNotEqual( e.y, camera.y ); //shouldn't change
		camera.update();
		Assert.areEqual( e.x, camera.x );
		Assert.areEqual( e.y, camera.y );
		
		// Reset original values
		HXP.width = HXP.width;
		HXP.height = heightSave;
	}

}
