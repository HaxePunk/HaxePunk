package haxepunk.graphics.importer;

import haxe.ds.StringMap;
import lime.Assets;
import haxepunk.graphics.Model;
import haxepunk.renderers.Renderer;

using StringTools;

class Wavefront
{

	public static function load(path:String, ?material:Material):Model
	{
		var vertices = new FloatArray();
		var texCoords = new FloatArray();
		var normals = new FloatArray();
		var data = new FloatArray();

		var tris = new IntArray();

		var indexMap = new StringMap<Int>();
		var model = new Model(material);

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

			var processFace = false;
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
					if (data.length > 0)
					{
						var mesh = new Mesh();
						mesh.createBuffer(data);
						mesh.createIndexBuffer(tris);
						model.addMesh(mesh);

						data.splice(0, data.length);
						tris.splice(0, tris.length);
					}
					if (parts.length > 0)
						groupName = parts.shift();
				case "f": // face
					processFace = true;
					// convert triangle fan to individual triangles
					var i = 3;
					while (i < parts.length)
					{
						parts.insert(i, parts[0]);
						parts.insert(i+1, parts[i-1]);
						i += 3;
					}
					// parse indices
					for (i in 0...parts.length)
					{
						var part = parts[i];
						if (indexMap.exists(part))
						{
							tris.push(indexMap.get(part));
						}
						else
						{
							var i = Std.int(data.length / 8);
							tris.push(i);
							indexMap.set(part, i);

							var p = part.split("/");
							var index = parseInt(p[0]) * 3;
							data.push(vertices[index]);
							data.push(vertices[index+1]);
							data.push(vertices[index+2]);

							if (p.length > 1)
							{
								index = parseInt(p[1]) * 2;
								data.push(texCoords[index]);
								data.push(texCoords[index+1]);

								if (p.length > 2)
								{
									index = parseInt(p[2]) * 3;
									data.push(normals[index]);
									data.push(normals[index+1]);
									data.push(normals[index+2]);
								}
								else
								{
									data.push(0);
									data.push(0);
									data.push(0);
								}
							}
							else
							{
								data.push(0);
								data.push(0);

								data.push(0);
								data.push(0);
								data.push(0);
							}
						}
					}
				case "mtllib":
				case "usemtl":
			}
		}

		if (data.length > 0)
		{
			var mesh = new Mesh();
			mesh.createBuffer(data);
			mesh.createIndexBuffer(tris);
			model.addMesh(mesh);
		}

		return model;
	}

	private static inline function parseInt(str:String):Int
	{
		return (str.trim() == "" ? 0 : Std.parseInt(str) - 1);
	}

}
