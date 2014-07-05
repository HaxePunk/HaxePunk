package haxepunk.graphics;

@:access(haxepunk.graphics.TextureAtlas)
class TextureAtlasTest extends haxe.unit.TestCase
{

	@:access(haxepunk.graphics.Texture)
	override public function setup()
	{
		_texture = Texture.create("");
		_texture.originalWidth  = _texture.width  = 64;
		_texture.originalHeight = _texture.height = 64;
	}

	public function testAddTile()
	{
		var atlas = new TextureAtlas(_texture);
		assertEquals(0, atlas.addTile(16, 8, 32, 32));
		assertEquals(0, atlas._regions[0][0]);
		var result = [0.25, 0.125, 0.75, 0.125, 0.25, 0.625, 0.75, 0.625];
		for (i in 0...result.length)
		{
			assertEquals(result[i], atlas._texCoords[i]);
		}

		assertEquals(1, atlas.addTile(32, 0, 32, 32));
		assertEquals(4, atlas._regions[1][0]);
		result = [0.5, 0.0, 1.0, 0.0, 0.5, 0.5, 1.0, 0.5];
		for (i in 0...result.length)
		{
			assertEquals(result[i], atlas._texCoords[i+8]);
		}

		assertEquals(2, atlas.addTile(16, 8, 32, 32));
		assertEquals(8, atlas._regions[2][0]);
	}

	public function testInvalidRegion()
	{
		var atlas = new TextureAtlas(_texture);

		// not enough points
		assertEquals(-1, atlas.addRegion([16, 8, 32, 32]));

		// odd number of values
		assertEquals(-1, atlas.addRegion([0, 10, 20, 30, 40, 50, 60]));
	}

	public function testAddRegion()
	{
		var atlas = new TextureAtlas(_texture);

		assertEquals(0, atlas.addRegion([0, 0, 32, 8, 32, 16]));
		assertEquals(3, atlas._regions[0].length);
		var result = [0.0, 0.0, 0.5, 0.125, 0.5, 0.25];
		for (i in 0...result.length)
		{
			assertEquals(result[i], atlas._texCoords[i]);
		}
	}

	private var _texture:Texture;

}
