import neko.Lib;
import Terminal;
import sys.io.Process;
import haxe.io.BytesOutput;
import haxe.io.Eof;

import haxepunk.utils.HaxelibInfo;

class CLI
{

	public function new()
	{
		var args:Array<String> = Sys.args();

		// Windows command line doesn't support ANSI colors...
		if (Sys.systemName() == "Windows")
		{
			colorize = false;
		}

		if (args.length == 0)
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

			switch (command)
			{
				case "new":
					Project.create(args);
				case "setup":
					Setup.setup();
				case "update":
					Setup.update();
				case "doc":
					openDoc();
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

	/** From https://github.com/openfl/lime-tools/blob/master/helpers/ProcessHelper.hx */
	public static function openDoc():Void
	{
		// Get HaxePuk path
		var output = "";

		try
		{
			var process = new Process("haxelib", ["path", "HaxePunk"]);
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
		catch (e:Dynamic) { trace(e); }

		var lines = output.split("\n");
		var result = "";

		for (i in 1...lines.length)
		{
			if (StringTools.startsWith(lines[i], "-D HaxePunk"))
			{
				result = StringTools.trim(lines[i - 1]);
			}
		}

		var url = result + "doc/pages/index.html";

		if (Sys.systemName() == "Windows")
		{
			Sys.command("start", [ url ]);
		}
		else if (Sys.systemName() == "Mac")
		{
			Sys.command("/usr/bin/open", [ url ]);
		}
		else
		{
			Sys.command("/usr/bin/xdg-open", [ url ]);
		}
	}

	public function usage()
	{
		var tool = "haxelib run HaxePunk";
		var version = HaxelibInfo.version;

		print('/green/bold-- HaxePunk $version --/reset\n');
		print('/blueUSAGE: /green$tool/reset doc');
		print('/blueUSAGE: /green$tool/reset setup');
		print('/blueUSAGE: /green$tool/reset update');
		print("");
		print('/blueUSAGE: /green$tool/reset new [options] [PROJECT_NAME]');
		print("Options:
  /yellow-s/reset <width>x<height> : Set default size of window (default: 640x480)
  /yellow-r/reset <framerate>      : Set target frame rate (default: 60)
  /yellow-c/reset <class>          : Set name of main class (default: Main)
  /yellow--flashdevelop/reset	  : Add a FlashDevelop project file
  /yellow--sublimetext/reset	  : Add a SublimeText project file");
	}

	public static function print(line:String)
	{
		Lib.println(Terminal.colorize(line, colorize));
	}

	public static function main()
	{
		new CLI();
	}

	private static var colorize:Bool = true;

}
