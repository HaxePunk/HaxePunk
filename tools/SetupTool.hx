import neko.Sys;
import neko.Lib;
import neko.FileSystem;
import neko.io.File;
import neko.io.Path;

class SetupTool
{

	public function new()
	{
		var args:Array<String> = Sys.args();
		if (args.length < 2)
		{
			Lib.println("USAGE: haxelib run HaxePunk new");
			return;
		}

//		var last:String = (new Path(args[args.length-1])).toString();
//		var slash = last.substr(-1);
//		if (slash=="/"|| slash=="\\") 
//			last = last.substr(0, last.length - 1);
//		if (FileSystem.exists(last) && FileSystem.isDirectory(last)) {
//			Sys.setCwd(last);
//		}

		var command:String = args.shift();

		switch (command)
		{
			case "new":
				newProject(args);
		}
	}

	public function newProject(args:Array<String>)
	{
		var destFolder:String = (new Path(args.shift())).toString();
		var slash = destFolder.substr(-1);
		if (slash=="/"|| slash=="\\")
			destFolder = destFolder.substr(0, destFolder.length - 1);
		
		if (FileSystem.exists(destFolder) && FileSystem.isDirectory(destFolder))
		{
			var assetsFolder:String = destFolder + "/assets";
			if ( ! FileSystem.exists(assetsFolder) )
			{
				FileSystem.createDirectory(assetsFolder);
			}

			var srcFolder:String = destFolder + "/src";
			if ( ! FileSystem.exists(srcFolder) )
			{
				FileSystem.createDirectory(srcFolder);
			}
			
			File.copy('template/build.nmml', destFolder + '/build.nmml');
			File.copy('com/haxepunk/debug/console_debug.png', assetsFolder + '/console_debug.png');
			File.copy('com/haxepunk/debug/console_logo.png', assetsFolder + '/console_logo.png');
			File.copy('com/haxepunk/debug/console_output.png', assetsFolder + '/console_output.png');
			File.copy('com/haxepunk/debug/console_pause.png', assetsFolder + '/console_pause.png');
			File.copy('com/haxepunk/debug/console_play.png', assetsFolder + '/console_play.png');
			File.copy('com/haxepunk/debug/console_step.png', assetsFolder + '/console_step.png');
			File.copy('com/haxepunk/graphics/04B_03__.ttf', assetsFolder + '/04B_03__.ttf');
			File.copy('template/src/Main.hx', srcFolder + '/Main.hx');
		}
	}

	public static function main()
	{
		new SetupTool();
	}

}