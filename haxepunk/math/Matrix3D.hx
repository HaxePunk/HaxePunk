package haxepunk.math;

import lime.utils.Vector3D;
import lime.utils.Float32Array;

class Matrix3D
{
	public var _11:Float = 0;
	public var _12:Float = 0;
	public var _13:Float = 0;
	public var _14:Float = 0;
	public var _21:Float = 0;
	public var _22:Float = 0;
	public var _23:Float = 0;
	public var _24:Float = 0;
	public var _31:Float = 0;
	public var _32:Float = 0;
	public var _33:Float = 0;
	public var _34:Float = 0;
	public var _41:Float = 0;
	public var _42:Float = 0;
	public var _43:Float = 0;
	public var _44:Float = 0;

	public function new(
		a1:Float=1, a2:Float=0, a3:Float=0, a4:Float=0,
		b1:Float=0, b2:Float=1, b3:Float=0, b4:Float=0,
		c1:Float=0, c2:Float=0, c3:Float=1, c4:Float=0,
		d1:Float=0, d2:Float=0, d3:Float=0, d4:Float=1)
	{
		_11 = a1; _21 = b1; _31 = c1; _41 = d1;
		_12 = a2; _22 = b2; _32 = c2; _42 = d2;
		_13 = a3; _23 = b3; _33 = c3; _43 = d3;
		_14 = a4; _24 = b4; _34 = c4; _44 = d4;
	}

	public var rawData(get, never):Float32Array;
	private inline function get_rawData():Float32Array
	{
		return new Float32Array([
			_11, _12, _13, _14,
			_21, _22, _23, _24,
			_31, _32, _33, _34,
			_41, _42, _43, _44
		]);
	}

	public function clone():Matrix3D
	{
		return new Matrix3D(
			_11, _12, _13, _14,
			_21, _22, _23, _24,
			_31, _32, _33, _34,
			_41, _42, _43, _44
		);
	}

	public function identity()
	{
		_11 = 1.0; _12 = 0.0; _13 = 0.0; _14 = 0.0;
		_21 = 0.0; _22 = 1.0; _23 = 0.0; _24 = 0.0;
		_31 = 0.0; _32 = 0.0; _33 = 1.0; _34 = 0.0;
		_41 = 0.0; _42 = 0.0; _43 = 0.0; _44 = 1.0;
	}

	public inline function translateVector3D(v:Vector3D):Void
	{
		translate(v.x, v.y, v.z);
	}

	public function translate(x:Float, y:Float, z:Float):Void
	{
		_11 = _11 + x * _14;
		_12 = _12 + y * _14;
		_13 = _13 + z * _14;
		_21 = _21 + x * _24;
		_22 = _22 + y * _24;
		_23 = _23 + z * _24;
		_31 = _31 + x * _34;
		_32 = _32 + y * _34;
		_33 = _33 + z * _34;
		_41 = _41 + x * _44;
		_42 = _42 + y * _44;
		_43 = _43 + z * _44;
	}

	public inline function scaleVector3D(v:Vector3D):Void
	{
		scale(v.x, v.y, v.z);
	}

	public function scale(x:Float, y:Float, z:Float):Void
	{
		_11 = _11 * x;
		_21 = _21 * x;
		_31 = _31 * x;
		_41 = _41 * x;
		_12 = _12 * y;
		_22 = _22 * y;
		_32 = _32 * y;
		_42 = _42 * y;
		_13 = _13 * z;
		_23 = _23 * z;
		_33 = _33 * z;
		_43 = _43 * z;
	}

	public function rotateX(angle:Float):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var tmp = new Matrix3D();
		tmp.identity();
		tmp._22 = cos;
		tmp._23 = sin;
		tmp._32 = -sin;
		tmp._33 = cos;
		multiply(tmp);
	}

	public function rotateY(angle:Float):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var tmp = new Matrix3D();
		tmp.identity();
		tmp._11 = cos;
		tmp._13 = -sin;
		tmp._31 = sin;
		tmp._33 = cos;
		multiply(tmp);
	}

	public function rotateZ(angle:Float):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var tmp = new Matrix3D();
		tmp.identity();
		tmp._11 = cos;
		tmp._12 = sin;
		tmp._21 = -sin;
		tmp._22 = cos;
		multiply(tmp);
	}

	public function multiply(m:Matrix3D):Matrix3D
	{
		var a11 = _11; var a12 = _12; var a13 = _13; var a14 = _14;
		var a21 = _21; var a22 = _22; var a23 = _23; var a24 = _24;
		var a31 = _31; var a32 = _32; var a33 = _33; var a34 = _34;
		var a41 = _41; var a42 = _42; var a43 = _43; var a44 = _44;

		_11 = a11 * m._11 + a12 * m._21 + a13 * m._31 + a14 * m._41;
		_12 = a11 * m._12 + a12 * m._22 + a13 * m._32 + a14 * m._42;
		_13 = a11 * m._13 + a12 * m._23 + a13 * m._33 + a14 * m._43;
		_14 = a11 * m._14 + a12 * m._24 + a13 * m._34 + a14 * m._44;

		_21 = a21 * m._11 + a22 * m._21 + a23 * m._31 + a24 * m._41;
		_22 = a21 * m._12 + a22 * m._22 + a23 * m._32 + a24 * m._42;
		_23 = a21 * m._13 + a22 * m._23 + a23 * m._33 + a24 * m._43;
		_24 = a21 * m._14 + a22 * m._24 + a23 * m._34 + a24 * m._44;

		_31 = a31 * m._11 + a32 * m._21 + a33 * m._31 + a34 * m._41;
		_32 = a31 * m._12 + a32 * m._22 + a33 * m._32 + a34 * m._42;
		_33 = a31 * m._13 + a32 * m._23 + a33 * m._33 + a34 * m._43;
		_34 = a31 * m._14 + a32 * m._24 + a33 * m._34 + a34 * m._44;

		_41 = a41 * m._11 + a42 * m._21 + a43 * m._31 + a44 * m._41;
		_42 = a41 * m._12 + a42 * m._22 + a43 * m._32 + a44 * m._42;
		_43 = a41 * m._13 + a42 * m._23 + a43 * m._33 + a44 * m._43;
		_44 = a41 * m._14 + a42 * m._24 + a43 * m._34 + a44 * m._44;

		return this;
	}

	public static inline function createOrtho(x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float):Matrix3D
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);

		return new Matrix3D(
			2.0*sx,       0,          0,                 0,
			0,            2.0*sy,     0,                 0,
			0,            0,          -2.0*sz,           0,
			- (x0+x1)*sx, - (y0+y1)*sy, - (zNear+zFar)*sz,  1
		);
	}
}
