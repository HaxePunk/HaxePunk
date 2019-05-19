import haxe.io.Path;
import sys.FileSystem;

class Run
{
	public static function main ()
	{
		var path = FileSystem.absolutePath(Path.directory(neko.vm.Module.local().name));

		var tool = Path.join([ path, "tool.n" ]);
		var template = Path.join([ path, "template.zip" ]);
		var args = Sys.args();
		var rebuild = args.length > 0 && args[0] == "--rebuild";
		var dir = args.pop();
		var cwd = Sys.getCwd();

		// If tool.n doesn't exists compile it
		if (!FileSystem.exists(tool) || rebuild)
		{
			Sys.setCwd(Path.join([ path, "tools" ]));

			Sys.command("haxe", ["tool.hxml"]);

			Sys.setCwd(cwd);
		}

		if (!FileSystem.exists(template))
		{
			Sys.setCwd(path);

			// copy template folder to zip file
			var out = sys.io.File.write("template.zip", true);
			var zip = new haxe.zip.Writer(out);
			zip.write(getEntries("template/"));

			Sys.setCwd(cwd);
		}

		if (rebuild)
		{
			args.shift();
		}

		// Call tool.n without the cwd passed by haxelib
		args.unshift(tool);

		// Enter the directory provided by haxelib
		Sys.setCwd(dir);

		var code = Sys.command("neko", args);

		Sys.setCwd(cwd);
		Sys.exit(code);
	}

	/** 
	* Recursively copies a directory. 
	* @param dir The directory to copy for compression.
	* @return A list of zip entries, to be passed to the writer.
	* @source: https://code.haxe.org/category/other/haxe-zip.html
	* @author: Mark Knol
	**/
	private static function getEntries(dir:String, ?entries:List<haxe.zip.Entry>, ?inDir:Null<String>):List<haxe.zip.Entry> 
	{
		if (entries == null)
		{
			entries = new List<haxe.zip.Entry>();
		}
		if (inDir == null)
		{
			inDir = dir;
		}
		for (file in sys.FileSystem.readDirectory(dir)) 
		{
			var path = haxe.io.Path.join([dir, file]);
			if (sys.FileSystem.isDirectory(path)) 
			{
				getEntries(path, entries, inDir);
			} 
			else 
			{
				var bytes:haxe.io.Bytes = haxe.io.Bytes.ofData(sys.io.File.getBytes(path).getData());
				var entry:haxe.zip.Entry = {
					fileName: StringTools.replace(path, inDir, ""), 
					fileSize: bytes.length,
					fileTime: Date.now(),
					compressed: false,
					dataSize: 0,
					data: bytes,
					crc32: haxe.crypto.Crc32.make(bytes)
				};
				entries.push(entry);
			}
		}
		return entries;
	}

}
