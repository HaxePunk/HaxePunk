package haxepunk.scene;

import lime.utils.Matrix3D;

class Scene
{

	public var camera:Camera;

	public function new()
	{
		camera = new Camera();
		entities = new List<Entity>();
	}

	public function add(e:Entity)
	{
		entities.add(e);
	}

	public function draw()
	{
		camera.setup();
		for (entity in entities)
		{
			entity.draw(camera.matrix);
		}
	}

	public function update()
	{
		for (entity in entities)
		{
			entity.update();
		}
	}

	private var entities:List<Entity>;

}
