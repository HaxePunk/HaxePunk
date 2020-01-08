package haxepunk;

import haxepunk.graphics.Graphiclist;

class SubEntity extends Entity {}
class RenderedGraphic extends Graphic
{
	public function new() super();

	public var isRendered = false;
	override public function render(p, g)
	{
		isRendered = true;
	}
}

class EntityTest
{
	var e:Entity;
	var scene:Scene;

	@Before
	public function setup()
	{
		e = new Entity();
		scene = new Scene();
	}

	public function addToScene(e:Entity)
	{
		scene.add(e);
		scene.updateLists(true);
	}

	@Test
	public function testStringName()
	{
		Assert.areEqual("haxepunk.Entity", e.toString());
		Assert.areEqual("haxepunk.SubEntity", new SubEntity().toString());
	}

	@Test
	public function testLayer()
	{
		Assert.areEqual(0, e.layer);
		e.layer = 10;
		Assert.areEqual(10, e.layer);
		addToScene(e);
		Assert.areEqual(1, scene.layerCount(10));
		e.layer = -143; // allow for negatives
		Assert.areEqual(0, scene.layerCount(10));
		Assert.areEqual(1, scene.layerCount(-143));
	}

	@Test
	public function testType()
	{
		Assert.areEqual("", e.type);
		e.type = "foobar";
		addToScene(e);
		Assert.areEqual(1, scene.typeCount("foobar"));
		e.type = "Hi, there\\ 'quote'";
		Assert.areEqual(0, scene.typeCount("foobar"));
		Assert.areEqual("Hi, there\\ 'quote'", e.type);
	}

	@Test
	public function testName()
	{
		Assert.areEqual("", e.name);
		e.name = "foobar";
		addToScene(e);
		Assert.areEqual(e, scene.getInstance("foobar"));
		e.name = "hello";
		Assert.areEqual(null, scene.getInstance("foobar"));
		Assert.areEqual(e, scene.getInstance("hello"));
	}

	@Test
	public function addGraphic()
	{
		var g = new Graphic();
		e.addGraphic(g);
		Assert.areEqual(e.graphic, g);
		e.addGraphic(g);
		Assert.isType(e.graphic, Graphiclist);
		Assert.areEqual(2, cast(e.graphic, Graphiclist).count);
		e.addGraphic(g);
		Assert.areEqual(3, cast(e.graphic, Graphiclist).count);
	}

	@Test
	public function testSetHitbox()
	{
		var e = new Entity(51, 89);
		e.setHitbox(20, 30, 5, 7);
		Assert.areEqual(20, e.width);
		Assert.areEqual(10, e.halfWidth);
		Assert.areEqual(30, e.height);
		Assert.areEqual(15, e.halfHeight);
		Assert.areEqual(5, e.originX);
		Assert.areEqual(7, e.originY);

		Assert.areEqual(56, e.centerX);
		Assert.areEqual(97, e.centerY);
		Assert.areEqual(46, e.left);
		Assert.areEqual(66, e.right);
		Assert.areEqual(82, e.top);
		Assert.areEqual(112, e.bottom);
	}

	@Test
	public function testSetHitboxTo()
	{
		e.setHitboxTo({
			width: 12,
			height: 13,
			x: -14,
			y: 53
		});
		Assert.areEqual(12, e.width);
		Assert.areEqual(13, e.height);
		Assert.areEqual(14, e.originX);
		Assert.areEqual(-53, e.originY);

		e.setHitboxTo({
			originX: 849,
			originY: -253
		});
		Assert.areEqual(0, e.width);
		Assert.areEqual(0, e.height);
		Assert.areEqual(849, e.originX);
		Assert.areEqual(-253, e.originY);

		e.setHitboxTo(null);
		Assert.areEqual(0, e.width);
		Assert.areEqual(0, e.height);
		Assert.areEqual(0, e.originX);
		Assert.areEqual(0, e.originY);
	}

	@Test
	public function testSetOrigin()
	{
		e.setOrigin();
		Assert.areEqual(0, e.originX);
		Assert.areEqual(0, e.originY);

		e.setOrigin(42, 19);
		Assert.areEqual(42, e.originX);
		Assert.areEqual(19, e.originY);
	}

	@Test
	public function testCenterOrigin()
	{
		e.centerOrigin();
		Assert.areEqual(0, e.originX);
		Assert.areEqual(0, e.originY);

		e.setHitbox(20, 25);
		e.centerOrigin();
		Assert.areEqual(10, e.originX);
		Assert.areEqual(12, e.originY);
	}

	@Test
	public function testDistanceFrom()
	{
		Assert.areEqual(0, e.distanceFrom(e));
		var e2 = new Entity(50, 50);
		Assert.areEqual(71, Math.round(e.distanceFrom(e2)));

		e.setHitbox(30, 30);
		Assert.areEqual(28, Math.round(e.distanceFrom(e2, true)));
	}

