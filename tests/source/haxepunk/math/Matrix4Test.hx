package haxepunk.math;

class Matrix4Test extends haxe.unit.TestCase
{

	public function testCreate()
	{
		var matrix = new Matrix4();

		isIdentityMatrix(matrix);
	}

	public function testIdentity()
	{
		var matrix = new Matrix4();
		matrix.identity();

		isIdentityMatrix(matrix);
	}

	public function testDeterminant()
	{
		var m = new Matrix4();

		assertEquals(1.0, m.determinant);

		m._11 = 1; m._12 = 2; m._13 = 3; m._14 = 1;
		m._21 = 3; m._22 = 4; m._23 = 5; m._24 = 2;
		m._31 = 2; m._32 = 4; m._33 = 3; m._34 = 5;
		m._41 = 1; m._42 = 2; m._43 = 4; m._44 = 3;

		assertEquals(18.0, m.determinant);

		m._11 = 1; m._12 = 2; m._13 = 3; m._14 = 4;
		m._21 = 2; m._22 = 3; m._23 = 4; m._24 = 5;
		m._31 = 3; m._32 = 4; m._33 = 5; m._34 = 6;
		m._41 = 4; m._42 = 5; m._43 = 6; m._44 = 7;

		assertEquals(0.0, m.determinant);
	}

	public function testInverse()
	{
		var a = new Matrix4();
		a.rotateZ(Math.PI);
		a.translate(0, 3, 5);

		var b = a.clone();
		assertTrue(b.invert());
		a.multiply(b);
		isIdentityMatrix(a);

		// check that inverse fails when the determinant is zero
		b._11 = 1; b._12 = 2; b._13 = 3; b._14 = 4;
		b._21 = 2; b._22 = 3; b._23 = 4; b._24 = 5;
		b._31 = 3; b._32 = 4; b._33 = 5; b._34 = 6;
		b._41 = 4; b._42 = 5; b._43 = 6; b._44 = 7;

		assertFalse(b.invert());
	}

	public function testRotateZ()
	{
		var matrix = new Matrix4();
		matrix.rotateZ(270 * Math.PI / 180);

		assertTrue(matrix._11 < 0.0000000001);
		assertEquals(1.0, matrix._12);
		assertTrue(matrix._22 < 0.0000000001);
		assertEquals(-1.0, matrix._21);

		matrix.identity();
		matrix.rotateZ(Math.PI);
		assertTrue(matrix._12 < 0.0000000001);
		assertEquals(-1.0, matrix._11);
		assertTrue(matrix._21 < 0.0000000001);
		assertEquals(-1.0, matrix._22);
		assertEquals(1.0, matrix._33);
	}

	public function testArrayAccess()
	{
		var matrix = new Matrix4();

		matrix[3] = 2;

		assertEquals(2.0, matrix[3]);
		assertEquals(2.0, matrix._14);
	}

	private function isIdentityMatrix(matrix:Matrix4)
	{
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

}
