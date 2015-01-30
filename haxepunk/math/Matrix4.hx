package haxepunk.math;

#if cpp
typedef MatrixValue = cpp.Float32;
#else
typedef MatrixValue = Float;
#end

#if flash
typedef NativeMatrix4 = flash.geom.Matrix3D;
#else
typedef NativeMatrix4 = lime.utils.Float32Array;
#end

class Matrix4 implements ArrayAccess<MatrixValue>
{

	public var _11:MatrixValue = 1;
	public var _12:MatrixValue = 0;
	public var _13:MatrixValue = 0;
	public var _14:MatrixValue = 0;
	public var _21:MatrixValue = 0;
	public var _22:MatrixValue = 1;
	public var _23:MatrixValue = 0;
	public var _24:MatrixValue = 0;
	public var _31:MatrixValue = 0;
	public var _32:MatrixValue = 0;
	public var _33:MatrixValue = 1;
	public var _34:MatrixValue = 0;
	public var _41:MatrixValue = 0;
	public var _42:MatrixValue = 0;
	public var _43:MatrixValue = 0;
	public var _44:MatrixValue = 1;

	public function new(?data:NativeMatrix4)
	{
		if (data != null)
		{
			_native = data;
			_isDirty = false;
		}
	}

	public var native(get, never):NativeMatrix4;
	private inline function get_native():NativeMatrix4
	{
		if (_isDirty)
		{
			if (_native == null)
			{
				#if flash
				_native = new NativeMatrix4(flash.Vector.ofArray(toArray()));
				#else
				_native = new NativeMatrix4(toArray());
				#end
			}
			else
			{
				var bytes = #if flash _native.rawData #else _native #end;
				bytes[0] = _11;
				bytes[1] = _12;
				bytes[2] = _13;
				bytes[3] = _14;

				bytes[4] = _21;
				bytes[5] = _22;
				bytes[6] = _23;
				bytes[7] = _24;

				bytes[8] = _31;
				bytes[9] = _32;
				bytes[10] = _33;
				bytes[11] = _34;

				bytes[12] = _41;
				bytes[13] = _42;
				bytes[14] = _43;
				bytes[15] = _44;
			}
			_isDirty = false;
		}
		return _native;
	}

	public function toArray():Array<MatrixValue>
	{
		return [
			_11, _12, _13, _14,
			_21, _22, _23, _24,
			_31, _32, _33, _34,
			_41, _42, _43, _44
		];
	}

	public function toString():String
	{
		return "<Matrix4>\n| " +
			_11 + ", " + _12 + ", " + _13 + ", " + _14 + " |\n| " +
			_21 + ", " + _22 + ", " + _23 + ", " + _24 + " |\n| " +
			_31 + ", " + _32 + ", " + _33 + ", " + _34 + " |\n| " +
			_41 + ", " + _42 + ", " + _43 + ", " + _44 + " |";
	}

	public function clone():Matrix4
	{
		var m = new Matrix4(_native);
		m._11 = _11; m._21 = _21; m._31 = _31; m._41 = _41;
		m._12 = _12; m._22 = _22; m._32 = _32; m._42 = _42;
		m._13 = _13; m._23 = _23; m._33 = _33; m._43 = _43;
		m._14 = _14; m._24 = _24; m._34 = _34; m._44 = _44;
		return m;
	}

	public function identity()
	{
		_11 = 1.0; _12 = 0.0; _13 = 0.0; _14 = 0.0;
		_21 = 0.0; _22 = 1.0; _23 = 0.0; _24 = 0.0;
		_31 = 0.0; _32 = 0.0; _33 = 1.0; _34 = 0.0;
		_41 = 0.0; _42 = 0.0; _43 = 0.0; _44 = 1.0;
		_isDirty = true;
	}

	public function lookAt(eye:Vector3, target:Vector3, up:Vector3):Matrix4
	{
		var zaxis = eye - target;
		zaxis.normalize();
		var yaxis = up % zaxis;
		yaxis.normalize();
		var xaxis = zaxis % yaxis;

		_11 = xaxis.x; _12 = yaxis.x; _13 = zaxis.x;
		_21 = xaxis.y; _22 = yaxis.y; _23 = zaxis.y;
		_31 = xaxis.z; _32 = yaxis.z; _33 = zaxis.z;

		_41 = -(xaxis * eye);
		_42 = -(yaxis * eye);
		_43 = -(zaxis * eye);

		return this;
	}

	public inline function translateVector3(v:Vector3):Void
	{
		translate(v.x, v.y, v.z);
	}

	public function translate(x:MatrixValue, y:MatrixValue, z:MatrixValue):Void
	{
		_41 = x;
		_42 = y;
		_43 = z;
		_isDirty = true;
	}

	public inline function scaleVector3(v:Vector3):Void
	{
		scale(v.x, v.y, v.z);
	}

