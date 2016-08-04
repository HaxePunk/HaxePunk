import haxe.io.Path;
import sys.FileSystem;

class Run
{
	public static function main ()
	{
		#if (haxe_ver < "3.3")
		var path = Path.normalize(Path.join([ Sys.getCwd(), Path.directory(neko.vm.Module.local().name) ]));
        	#else
		var path = Path.normalize(Path.directory(neko.vm.Module.local().name));
        	#end
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

			Sys.command("make", ["template.zip"]);

			Sys.setCwd(cwd);
		}

		if (rebuild)
		{
			args.shift();
		}

		// Call tool.n without the cwd passed by haxelib
		args.unshift(tool);
		Sys.setCwd(dir);

		var code = Sys.command("neko", args);

		Sys.setCwd(cwd);
		Sys.exit(code);
	}
}