	@Test
	public function testDistanceToPoint()
	{
		Assert.areEqual(0, e.distanceToPoint(0, 0));
		Assert.areEqual(71, Math.round(e.distanceToPoint(50, 50)));

		e.setHitbox(30, 30);
		Assert.areEqual(28, Math.round(e.distanceToPoint(50, 50, true)));
	}

	@Test
	public function testDistanceToRect()
	{
		Assert.areEqual(71, Math.round(e.distanceToRect(50, 50, 0, 0)));
		e.setHitbox(30, 30);
		Assert.areEqual(28, Math.round(e.distanceToRect(50, 50, 12, 43)));
	}

	@Test
	public function testCollide()
	{
		Assert.isNull(e.collide("test", 0, 0));
		addToScene(e);
		Assert.isNull(e.collide("test", 0, 0));
	}

	@Test
	public function testScene()
	{
		Assert.isNull(e.scene);
		addToScene(e);
		Assert.isNotNull(e.scene);
	}

	@Test
	public function testCenterGraphic()
	{
		e.setHitbox(40, 50);
		e.centerGraphicInRect();
		var g = new Graphic();
		e.addGraphic(g);
		e.centerGraphicInRect();
		Assert.areEqual(20, g.x);
		Assert.areEqual(25, g.y);
	}

	@Test
	public function testRender()
	{
		var camera = new Camera();
		e.render(camera);
		var g = new RenderedGraphic();
		e.addGraphic(g);
		e.render(camera);
		Assert.isTrue(g.isRendered);
	}

	@Test
	public function testVisible()
	{
		Assert.isTrue(e.visible);
		e.parent = new Entity();
		e.parent.visible = false;
		Assert.isFalse(e.visible);
		e.parent = null;
		Assert.isTrue(e.visible);
		e.visible = false;
		Assert.isFalse(e.visible);
	}

	@Test
	public function testCollidable()
	{
		Assert.isTrue(e.collidable);
		e.parent = new Entity();
		e.parent.collidable = false;
		Assert.isFalse(e.collidable);
		e.parent = null;
		Assert.isTrue(e.collidable);
		e.collidable = false;
		Assert.isFalse(e.collidable);
	}

	@Test
	public function testActive()
	{
		Assert.isTrue(e.active);
		e.parent = new Entity();
		e.parent.active = false;
		Assert.isFalse(e.active);
		e.parent = null;
		Assert.isTrue(e.active);
		e.active = false;
		Assert.isFalse(e.active);
	}

	@Test
	public function testEnabled()
	{
		Assert.isTrue(e.enabled);
		e.active = false;
		Assert.isFalse(e.enabled);
		e.active = true;
		e.visible = false;
		Assert.isFalse(e.enabled);
		e.visible = true;
		e.collidable = false;
		Assert.isFalse(e.enabled);
		e.collidable = true;
		Assert.isTrue(e.enabled);
		e.enabled = false;
		Assert.isFalse(e.visible);
		Assert.isFalse(e.collidable);
		Assert.isFalse(e.enabled);
	}

	@Test
	public function testGetPosition()
	{
		e.x = 15; e.y = 4;
		Assert.areEqual(15, e.x);
		Assert.areEqual(4, e.y);
		e.parent = new Entity(32, 87);
		Assert.areEqual(47, e.x);
		Assert.areEqual(91, e.y);
		e.followCamera = new Camera(99, 32);
		Assert.areEqual(146, e.x);
		Assert.areEqual(123, e.y);
	}

	@Test
	public function testSetPosition()
	{
		e.x = 15; e.y = 4;
		e.parent = new Entity(32, 87);
		Assert.areEqual(47, e.x);
		Assert.areEqual(91, e.y);
	}

	@Test
	public function testSetPositionReverse()
	{
		e.parent = new Entity(32, 87);
		e.x = 15; e.y = 4;
		// Order changes the value of x, y
		Assert.areEqual(15, e.x);
		Assert.areEqual(4, e.y);
	}

	@Test
	public function testLocalPosition()
	{
		e.x = 15; e.y = 4;
		e.parent = new Entity(32, 87);
		Assert.areEqual(15, e.localX);
		Assert.areEqual(4, e.localY);
	}

	@Test
	public function testLocalPositionReverse()
	{
		e.parent = new Entity(32, 87);
		e.x = 15; e.y = 4;
		// Order changes the value of x, y
		Assert.areEqual(-17, e.localX);
		Assert.areEqual(-83, e.localY);
	}

	@Test
	public function testSetLocalPosition()
	{
		e.localX = 15; e.localY = 4;
		e.parent = new Entity(32, 87);
		Assert.areEqual(47, e.x);
		Assert.areEqual(91, e.y);
	}

	@Test
	public function testSetLocalPositionReverse()
	{
		e.parent = new Entity(32, 87);
		e.localX = 15; e.localY = 4;
		// Order changes the value of x, y
		Assert.areEqual(47, e.x);
		Assert.areEqual(91, e.y);
	}
}
