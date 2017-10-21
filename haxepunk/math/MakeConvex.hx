package haxepunk.math;

// A polygon is a path along points CCW
typedef Polygon = Array<Point>;

/**
 * MakeConvex class
 *
 * Decomposes simple polygons into convex polygons in under-quadratic time.
 * @author Matrefeytontias
 */
class MakeConvex
{
	// Find all invalid vertices, that is, vertices that form an invalid angle (> 180°)
	static function findInvalid(p:Polygon):Array<Int>
	{
		var invalidVertices = new Array<Int>();
		var np = p.length;
		for (currentVIndex in 0 ... np)
		{
			var currentV = p[currentVIndex];
			var nextV = p[(currentVIndex + 1) % np];
			var nextNextV = p[(currentVIndex + 2) % np];
			var currentEdge = nextV - currentV;
			var nextEdge = nextNextV - nextV;
			if (currentEdge.orthoR().dot(nextEdge) < 0)
				invalidVertices.push((currentVIndex + 1) % np);
		}
		return invalidVertices;
	}

	/**
	 * Decomposes a counter-clockwise simple polygon into convex polygons.
	 */
	public static function run(polygon:Polygon):Array<Polygon>
	{
		var p = polygon.copy();
		var r = new Array<Polygon>();
		var invalidVertices = findInvalid(p);
		var np = p.length;

		var n:Int = invalidVertices.length;
		while ((n = invalidVertices.length) > 0)
		{
			// Find the starting vertex ; it's any invalid vertex that has a valid vertex after it
			// we know this exists because a polygon must have at least one valid vertex
			var startIndex:Int = 0;
			for (i in 0 ... n)
			{
				if (n == 1 || (invalidVertices[i] + 1) % np != invalidVertices[(i + 1) % n])
				{
					startIndex = invalidVertices[i];
					break;
				}
			}

			// After that, find the furthest valid point along the polygon that still forms a convex
			// polygon when linked to the starting vertex, or the first invalid vertex.
			// This is because by definition, the two edges that an invalid vertex is a part of cannot
			// belong to the same one polygon.
			var startVertex = p[startIndex];
			var firstEdge = p[(startIndex + 1) % np] - startVertex;
			var found = false, target:Int = 0;
			for (i in 2 ... np)
			{
				var curIndex = (startIndex + i) % np,
					curVertex = p[curIndex];

				// This vertex is invalid
				if (invalidVertices.indexOf(curIndex) > -1)
				{
					found = true;
					target = curIndex;
				}
				// This vertex, if added, would turn the polygon from convex to concave.
				// Thus, the correct vertex is the previous one
				else if ((startVertex - curVertex).orthoR().dot(firstEdge) < 0)
				{
					found = true;
					target = (startIndex + i - 1) % np;
				}

				if (found)
				{
					// Extract vertices startIndex to "target" ; they make up a convex polygon
					var newPoly = new Polygon(),
						k = startIndex;
					while (true)
					{
						newPoly.push(p[k]);
						if (k == target)
							break;
						k = (k + 1) % np;
					}
					r.push(newPoly);
					// Then, discard the vertices that were added to the resulting array, except the start and end
					p = p.filter(function(x) return newPoly.indexOf(x) == -1 || x == startVertex || x == p[target]);
					np = p.length;
					// Rearrange the indices in invalidVertices as well, since the contents of p will change
					invalidVertices = findInvalid(p);
					if (invalidVertices.length == 0)
						r.push(p);
					break;
				}
			}
		}

		return r.length == 0 ? [polygon] : r;
	}
}

// Convenience type with overloaded operations
// R is for Reentrant
@:forward
abstract Point(Vector2) from Vector2 to Vector2
{
	public function new(x:Float = 0., y:Float = 0.)
	{
		this = new Vector2(x, y);
	}

	@:from public static function fromStruct(v:{x:Float, y:Float}):Point
	{
		return new Point(v.x, v.y);
	}

	@:op(A + B) public function addR(b:Point):Point
	{
		return new Point(this.x + b.x, this.y + b.y);
	}

	@:op(A - B) public function subR(b:Point):Point
	{
		return addR(b.negR());
	}

	@:op(-A) public function negR():Point
	{
		return new Point(-this.x, -this.y);
	}

	@:op(A * B) public function dot(b:Point):Float
	{
		return this.x * b.x + this.y * b.y;
	}

	public function orthoR():Point
	{
		return new Point(this.y, -this.x);
	}
}
