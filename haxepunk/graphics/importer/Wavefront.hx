package haxepunk.graphics.importer;

import haxe.ds.StringMap;
import lime.utils.Assets;
import haxepunk.graphics.Mesh;

using StringTools;

class Wavefront
{

	public static function load(path:String):List<Mesh>
	{
		var vertices = new Array<Float>();
		var texCoords = new Array<Float>();
		var normals = new Array<Float>();

		var faces = new Array<Int>();

		var indices = new Array<Array<Int>>();
		var indexMap = new StringMap<Int>();

		var meshList = new List<Mesh>();

		var lines = Assets.getText(path).split("\n");
		var v = 0, t = 0, n = 0;
		var groupName:String = null;
		for (line in lines)
		{
			line = line.trim();
			if (line.startsWith("#") || line == "") continue;

			var parts = line.split(" ");
			for (part in parts) if (part.trim() == "") parts.remove(part);
			if (parts.length == 0) continue;

			switch (parts.shift())
			{
				case "v": // vertex
					vertices[v++] = Std.parseFloat(parts[0]);
					vertices[v++] = Std.parseFloat(parts[1]);
					vertices[v++] = Std.parseFloat(parts[2]);
				case "vt": // vertex tex coord
					texCoords[t++] = Std.parseFloat(parts[0]);
					texCoords[t++] = Std.parseFloat(parts[1]);
				case "vn": // vertex normal
					normals[n++] = Std.parseFloat(parts[0]);
					normals[n++] = Std.parseFloat(parts[1]);
					normals[n++] = Std.parseFloat(parts[2]);
				case "s": // smooth shading
				case "g": // group
					if (groupName != null)
					{
						var data = createMeshData(vertices, texCoords, normals, indices);
						if (data.length > 0)
						{
							meshList.push(new Mesh(data, faces));
						}
						// t = n = v = 0;
						groupName = null;
					}
					if (parts.length > 0)
						groupName = parts[0];
				case "f": // face
					for (part in parts)
					{
						if (indexMap.exists(part))
						{
							faces.push(indexMap.get(part));
						}
						else
						{
							var i = indices.length;
							faces.push(i);
							indexMap.set(part, i);

							var p = part.split("/");
							var vv = parseInt(p[0]),
								vt = vv,
								vn = vv;
							if (p.length > 1)
							{
								vt = parseInt(p[1]);
								if (p.length > 2)
								{
									vn = parseInt(p[2]);
								}
							}
							indices.push([vv, vt, vn]);
						}
					}
					if (parts.length > 3)
					{
						var len = faces.length;
						faces.push(faces[len - 2]);
						faces.push(faces[len - 4]);
					}
				case "mtllib":
				case "usemtl":
			}
		}

		var data = createMeshData(vertices, texCoords, normals, indices);
		if (data.length > 0)
		{
			meshList.push(new Mesh(data, faces));
		}

		return meshList;
	}

	private static function createMeshData(vertices:Array<Float>, texCoords:Array<Float>, normals:Array<Float>, indices:Array<Array<Int>>):Array<Float>
	{
		var data = new Array<Float>();
		data[indices.length * 8 - 1] = 0.0;
		var d = 0;
		for (index in indices)
		{
			var i = index[0] * 3;
			data[d++] = vertices[i];
			data[d++] = vertices[i + 1];
			data[d++] = vertices[i + 2];

			i = index[1] * 2;
			if (i < texCoords.length)
			{
				data[d++] = texCoords[i];
				data[d++] = texCoords[i + 1];
			}
			else
			{
				data[d++] = data[d++] = 0;
			}

			i = index[2] * 3;
			if (i < normals.length)
			{
				data[d++] = normals[i];
				data[d++] = normals[i + 1];
				data[d++] = normals[i + 2];
			}
			else
			{
				data[d++] = data[d++] = data[d++] = 0;
			}
		}
		return data;
	}

	private static inline function parseInt(str:String):Int
	{
		return (str.trim() == "" ? 0 : Std.parseInt(str) - 1);
	}

}
