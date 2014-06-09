import haxepunk.math.Matrix3D;

class MatrixTest extends haxe.unit.TestCase
{

	public function testCreate()
	{
		var matrix = new Matrix3D();

		assertEquals(1.0, matrix._11);
		assertEquals(0.0, matrix._12);
		assertEquals(0.0, matrix._13);
		assertEquals(0.0, matrix._14);

		assertEquals(0.0, matrix._21);
		assertEquals(1.0, matrix._22);
		assertEquals(0.0, matrix._23);
		assertEquals(0.0, matrix._24);

		assertEquals(0.0, matrix._31);
		assertEquals(0.0, matrix._32);
		assertEquals(1.0, matrix._33);
		assertEquals(0.0, matrix._34);

		assertEquals(0.0, matrix._41);
		assertEquals(0.0, matrix._42);
		assertEquals(0.0, matrix._43);
		assertEquals(1.0, matrix._44);
	}

	public function testIdentity()
	{
		var matrix = new Matrix3D();
		matrix.identity();

		assertEquals(1.0, matrix._11);
		assertEquals(0.0, matrix._12);
		assertEquals(0.0, matrix._13);
		assertEquals(0.0, matrix._14);

		assertEquals(0.0, matrix._21);
		assertEquals(1.0, matrix._22);
		assertEquals(0.0, matrix._23);
		assertEquals(0.0, matrix._24);

		assertEquals(0.0, matrix._31);
		assertEquals(0.0, matrix._32);
		assertEquals(1.0, matrix._33);
		assertEquals(0.0, matrix._34);

		assertEquals(0.0, matrix._41);
		assertEquals(0.0, matrix._42);
		assertEquals(0.0, matrix._43);
		assertEquals(1.0, matrix._44);
	}

	public function testRotateZ()
	{
		var matrix = new Matrix3D();
		matrix.rotateZ(Math.PI);

		assertEquals(-1.0, matrix._11);
		assertEquals(0.0, matrix._31);
	}

	public function testArrayAccess()
	{
		var matrix = new Matrix3D();

		matrix[3] = 2;

		assertEquals(2.0, matrix[3]);
		assertEquals(2.0, matrix._14);
	}

}
