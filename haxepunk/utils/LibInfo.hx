package haxepunk.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;
import haxe.io.BytesOutput;
import haxe.io.Eof;
import sys.io.Process;

using StringTools;

private typedef LibInfoType = {
	name:String,
	url:String,
	license:String,
	tags:Array<String>,
	description:String,
	version:String,
	releasenote:String,
	contributors:Array<String>,
	dependencies:Map<String, String>
};

class LibInfoBuilder
{

	public static function getLibraryPath(library:String):String
	{
		var output = getProcessOutput("haxelib", ["path", library]);

		var result = "";
		var lines = output.split("\n");

		var libraryDefine = new EReg('-D $library', 'i');
		for (i in 1...lines.length)
		{
			if (libraryDefine.match(lines[i]) && i > 0)
			{
				result = lines[i - 1].trim();
			}
		}

		return result;
	}

	public static function getProcessOutput(cmd:String, args:Array<String>):String
	{
		var output = "";

		try
		{
			var process = new Process(cmd, args);
			var buffer = new BytesOutput();

			var waiting = true;
			while (waiting)
			{
				try
				{
					var current = process.stdout.readAll (1024);
					buffer.write(current);

					if (current.length == 0)
						waiting = false;
				}
				catch (e:Eof)
				{
					waiting = false;
				}
			}

			process.close();
			output = buffer.getBytes().toString();
		}
		catch (e:Dynamic) { }

		return output;
	}

	public static function getGitSHA(path:String):String
	{
		var oldWd = Sys.getCwd();

		Sys.setCwd(path);
		var sha = getProcessOutput("git", ["rev-parse", "HEAD"]);
		if (!SHA_REGEX.match(sha))
		{
			return null;
		}

		Sys.setCwd(oldWd);
		return sha.substring(0, 10);
	}

	macro public static function build():Array<Field>
	{
		// Get HaxePuk path
		var path = getLibraryPath("HaxePunk");

		// Read haxelib.json
		var doc:LibInfoType = try {
			Json.parse(sys.io.File.read(path + "haxelib.json").readAll().toString());
		} catch (e:Dynamic) { trace(e); null;}

		// Construct fields
		var fields:Array<Field> = Context.getBuildFields();

		// Version info
		if (doc.version != null)
		{
			var version = "v" + doc.version;

			fields.push({
				name: "version",
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{doc.version}),
				pos: Context.currentPos()
			});

			var sha = getGitSHA(path);
			if (sha != null)
			{
				version += "@" + sha;
			}

			fields.push({
				name: "fullVersion",
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{version}),
				pos: Context.currentPos()
			});
		}

		// Simple String value
		for (field in ["name", "url", "license", "description", "releasenote"])
		{
			var value:String = Reflect.field(doc, field);

			fields.push({
				name: field,
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{value}),
				pos: Context.currentPos()
			});
		}

		// Array<String> value
		for (field in ["tags", "contributors"])
		{
			var value:Array<String> = Reflect.field(doc, field);

			fields.push({
				name: field,
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic],
				kind: FieldType.FProp("default", "never", macro:Array<String>, macro $v{value}),
				pos: Context.currentPos()
			});
		}

		// Map<String, String> value
		fields.push({
			name: "dependencies",
			doc: null,
			meta: [],
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:Dynamic, macro $v{doc.dependencies}),
			pos: Context.currentPos()
		});

		return fields;
	}

	private static var SHA_REGEX = ~/[a-f0-9]{40}/g;

}
#end

#if !macro @:build(haxepunk.utils.LibInfo.LibInfoBuilder.build()) #end
class LibInfo
{
}
