package haxepunk.graphics;

@:access(haxepunk.graphics.TextureAtlas)
class TextureAtlasTest extends haxe.unit.TestCase
{

	@:access(haxepunk.graphics.Texture)
	override public function setup()
	{
		_atlas = new TextureAtlas(null);
		_atlas.sourceWidth  = _atlas.width  = 64;
		_atlas.sourceHeight = _atlas.height = 64;
	}

	public function testAddTile()
	{
		var id = _atlas.addTile(16, 8, 32, 32);
		assertEquals(0, id);
		assertEquals(0, _atlas._index[id]);
		var result = [0.25, 0.125, 0.75, 0.125, 0.25, 0.625, 0.75, 0.625];
		for (i in 0...result.length)
		{
			assertEquals(result[i], _atlas._uvs[i]);
		}

		id = _atlas.addTile(32, 0, 32, 32);
		assertEquals(1, id);
		assertEquals(8, _atlas._index[id]);
		result = [0.5, 0.0, 1.0, 0.0, 0.5, 0.5, 1.0, 0.5];
		for (i in 0...result.length)
		{
			assertEquals(result[i], _atlas._uvs[i+8]);
		}

		// matches the first so it should be an index of 0
		assertEquals(0, _atlas.addTile(16, 8, 32, 32));

		id = _atlas.addTile(16, 8, 32, 24);
		assertEquals(2, id);
		assertEquals(16, _atlas._index[id]);
	}

	public function testInvalidQuad()
	{

		// not enough points
		assertEquals(-1, _atlas.addQuad([16, 8, 32, 32]));
	}

	public function testAddQuad()
	{

		assertEquals(0, _atlas.addQuad([0, 0, 32, 8, 32, 16, 8, 8]));
		assertEquals(8, _atlas._uvs.length);
		var result = [0.0, 0.0, 0.5, 0.125, 0.5, 0.25];
		for (i in 0...result.length)
		{
			assertEquals(result[i], _atlas._uvs[i]);
		}
	}

	public function testGenerateTiles()
	{
		var tiles = _atlas.generateTiles(8, 8);
		assertEquals(64, tiles.length);

		tiles = _atlas.generateTiles(8, 64);
		assertEquals(8, tiles.length);
		assertEquals(64, tiles[0]);

		tiles = _atlas.generateTiles(64, 8);
		assertEquals(8, tiles.length);

		tiles = _atlas.generateTiles(64, 64);
		assertEquals(1, tiles.length);

		tiles = _atlas.generateTiles(72, 64);
		assertEquals(0, tiles.length);
	}

	private var _atlas:TextureAtlas;

}
