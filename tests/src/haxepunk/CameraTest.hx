package haxepunk;

import haxepunk.Camera;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.math.Vector2;

class CameraTest
{
	var widthSave:Int;
	var heightSave:Int;

	@Before
	public function setup():Void
	{
		widthSave = HXP.width;
		heightSave = HXP.height;
		HXP.width = 0;
		HXP.height = 0;
	}

	@After
	public function tearDown():Void
	{
		HXP.width = heightSave;
		HXP.height = heightSave;
	}

	// @Test
	public function testCameraAnchorEntity()
	{
		var e = new Entity(0,2);
		var camera = new Camera();

		camera.anchor(e);
		camera.update();
		Assert.areEqual( e.x, camera.x );
		Assert.areEqual( e.y, camera.y );
		
		e.x = 100;
		e.y = 500;
		Assert.areNotEqual( e.x, camera.x ); //shouldn't change
		Assert.areNotEqual( e.y, camera.y ); //shouldn't change
		
		camera.update();
		Assert.areEqual( e.x, camera.x );
		Assert.areEqual( e.y, camera.y );
	}

	@Test
	public function testCameraAnchorOther()
	{
		var v = new Vector2(0,2);
		var camera = new Camera();

		camera.anchor(v);
		camera.update();
		Assert.areEqual( v.x, camera.x );
		Assert.areEqual( v.y, camera.y );
		
		v.x = 100;
		v.y = 500;
		Assert.areNotEqual( v.x, camera.x ); //shouldn't change
		Assert.areNotEqual( v.y, camera.y ); //shouldn't change
		
		camera.update();
		Assert.areEqual( v.x, camera.x );
		Assert.areEqual( v.y, camera.y );
	}

}