	public function scale(x:MatrixValue, y:MatrixValue, z:MatrixValue):Void
	{
		// not using *= because it compiles better in c++
		_11 = _11 * x;
		_21 = _21 * x;
		_31 = _31 * x;

		_12 = _12 * y;
		_22 = _22 * y;
		_32 = _32 * y;

		_13 = _13 * z;
		_23 = _23 * z;
		_33 = _33 * z;

		_isDirty = true;
	}

	public inline function rotateVector3(v:Vector3):Void
	{
		rotateX(v.x);
		rotateY(v.y);
		rotateZ(v.z);
	}

	public function rotateX(angle:MatrixValue):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		var tmp = _12;
		_12 = tmp * cos + _13 * sin;
		_13 = tmp * -sin + _13 * cos;

		tmp = _22;
		_22 = tmp * cos + _23 * sin;
		_23 = tmp * -sin + _23 * cos;

		tmp = _32;
		_32 = tmp * cos + _33 * sin;
		_33 = tmp * -sin + _33 * cos;

		tmp = _42;
		_42 = tmp * cos + _43 * sin;
		_43 = tmp * -sin + _43 * cos;

		_isDirty = true;
	}

	public function rotateY(angle:MatrixValue):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		var tmp = _11;
		_11 = tmp * cos + _13 * sin;
		_13 = tmp * -sin + _13 * cos;

		tmp = _21;
		_21 = tmp * cos + _23 * sin;
		_23 = tmp * -sin + _23 * cos;

		tmp = _31;
		_31 = tmp * cos + _33 * sin;
		_33 = tmp * -sin + _33 * cos;

		tmp = _41;
		_41 = tmp * cos + _43 * sin;
		_43 = tmp * -sin + _43 * cos;

		_isDirty = true;
	}

	public function rotateZ(angle:MatrixValue):Void
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		var tmp = _11;
		_11 = tmp * cos + _12 * sin;
		_12 = _12 * cos - tmp * sin;

		tmp = _21;
		_21 = tmp * cos + _22 * sin;
		_22 = _22 * cos - tmp * sin;

		tmp = _31;
		_31 = tmp * cos + _32 * sin;
		_32 = _32 * cos - tmp * sin;

		tmp = _41;
		_41 = _11 + (_31 - _21);
		_42 = _12 + (_32 - _22);

		// var m = new Matrix4();
		// m._11 = m._22 = Math.cos(angle);
		// m._21 = Math.sin(angle);
		// m._12 = -m._21;
		// multiply(m);

		_isDirty = true;
	}

	public function multiply(m:Matrix4):Matrix4
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

		_isDirty = true;

		return this;
	}

	public var determinant(get, never):MatrixValue;
	private function get_determinant():MatrixValue
	{
		return ((_11 * _22 - _12 * _21) * (_33 * _44 - _34 * _43)
			- (_11 * _23 - _13 * _21) * (_32 * _44 - _34 * _42)
			+ (_11 * _24 - _14 * _21) * (_32 * _43 - _33 * _42)
			+ (_12 * _23 - _13 * _22) * (_31 * _44 - _34 * _41)
			- (_12 * _24 - _14 * _22) * (_31 * _43 - _33 * _41)
			+ (_13 * _24 - _14 * _23) * (_31 * _42 - _32 * _41));
	}

	public function invert():Bool
	{
		var d = determinant;

		if (d == 0) return false;

		var m11:MatrixValue = _11; var m21:MatrixValue = _21; var m31:MatrixValue = _31; var m41:MatrixValue = _41;
		var m12:MatrixValue = _12; var m22:MatrixValue = _22; var m32:MatrixValue = _32; var m42:MatrixValue = _42;
		var m13:MatrixValue = _13; var m23:MatrixValue = _23; var m33:MatrixValue = _33; var m43:MatrixValue = _43;
		var m14:MatrixValue = _14; var m24:MatrixValue = _24; var m34:MatrixValue = _34; var m44:MatrixValue = _44;

		d = 1 / d;

		_11 =  d * (m22 * (m33 * m44 - m43 * m34) - m32 * (m23 * m44 - m43 * m24) + m42 * (m23 * m34 - m33 * m24));
		_12 = -d * (m12 * (m33 * m44 - m43 * m34) - m32 * (m13 * m44 - m43 * m14) + m42 * (m13 * m34 - m33 * m14));
		_13 =  d * (m12 * (m23 * m44 - m43 * m24) - m22 * (m13 * m44 - m43 * m14) + m42 * (m13 * m24 - m23 * m14));
		_14 = -d * (m12 * (m23 * m34 - m33 * m24) - m22 * (m13 * m34 - m33 * m14) + m32 * (m13 * m24 - m23 * m14));
		_21 = -d * (m21 * (m33 * m44 - m43 * m34) - m31 * (m23 * m44 - m43 * m24) + m41 * (m23 * m34 - m33 * m24));
		_22 =  d * (m11 * (m33 * m44 - m43 * m34) - m31 * (m13 * m44 - m43 * m14) + m41 * (m13 * m34 - m33 * m14));
		_23 = -d * (m11 * (m23 * m44 - m43 * m24) - m21 * (m13 * m44 - m43 * m14) + m41 * (m13 * m24 - m23 * m14));
		_24 =  d * (m11 * (m23 * m34 - m33 * m24) - m21 * (m13 * m34 - m33 * m14) + m31 * (m13 * m24 - m23 * m14));
		_31 =  d * (m21 * (m32 * m44 - m42 * m34) - m31 * (m22 * m44 - m42 * m24) + m41 * (m22 * m34 - m32 * m24));
		_32 = -d * (m11 * (m32 * m44 - m42 * m34) - m31 * (m12 * m44 - m42 * m14) + m41 * (m12 * m34 - m32 * m14));
		_33 =  d * (m11 * (m22 * m44 - m42 * m24) - m21 * (m12 * m44 - m42 * m14) + m41 * (m12 * m24 - m22 * m14));
		_34 = -d * (m11 * (m22 * m34 - m32 * m24) - m21 * (m12 * m34 - m32 * m14) + m31 * (m12 * m24 - m22 * m14));
		_41 = -d * (m21 * (m32 * m43 - m42 * m33) - m31 * (m22 * m43 - m42 * m23) + m41 * (m22 * m33 - m32 * m23));
		_42 =  d * (m11 * (m32 * m43 - m42 * m33) - m31 * (m12 * m43 - m42 * m13) + m41 * (m12 * m33 - m32 * m13));
		_43 = -d * (m11 * (m22 * m43 - m42 * m23) - m21 * (m12 * m43 - m42 * m13) + m41 * (m12 * m23 - m22 * m13));
		_44 =  d * (m11 * (m22 * m33 - m32 * m23) - m21 * (m12 * m33 - m32 * m13) + m31 * (m12 * m23 - m22 * m13));

		return _isDirty = true;
	}

	public function transpose()
	{
		var tmp:MatrixValue;
		tmp = _12; _12 = _21; _21 = tmp;
		tmp = _13; _13 = _31; _31 = tmp;
		tmp = _14; _14 = _41; _41 = tmp;
		tmp = _23; _23 = _32; _32 = tmp;
		tmp = _24; _24 = _42; _42 = tmp;
		tmp = _34; _34 = _43; _43 = tmp;
	}

	/**
	 * Creates a perspective matrix
	 * @param fov The field of view in radians
	 * @param aspect The viewport's aspect ratio
	 * @param near The z-axis nearest value
	 * @param far The z-axis farthest value
	 */
	public static inline function createPerspective(fov:MatrixValue, aspect:MatrixValue, near:MatrixValue, far:MatrixValue):Matrix4
	{
		var m = new Matrix4();
		if (fov <= 0 || aspect == 0)
		{
			return m;
		}

		var depth = near - far;
		var oneOverDepth = 1 / depth;

		m._22 = -1 / Math.tan(0.5 * fov);
		m._11 = -m._22 / aspect;
		m._33 = (far + near) * oneOverDepth;
		m._43 = (2 * far * near) * oneOverDepth;
		m._34 = -1;
		m._44 = 0;
		m._isDirty = true;

		return m;
	}

	public static inline function createOrtho(left:MatrixValue, right:MatrixValue,  top:MatrixValue, bottom:MatrixValue, near:MatrixValue, far:MatrixValue):Matrix4
	{
		var m = new Matrix4();
		var sx = 1.0 / (right - left);
		var sy = 1.0 / (bottom - top);
		var sz = 1.0 / (far - near);

		m._11 = 2.0 * sx;
		m._22 = 2.0 * sy;
		m._33 = -2.0 * sz;

		m._41 = -(left + right) * sx;
		m._42 = -(top + bottom) * sy;
		m._43 = -(near + far) * sz;
		m._isDirty = true;

		return m;
	}

	private function __get(index:Int):MatrixValue
	{
		return switch (index)
		{
			case 0: _11;
			case 1: _12;
			case 2: _13;
			case 3: _14;
			case 4: _21;
			case 5: _22;
			case 6: _23;
			case 7: _24;
			case 8: _31;
			case 9: _32;
			case 10: _33;
			case 11: _34;
			case 12: _41;
			case 13: _42;
			case 14: _43;
			case 15: _44;
			default: throw "Invalid index value for Matrix4 (0-15).";
		}
	}

	private function __set(index:Int, value:MatrixValue):MatrixValue
	{
		_isDirty = true;
		return switch (index)
		{
			case 0: _11 = value;
			case 1: _12 = value;
			case 2: _13 = value;
			case 3: _14 = value;
			case 4: _21 = value;
			case 5: _22 = value;
			case 6: _23 = value;
			case 7: _24 = value;
			case 8: _31 = value;
			case 9: _32 = value;
			case 10: _33 = value;
			case 11: _34 = value;
			case 12: _41 = value;
			case 13: _42 = value;
			case 14: _43 = value;
			case 15: _44 = value;
			default: throw "Invalid index value for Matrix4 (0-15).";
		}
	}

	private var _native:NativeMatrix4;
	private var _isDirty:Bool = true;

}
