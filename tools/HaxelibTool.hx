package tools;

import neko.Lib;
import tools.Terminal;
import sys.io.Process;

import haxepunk.utils.LibInfo;

class HaxelibTool
{

	public function new()
	{
		var args = Sys.args();

		// Windows command line doesn't support ANSI colors...
		if (Sys.systemName() == "Windows")
		{
			colorize = false;
		}

		if (args.length < 2)
		{
			usage();
			return;
		}

		try
		{
			var command = args.shift();

			if (command == "--no-colors")
			{
				colorize = false;
				command = args.shift();
			}

			if (args.length < 1)
			{
				usage();
				return;
			}

			switch (command)
			{
				case "new":
					Project.create(args);
				case "setup":
					Setup.setup();
				case "update":
					Setup.update();
				case "process":
					Asset.process(args);
				case "help":
					usage();
				default:
					throw 'Unknown argument /yellow"$command"';
			}
		}
		catch(e:String)
		{
			print('/red/bold' + e + '/reset');
			usage();
		}
	}

	public function usage()
	{
		var tool = "haxelib run HaxePunk";
		var version = LibInfo.version;

		print('/green/bold-- HaxePunk $version --/reset\n');
		print('/blueUSAGE: /green$tool/reset setup');
		print('/blueUSAGE: /green$tool/reset update');
		print('/blueUSAGE: /green$tool/reset new [options] [PROJECT_NAME]');
		print("Options:
  /yellow-s/reset <width>x<height> : Set default size of window (default: 640x480)
  /yellow-r/reset <framerate>      : Set target frame rate (default: 60)
  /yellow-c/reset <class>          : Set name of main class (default: Main)");
	}

	public static function print(line:String)
	{
		Lib.println(Terminal.colorize(line, colorize));
	}

	public static function main()
	{
		new HaxelibTool();
	}

	private static var colorize:Bool = true;

}
