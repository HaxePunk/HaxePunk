package haxepunk.math;

class Matrix3D extends lime.utils.Matrix3D
{
	public static inline function createOrtho(x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float):Matrix3D
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);

		return new Matrix3D([
			2.0*sx,       0,          0,                 0,
			0,            2.0*sy,     0,                 0,
			0,            0,          -2.0*sz,           0,
			- (x0+x1)*sx, - (y0+y1)*sy, - (zNear+zFar)*sz,  1,
		]);
	}
}
