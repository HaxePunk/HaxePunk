package haxepunk;

import massive.munit.Assert;

class SceneOrder extends Scene
{
    public static var UPDATE_ORDER:Int = 0;
    public var order:Int;

    public function new(order:Int)
    {
        this.order = order;
        super();
    }

    override public function update()
    {
        Assert.areEqual(order, UPDATE_ORDER);
        UPDATE_ORDER += 1;
    }
}

class EngineTest
{
    var engine:Engine;

    @Before
    public function setup()
    {
        engine = new Engine();
    }

    function addSceneList<S:Scene>(sceneList:Array<S>):Array<S>
    {
        for (scene in sceneList)
        {
            engine.pushScene(scene);
        }
        engine.update();
        return sceneList;
    }

    @Test
    public function testAddScene()
    {
        engine.pushScene(new Scene());
        Assert.areEqual(0, engine.sceneCount);
        engine.update();
        Assert.areEqual(1, engine.sceneCount);
    }

    @Test
    public function testSceneOrder()
    {
        var sceneList = addSceneList([new SceneOrder(0), new SceneOrder(1), new SceneOrder(2)]);
        Assert.areEqual(sceneList.length, engine.sceneCount);
    }

    @Test
    public function testPopScene()
    {
        var a = new Scene(),
            b = new Scene();
        engine.pushScene(a);
        engine.pushScene(b);
        engine.update();
        Assert.areEqual(b, engine.popScene());
        Assert.areEqual(a, engine.popScene());
        Assert.areEqual(2, engine.sceneCount);
        engine.update();
        Assert.areEqual(0, engine.sceneCount);
    }

    @Test
    public function testPopEmpty()
    {
        Assert.areEqual(null, engine.popScene());
    }

    @Test
    public function testPopAddBuffer()
    {
        var scene = new Scene();
        engine.pushScene(scene);
        Assert.areEqual(scene, engine.popScene());
    }

    @Test
    public function testRemoveScene()
    {
        var scene = new Scene();
        engine.pushScene(scene);
        engine.update();
        engine.removeScene(scene);
        Assert.areEqual(1, engine.sceneCount);
        engine.update();
        Assert.areEqual(0, engine.sceneCount);
    }

    @Test
    public function testAddAndRemoveSceneInSameFrame()
    {
        var scene = new Scene();
        engine.pushScene(scene);
        engine.removeScene(scene);
        Assert.areEqual(0, engine.sceneCount);
        engine.update();
        Assert.areEqual(0, engine.sceneCount);
    }

    @Test
    public function testRemoveAllScenes()
    {
        var sceneList = addSceneList([new Scene(), new Scene(), new Scene()]);
        engine.removeAllScenes();
        Assert.areEqual(sceneList.length, engine.sceneCount);
        engine.update();
        Assert.areEqual(0, engine.sceneCount);
    }

    @Test
    public function testSetScene()
    {
        var sceneList = addSceneList([new Scene(), new Scene(), new Scene()]);
        var scene = new Scene();
        engine.setScene(scene);
        Assert.areEqual(sceneList.length, engine.sceneCount);
        engine.update();
        Assert.areEqual(1, engine.sceneCount);
        Assert.areEqual(scene, engine.popScene());
    }
}