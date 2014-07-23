package haxepunk.graphics;

@:access(haxepunk.graphics.Tilemap)
class TilemapTest extends haxe.unit.TestCase
{

	@:access(haxepunk.graphics.Texture)
	override public function setup()
	{
		_material = new Material();
		var texture = new Texture();
		texture.width = texture.sourceWidth = 8;
		texture.height = texture.sourceHeight = 9;
		_material.firstPass.addTexture(texture);

		_tilemap = new Tilemap(_material, 4, 6, 2, 3);
	}

	public function testInit()
	{
		assertEquals(4, _tilemap._width);
		assertEquals(6, _tilemap._height);

		assertEquals(2, _tilemap._columns);
		assertEquals(2, _tilemap._rows);

		assertEquals(4, _tilemap._setColumns);
		assertEquals(3, _tilemap._setRows);
		assertEquals(12, _tilemap._setCount);
	}

	public function testTileAccessors()
	{
		assertEquals(-1, _tilemap.getTile(1, 1));
		assertEquals(-1, _tilemap.getTile(500, 5));

		_tilemap.setTile(0, 0, 10);
		assertEquals(10, _tilemap.getTile(0, 0));

		_tilemap.clearTile(0, 0);
		assertEquals(-1, _tilemap.getTile(0, 0));
	}

	public function testSetRect()
	{
		_tilemap.setRect(0, 0, 1, 2, 2);
		_tilemap.setRect(1, 0, 1, 2, 1);
		assertEquals(2, _tilemap.getTile(0, 0));
		assertEquals(1, _tilemap.getTile(1, 0));
		assertEquals(2, _tilemap.getTile(0, 1));
		assertEquals(1, _tilemap.getTile(1, 1));

		_tilemap.clearRect(0, 0, 2, 1);
		assertEquals("-1,-1\n2,1", _tilemap.toString());
	}

	public function test2DArray()
	{
		_tilemap.loadFrom2DArray([[3, 1], [4, 2]]);
		assertEquals("3,1\n4,2", _tilemap.toString());
	}

	public function testTileIndex()
	{
		assertEquals(11, _tilemap.getIndex(3, 2));
		assertEquals(5, _tilemap.getIndex(1, 1));
		assertEquals(6, _tilemap.getIndex(6, 10));
	}

	public function testStringLoad()
	{
		_tilemap.fromString("1, 2\n 3,1");
		assertEquals(2, _tilemap.getTile(1, 0));

		_tilemap.fromString("1:2|3:1", ":", "|");
		assertEquals(3, _tilemap.getTile(0, 1));
	}

	public function testStringSave()
	{
		var data = _tilemap.toString();
		assertEquals("-1,-1\n-1,-1", data);
		assertEquals("-1:-1|-1:-1", _tilemap.toString(":", "|"));
	}

	private var _material:Material;
	private var _tilemap:Tilemap;

}
